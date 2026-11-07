import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fft_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.fft_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Load signing properties
    val keyPropsFile = rootProject.file("key.properties")
    val keyProps = if (keyPropsFile.exists()) {
        val props = Properties()
        props.load(keyPropsFile.inputStream())
        props
    } else null

    signingConfigs {
        if (keyProps != null) {
            create("release") {
                storeFile = file(keyProps["storeFile"] as String)
                storePassword = keyProps["storePassword"] as String
                keyAlias = keyProps["keyAlias"] as String
                keyPassword = keyProps["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Configure release signing if key.properties exists with all required fields
            val storeFile = keyProps?.get("storeFile") as String?
            val storePassword = keyProps?.get("storePassword") as String?
            val keyAlias = keyProps?.get("keyAlias") as String?
            val keyPassword = keyProps?.get("keyPassword") as String?

            if (storeFile != null && storePassword != null && keyAlias != null && keyPassword != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// PRODUCTION RELEASE SIGNING POLICY ENFORCEMENT:
// Add validation to assembleRelease task to block builds without valid keystore
// Use afterEvaluate to ensure task exists
afterEvaluate {
    tasks.matching { it.name == "assembleRelease" }.configureEach {
        doFirst {
            val keyPropsFile = rootProject.file("key.properties")
            val keyProps = if (keyPropsFile.exists()) {
                val props = Properties()
                props.load(keyPropsFile.inputStream())
                props
            } else null

            val storeFile = keyProps?.get("storeFile") as String?
            val storePassword = keyProps?.get("storePassword") as String?
            val keyAlias = keyProps?.get("keyAlias") as String?
            val keyPassword = keyProps?.get("keyPassword") as String?

            if (storeFile == null || storePassword == null || keyAlias == null || keyPassword == null) {
                throw GradleException(
                    "PRODUCTION RELEASE BLOCKED: key.properties missing or incomplete.\n" +
                    "Create android/key.properties with valid production keystore credentials.\n" +
                    "Debug builds (flutter build apk --debug) are unaffected.\n" +
                    "Example template: android/key.properties.example"
                )
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}