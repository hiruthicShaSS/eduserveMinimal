import os
import time
import json
import datetime

from colorama import init
from colorama import Fore, Back, Style
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

from selenium import webdriver
from selenium.common.exceptions import ElementNotInteractableException, NoSuchElementException

chrome_options = webdriver.ChromeOptions()
chrome_options.binary_location = os.environ.get("GOOGLE_CHROME_BIN")
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("user-agent=[Chrome/80.0.3987.116]")
chrome_options.add_argument("--silent")

web = webdriver.Chrome(
    executable_path=os.environ.get("CHROMEDRIVER_PATH"),
    options=chrome_options)
init()  # Colorama initiation


class EduServe:
    def __init__(self):
        self.data = dict()
        with open("config.json") as configData:
            self.config = json.load(configData)

    def login(self):
        web.get("https://eduserve.karunya.edu/Login.aspx")
        try:
            # Entering username
            web.find_element_by_id('mainContent_Login1_UserName').send_keys(
                self.config["username"])
            # Entering password
            web.find_element_by_id('mainContent_Login1_Password').send_keys(
                self.config["password"])
            # Clicking login button
            web.find_element_by_id('mainContent_Login1_LoginButton').click()
            print(Fore.GREEN, "Login Successful.")
            time.sleep(3)
        except Exception as e:
            print(Fore.RED, "Login unsuccessful")
            print(Fore.RED, e)

    def fetch(self):
        self.data["reg"] = web.find_element_by_id('mainContent_LBLREGNO').text
        self.data["name"] = web.find_element_by_id('mainContent_LBLNAME').text
        self.data["programme"] = web.find_element_by_id(
            'mainContent_LBLPROGRAMME').text
        self.data["semester"] = web.find_element_by_id(
            'mainContent_LBLSEMESTER').text
        self.data["kmail"] = web.find_element_by_id(
            'mainContent_LBLEMAILID').text
        self.data["mobile"] = web.find_element_by_id(
            'mainContent_LBLMOBILENO').text
        self.data["mentor"] = web.find_element_by_id(
            'mainContent_LBLMENTOR').text
        self.data["studentIMG"] = web.find_element_by_id(
            "mainContent_IMGSTUDENT").get_attribute("src")

        self.data["arrears"] = web.find_element_by_id(
            'mainContent_LBLARREAR').text
        self.data["resultOf"] = web.find_element_by_id(
            'mainContent_LBLCURRENTMONTHYR').text
        self.data["att"] = web.find_element_by_id('mainContent_LBLCLASS').text
        self.data["asm"] = web.find_element_by_id(
            'mainContent_LBLASSEMBLY').text

        self.data["credits"] = web.find_element_by_id(
            "mainContent_LBLCURRENTCREDITEARNED").text
        self.data["cgpa"] = web.find_element_by_id(
            "mainContent_LBLCURRENTCGPA").text
        self.data["sgpa"] = web.find_element_by_id(
            "mainContent_LBLCURRENTSGPA").text
        self.data["nonAcademicCredits"] = web.find_element_by_id(
            "mainContent_LBLCURRENTNONACADEMICCREDITEARNED").text

        applications = list()
        self.data["leaveApplications"] = dict()
        # Leave application's
        for row in range(10):  # Traversing through row's
            if applications:  # If list contains data, add it to data dict
                applications.pop(0)
                # Remove empty strings
                applications = [i for i in applications if i and i != " "]
                self.data["leaveApplications"][applications[1]] = applications
                applications.clear()

            try:
                for column in range(9):  # Traversing through column's
                    try:
                        applications.append(web.find_element_by_xpath(
                            f"//tbody/tr[@id='ctl00_mainContent_grdData_ctl00__{row}']/td[{column}]").text)
                    except NoSuchElementException:
                        continue
            except NoSuchElementException:
                continue

        # OD application's
        applications.clear()
        for row in range(10):  # Traversing through row's
            # if applications:  # If list contains data, add it to data dict
            #     # Remove empty strings
            #     applications = [i for i in applications if i and i != " "]
            #     self.data["leaveApplications"][applications[8]] = applications
            #     applications.clear()

            try:
                for column in range(1, 14):  # Traversing through column's
                    try:
                        applications.append(web.find_element_by_xpath(
                            f"//tbody/tr[@id='ctl00_mainContent_grdStudentOD_ctl00__{row}']/td[{column}]").text)
                    except IndexError:
                        continue
                    except NoSuchElementException:
                        continue
            except NoSuchElementException:
                continue

        self.dumpData()

    def dumpData(self):
        print(Fore.WHITE, "Writing to file...")
        with open("datadump.json", "w") as dump:
            self.data["lastUpdated"] = datetime.datetime.now().strftime(
                "%d-%m-%Y %H:%M:%S")
            json.dump(self.data, dump)
        print(Fore.GREEN, "Done.")

    def upload(self):
        print(Fore.WHITE, "Uploading data...")
        gauth = GoogleAuth()
        gauth.LocalWebserverAuth()
        drive = GoogleDrive(gauth)

        tracking = drive.CreateFile(
            {"title": "datadump.json", 'mimeType': 'application/json', "id": self.config["sharingLink"].split("/")[5]})
        tracking_content = tracking.GetContentString()
        lines = str()
        for line in open("datadump.json", "r").readlines():
            lines += line
        tracking_content = lines
        tracking.SetContentString(tracking_content)
        tracking.Upload()
        tracking = None
        print(Fore.GREEN, "Done.")

    def finish(self):
        self.upload()
        web.close()  # Close browser instance
