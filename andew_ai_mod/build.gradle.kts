// Top-level build file
plugins {
    id 'com.android.application' version '8.2.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.20' apply false
}

android {
    namespace 'com.andew.ailocal'
    compileSdk 35

    defaultConfig {
        applicationId "com.andew.ailocal"
        minSdk 28
        targetSdk 35
        versionCode 12
        versionName "1.0.0-rc8-model-browser"
        
        // Enable multidex for large DEX count
        multiDexEnabled true
        
        // Vector drawable support
        vectorDrawables.useSupportLibrary = true
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.debug
        }
        debug {
            debuggable true
            signingConfig signingConfigs.debug
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
        freeCompilerArgs += ['-Xopt-in=kotlin.RequiresOptIn']
    }

    buildFeatures {
        viewBinding true
        compose true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = '1.5.10'
    }

    packagingOptions {
        resources {
            excludes += '/META-INF/{AL2.0,LGPL2.1,LICENSE,NOTICE}'
        }
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.activity:activity-ktx:1.8.2'
    implementation 'androidx.fragment:fragment-ktx:1.6.2'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0'
    
    // Compose BOM
    implementation platform('androidx.compose:compose-bom:2024.02.00')
    implementation 'androidx.compose.ui:ui'
    implementation 'androidx.compose.ui:ui-graphics'
    implementation 'androidx.compose.ui:ui-tooling-preview'
    implementation 'androidx.compose.material3:material3'
    implementation 'androidx.compose.runtime:runtime-livedata'
    implementation 'androidx.compose.runtime:runtime-rxjava2'
    
    // Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3'
    
    // Serialization for model config
    implementation 'org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0'
    
    // File I/O
    implementation 'com.google.code.gson:gson:2.10.1'
    
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}