import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.JavaVersion
import org.gradle.jvm.toolchain.JavaLanguageVersion

// Load key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    kotlin("android")
    id("org.jetbrains.kotlin.plugin.compose") // Version is inherited from project-level
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    
}

android {
    namespace = "com.amrabdelhameed.ella_lyaabdoon"
    compileSdk = 36

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "2.1.0" // Match Kotlin version
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.amrabdelhameed.ella_lyaabdoon"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

signingConfigs {
    create("release") {
        storeFile = file(
            keystoreProperties["storeFile"] as String
        )
        storePassword = keystoreProperties["storePassword"] as String
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
    }
}


 buildTypes {
        release {
            isMinifyEnabled = true               // Enable R8 shrinking
            isShrinkResources = true             // Enable resource shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release") // Use release signing
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // Core Glance & AppWidget functionality
// Add these here:
    implementation("androidx.glance:glance:1.1.0")
    implementation("androidx.glance:glance-appwidget:1.1.0")
    implementation("androidx.glance:glance-material3:1.1.0")
    
    // REMOVE the glance-state line as it's not being found.
    // implementation("androidx.glance:glance-state:1.1.0") 

    // Unit support (dp)
    implementation("androidx.compose.ui:ui-unit:1.7.0")

    // Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    implementation("com.google.firebase:firebase-messaging")
    // Google Play In-App Review (new modular libraries)
    // DO NOT include play:core or play:core-ktx - they conflict with these
    implementation("com.google.android.play:review:2.0.2")
    implementation("com.google.android.play:review-ktx:2.0.2")

    // Exclude old firebase-iid
    configurations.all {
        exclude(group = "com.google.firebase", module = "firebase-iid")
    }
}

// Java toolchain
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

// Kotlin JDK toolchain
kotlin {
    jvmToolchain(17)
}
