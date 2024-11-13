# kredit_pensiun_app

Kredit Pensiun mobile application.

## Prerequisites

- Flutter version >= 2.2.3

## How-To

### 1. How to Change Splash Screen
   
This application uses [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) for managing splash screen. All assets regarding splash screen are put into `assets/splash_screen` folder.

To change splash screen background color and image:

1. Open `pubspec.yaml`. In the `flutter_native_splash` section, update the `color` and `image` property respectively.
2. Run this command in the terminal:
   ```
   flutter pub run flutter_native_splash:create
   ```

### 2. How to Change Launcher Icon
   
This application uses [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) for managing launcher icon. All assets regarding launcher icons are put into `assets/launcher_icon` folder.

To change launcher icon images:

1. Open `flutter_launcher_icons.yaml` and update the properties accordingly.
2. Run this command in the terminal:
   ```
   flutter pub run flutter_launcher_icons:main
   ```

### 3. How to Build APK/App Bundle
   
The keystore file is located here: `android/app/keystore_pensiun_key.jks`. 
The keystore credentials can be seen here: `android/app/keystore_readme.txt`. 

Environment variable in config.dart.
Change the environment before build

To build APK/App Bundle:

1. Open terminal on the root folder of this project.
2. Run this command in the terminal to build APK: (The APK will be built in folder `build/app/outputs/apk/release`)
   ```
   flutter build apk
   ```
3. Run this command in the terminal to build App Bundle: (The APK will be built in folder `build/app/outputs/bundle/release`)
   ```
   flutter build appbundle
   ```
