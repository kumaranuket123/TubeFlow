import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: create android/key.properties (git-ignored) with
// storeFile, storePassword, keyAlias, keyPassword. See docs/RELEASE.md.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.crn.tubeflow"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.crn.tubeflow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Pinned (not flutter.minSdkVersion's default) because TubeFlow relies
        // on MediaStore/scoped-storage behavior that requires Android 10+.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Used by flutter_appauth to register the OAuth redirect receiver.
        // Must match kOAuthRedirectScheme in lib/core/config/env.dart, and be
        // updated in lockstep (plus a new Android OAuth client registration
        // in Google Cloud Console) if applicationId ever changes.
        manifestPlaceholders["appAuthRedirectScheme"] =
            "com.googleusercontent.apps.45915931754-oggc6tn5ip85teautmh0g7v00s7frbds"
    }

    signingConfigs {
        if (keystoreProperties.containsKey("storeFile")) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Uses the release keystore when key.properties exists; otherwise
            // falls back to debug signing so local `--release` runs still work.
            // Never publish a debug-signed build.
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                // Debug-signed release builds are only allowed for local runs.
                // Pass -PallowDebugSigning=true for a local test build; anything
                // else fails so a debug-signed build can't be shipped.
                if (!project.hasProperty("allowDebugSigning")) {
                    gradle.taskGraph.whenReady {
                        if (allTasks.any { it.name.contains("Release") && (it.name.startsWith("assemble") || it.name.startsWith("bundle")) }) {
                            throw GradleException(
                                "android/key.properties is missing: refusing to build a debug-signed release. " +
                                    "See docs/RELEASE.md, or pass -PallowDebugSigning=true for a local test build."
                            )
                        }
                    }
                }
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
