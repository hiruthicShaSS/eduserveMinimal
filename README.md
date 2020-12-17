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

    *This create's a file called 'datadump.json' which contains the eduserve data.*
    - Uplodad this file to your [Google Drive](https://drive.google.com/drive/u/0/my-drive)
    - Right click on the uploaded file and click 'Get link' and change the access to 'Anyone with the link' and copy the link.
    - Paste the sharing link on the value of 'sharingLink' key in 'config.json' file.
    - [Generate](https://sites.google.com/site/gdocs2direct/home) direct download link.
    - Copy the direct download link and paste it in the app in User -> Settings -> Update cloud link.
