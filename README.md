# eduserveMinimal

Minimalist app for eduserve

This branch contains the code for scrapping eduserve and upload the data to cloud.
This script uses Google Drive to sync the data with mobile app.

## Setup

1. ### Clone the repo

   ```bash
   git clone https://github.com/hiruthic2002/eduserveMinimal.git
   git checkout scrapper
   ```

2. ### Run the script

    ```bash
    pip install -r requirements.txt
    python main.py
    ```

    **Google Drive method:**

    This script require client_secret.json file which can be attained from [Google Developer Console](https://stackoverflow.com/questions/40136699/using-google-api-for-python-where-do-i-get-the-client-secrets-json-file-from). If you have dedicated cloud storage please use that, with GDrive you need to give permission every time the script executes.

    *If you are gonna use different storage solution you dont need this step and you can modify the code on the file [eduserve.py](/eduserve.py) below the 'upload' function*

    *This create's a file called 'datadump.json' which contains the eduserve data.*
    *This is a one time process*

    - Uplodad this file to your [Google Drive](https://drive.google.comdrive/u/0/my-drive).
    - Right click on the uploaded file and click 'Get link' and change the access to 'Anyone with the link' and copy the link.
    - Paste the sharing link on the value of 'sharingLink' key in 'config json' file.
    - [Generate](https://sites.google.com/site/gdocs2direct/home) direct download link.

3. ### Automation

- #### For someone who knows basic navigation on Windows10

  - Without raw script:
      1. Press Windows button and type 'Task Scheduler' and hit enter.
      2. On left hand side click 'Task Scheduler Library'.
      3. Click 'Create Basic Task...' on top right hand side.
      4. Give it a name and description.
      5. Select 'When the computer start' and click 'Next'.
      6. Select 'Start a program'.
      7. On program text bar type "python" or "python3" dependeing on your setup.
      8. Add main.py as argument in argument text box and 'Next'.
      9. Check "open the properties dialog for this taskwhen I click Finish" and press 'Finish'.
      10. Now go to the 'Conditions' tab and check the "Start only if the following network connection is available" and select your reliable network. Andpress 'OK'.
  - With the release package:
      1. Install the package on your system.
      2. Install the setup.
      3. Copy the file 'client_secrets.json' to the installed directory.
      4. Configure the 'config.json' file:

            - "username": Your EduServe register number.
            - "password": EduServe password.
            - "stars": Number of stars for each feedback form.
            - "sharingLink": Your drive file sharing link.
      5. Press Windows + R and type ```%appdata%\Microsoft\Windows\Start Menu\Programs``` this opens a folder in explorer.
      6. Create shortcut on the above directory with main.exe.

- #### For noob's

   [Video](https://youtu.be/LeXXiJaNVG0)

   1. Go to [releases](https://github.com/hiruthic2002/eduserveMinimal/releases) tab and download the latest release.
   2. Install the setup.
   3. Copy the file 'client_secrets.json' to the installed directory.
   4. Configure the 'config.json' file:

        - "username": Your EduServe register number.
        - "password": EduServe password.
        - "stars": Number of stars for each feedback form.
        - "sharingLink": Your drive file sharing link.

   5. Press Windows + R and type ```%appdata%\Microsoft\Windows\Start Menu\Programs``` this opens a folder in explorer.
   6. Right click on the folder and click New -> Shortcut and click 'Browse'.
   7. Now navigate and select the main.exe file from the installed directory and click 'next' and then 'Finish'.
   8. Copy the file 'esM app.apk' to your mobile and install. And update the link in the mobile. **Procedure**: Copy the direct download link and paste it in the app in User ->Settings -> Update cloud link.

