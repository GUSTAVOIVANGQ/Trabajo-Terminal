import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Release signing (Google Play upload key)
// Credentials are loaded from: android/key.properties (DO NOT commit it).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "mx.ipn.escom.flowcode"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("release") {
            // Values are validated below (afterEvaluate) only for Release tasks.
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "mx.ipn.escom.flowcode"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21  // Firebase requires minimum SDK 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        externalNativeBuild {
            cmake {
                arguments += listOf("-DANDROID_STL=none")
            }
        }
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    buildTypes {
        release {
            // Google Play Console rejects debug-signed bundles.
            signingConfig = signingConfigs.getByName("release")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }
}

// Fail fast if someone tries to build a Release artifact without proper signing.
// (Prevents producing a debug-signed .aab that Play Console will reject.)
afterEvaluate {
    val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
    if (!isReleaseTask) return@afterEvaluate

    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Missing android/key.properties. Create it (see android/key.properties.example) " +
                "and provide a valid upload keystore to build a release bundle."
        )
    }

    val storeFilePath = keystoreProperties.getProperty("storeFile")?.trim().orEmpty()
    val keyAlias = keystoreProperties.getProperty("keyAlias")?.trim().orEmpty()
    val storePassword = keystoreProperties.getProperty("storePassword")?.trim().orEmpty()
    val keyPassword = keystoreProperties.getProperty("keyPassword")?.trim().orEmpty()

    if (storeFilePath.isEmpty() || keyAlias.isEmpty() || storePassword.isEmpty() || keyPassword.isEmpty()) {
        throw GradleException(
            "android/key.properties is incomplete. Required keys: storeFile, storePassword, keyAlias, keyPassword."
        )
    }

    val ks = file(storeFilePath)
    if (!ks.exists()) {
        throw GradleException(
            "Keystore file not found: '${ks.absolutePath}'. Ensure storeFile points to your upload-keystore.jks."
        )
    }
}

flutter {
    source = "../.."
}

