plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.waqty_user_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ⚠ **مطلوب لـ`flutter_local_notifications`.**
        //
        // المكتبة بتستخدم `java.time` وهي موجودة من API 26،
        // والأبلكيشن بيدعم أقل من كده. الـdesugaring بيخلّي Gradle يولّد
        // بدائل للأجهزة القديمة بدل ما نرفع `minSdk`.
        //
        // رفع `minSdk` كان هيقطع أجهزة من السوق عشان إشعارات —
        // مقايضة غلط في سوق زي مصر.
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.waqty_user_application"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // بدائل مكتبة جافا الأساسية للأجهزة القديمة — شوف
    // `isCoreLibraryDesugaringEnabled` فوق.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
