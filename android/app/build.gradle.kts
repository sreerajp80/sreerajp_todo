import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
val releasePackagingTasks = listOf("assembleRelease", "bundleRelease", "packageRelease")
val isReleasePackagingBuild = gradle.startParameter.taskNames.any { taskName ->
    releasePackagingTasks.any { releaseTask -> taskName.contains(releaseTask, ignoreCase = true) }
}

if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

android {
    namespace = "in.sreerajp.sreerajp_todo"
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "in.sreerajp.sreerajp_todo"
        minSdk = flutter.minSdkVersion
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "environment"
        }
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                val keyAliasValue = keystoreProperties.getProperty("keyAlias")
                val keyPasswordValue = keystoreProperties.getProperty("keyPassword")
                val storeFileValue = keystoreProperties.getProperty("storeFile")
                val storePasswordValue = keystoreProperties.getProperty("storePassword")

                require(!keyAliasValue.isNullOrBlank()) { "key.properties is missing keyAlias." }
                require(!keyPasswordValue.isNullOrBlank()) { "key.properties is missing keyPassword." }
                require(!storeFileValue.isNullOrBlank()) { "key.properties is missing storeFile." }
                require(!storePasswordValue.isNullOrBlank()) {
                    "key.properties is missing storePassword."
                }

                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
                storeFile = file(storeFileValue)
                storePassword = storePasswordValue
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

if (isReleasePackagingBuild && !hasReleaseKeystore) {
    throw GradleException(
        "Missing Android release signing config. Create android/key.properties " +
            "and point it to the keystore before running a release build."
    )
}

