# Aurore School App

A Flutter application for Aurore School management.

## Setup

1. Clone the repository:
   `ash
   git clone https://github.com/your-username/aurore-school.git
   ` 

2. Create ndroid/key.properties with your keystore details:
   ` 
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=your-key-alias
   storeFile=/path/to/your/keystore.jks
   ` 

3. Create ndroid/local.properties with your SDK paths:
   ` 
   flutter.sdk=/path/to/flutter
   sdk.dir=/path/to/android-sdk
   flutter.buildMode=release
   flutterVersionCode=2
   flutterVersionName=1.0.1
   flutter.minSdkVersion=23
   org.gradle.java.home=/path/to/jdk-17
   android.useAndroidX=true
   android.enableJetifier=true
   ` 

4. Run the app:
   `ash
   flutter pub get
   flutter run
   ` 

## Known Issues
- **NDK Mismatch**: Build fails with NDK 26.3.11579264 being reinstalled despite requiring 27.0.12077973.
- **minSdkVersion Conflict**: irebase_auth requires minSdkVersion 23, but build detects 21.

See build logs for details and ongoing debugging efforts.
