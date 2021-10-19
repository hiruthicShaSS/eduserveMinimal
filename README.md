# eduserveMinimal

Minimalist app for eduserve

![Preview](screenshots/preview.png)

[![Website][website-shield]][website-url]

<div id="download">
<a href='https://play.google.com/store/apps/details?id=com.hiruthicShaBuilds.eduserveMinimal&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width=50%></a>

For non-programming iOS users, follow these steps:

1. Throw your iphone out of the window and buy a android device then [download](#download).

OR

1. Download and install the flutter SDK
2. Compile it yourself. [_Process_](#compile)

## Start Building

<div id="compile">
   
1. ### Clone the repo

```bash
git clone --recurse-submodules https://github.com/hiruthicShaSS/eduserveMinimal.git
git checkout mobile_app
```

2. ### Build app

   ```bash
   flutter pub get
   flutter build apk
   ```

   - Platform specific:

     ```bash
     flutter build apk --target-platform "your platform"
     ```

   - Append '--release' or '--debug' for release app or debug app respectively.
   - More: [Build Flutter app](https://flutter.dev/docs/deployment/android)

## Screenshots

![Home Page](screenshots/screenshot1.png)
![Student Page](screenshots/screenshot2.png)
![Fees Page](screenshots/screenshot3.png)
![Hall Ticket Page](screenshots/screenshot4.png)
![Dark Theme](screenshots/screenshot5.png)

[website-url]: https://hiruthicshass.github.io/eduserveMinimal/
[website-shield]: https://img.shields.io/website?label=GitHub%20Pages&style=for-the-badge&url=https://hiruthicshass.github.io/eduserveMinimal/
