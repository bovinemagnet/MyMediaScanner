import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.paulsnow.mymediascanner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.paulsnow.mymediascanner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "MyMedia (Dev)")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "MyMediaScanner")
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            // Sign with the upload keystore when android/key.properties exists.
            // Locally we fall back to debug keys so `flutter run --release`
            // still works, but on CI a missing keystore is a hard error — a
            // debug-signed artefact would be rejected by Play and is worse
            // than a failed build.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else if (System.getenv("CI") != null) {
                throw GradleException(
                    "Release build on CI without android/key.properties. " +
                        "Set the ANDROID_KEYSTORE_* secrets — see docs/PLAY_STORE_RELEASE.md."
                )
            } else {
                logger.warn(
                    "WARNING: android/key.properties not found — signing the release " +
                        "build with DEBUG keys. This artefact cannot be uploaded to Play."
                )
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Required by flutter_local_notifications (uses java.time on minSdk < 26).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // ML Kit optional language models referenced by google_mlkit_text_recognition
    // but not bundled — needed to satisfy R8 missing class checks.
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
    implementation("com.google.mlkit:text-recognition-korean:16.0.1")
}

flutter {
    source = "../.."
}
