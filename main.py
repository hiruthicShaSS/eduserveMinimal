import os
import time
import socket
import datetime
import json

from eduserve import EduServe


eduserve = EduServe()
eduserve.login()  # Login to eduserve
eduserve.fetch()  # Fetch data
eduserve.finish()  # Close browser instance
