pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Safe Flutter SDK path resolution
    val localProperties = file("../local.properties")
    if (localProperties.exists()) {
        properties.load(localProperties.inputStream())
        properties.getProperty("flutter.sdk")?.let { sdkPath ->
            val flutterToolsPath = file("$sdkPath/packages/flutter_tools/gradle")
            if (flutterToolsPath.exists()) {
                includeBuild(flutterToolsPath)
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")
