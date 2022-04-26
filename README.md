# Slots-finder
Slots Finder is an application for 42 Students.
It allows the students to find correction slots to review their projects.<br />
The app will search for a slot of a given project and send you a notification once found. You are then able to set the slot directly from the app.


# Requirement
- Flutter

# Compatibility
Work on `Android` and `IoS`.

# ⚠️ You need to provide your own secret_uid
Use [https://profile.intra.42.fr/oauth/applications](https://profile.intra.42.fr/oauth/applications) to create your App Token. <br />
The Redirect Url must be localhost. The needed scope is "public".<br />
Then go to [lib/credentials.dart](./lib/credentials.dart) and set your CLIENT_UID, CLIENT_SECRET and AUTHORIZE_URL (see below REDIRECT URL).<br />
# Usage
```
flutter run
```

# How does it work
The app will ask you authorization to use your account (access your public data). <br />
When accepted, the app will get and store the cookie you generated from the webview (it is needed to do intranet API call). The app will also generate the oauth2 token from the code you generated (that is needed to do 42 API call). <br />
From the 42 API, the app will get all your projects set as "waiting for correction" and list them. <br /><br />
When you select a project, the app will send a request every 30s to the intranet API to find available slots for your project. <br />
Once one is found, the app will send you a notification. <br />
You will then be able to select the the slot you want to set.<br />
The intranet being protected by x-csrf, the app will generate a webview of 5x5 pixels that will simulate a user interaction to fill the form/validation.

# Issue
Despite being developped with Flutter, it is not compatible for Web, Microsoft or Mac version. <br />
The app need your intranet cookie to be able to use the intranet API. The webview library I use isn't compatible with Mac/Windows. <br />
I tried to use iFrame for Web version, saddly there is a security protection that block me from getting the cookie from a Cross Origin url.
# Demo
![Gif demo](<img src="https://raw.githubusercontent.com/LudovicLemaire/Slots-finder/main/github_assets/demo.gif" height="600" width="300">)