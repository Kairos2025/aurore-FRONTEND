pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Safe Flutter SDK path resolution
    val localProperties = file("../local.properties")
    if (localProperties.exists()) {
        val properties = java.util.Properties()
        localProperties.inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk")?.let { flutterSdkPath ->
            if (file("$flutterSdkPath/packages/flutter_tools/gradle").exists()) {
                includeBuild(flutterSdkPath + "/packages/flutter_tools/gradle")
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")
