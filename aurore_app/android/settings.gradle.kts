
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Proper Flutter SDK detection
    val flutterSdkPath = file("../flutter").absolutePath.also {
        require(it.isNotEmpty()) { "Flutter SDK not found at ../flutter" }
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "aurore_app"
include(":app")

