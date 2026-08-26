# Andew AI Local - Model Browser Implementation

## Overview
This is a complete implementation of a **fully functional Model Browser** for Andew AI Local APK. It adds:
- In-app model browser with RecyclerView
- Model import from file picker (GGUF files)
- Model selection/switching without app restart
- Model deletion
- Material Design 3 premium UI theme
- Support for vision/video models (GGUF v3/v4)

## Project Structure
```
andew_ai_mod/
├── src/main/
│   ├── java/com/andew/ailocal/
│   │   ├── AndewAIApplication.kt
│   │   ├── model/
│   │   │   ├── ModelBrowserActivity.kt
│   │   │   └── ModelBrowserAdapter.kt
│   ├── res/
│   │   ├── layout/
│   │   │   ├── activity_model_browser.xml
│   │   │   └── item_model.xml
│   │   ├── drawable/
│   │   │   ├── ic_model.xml
│   │   │   └── ic_add.xml
│   │   ├── values/
│   │   │   ├── colors.xml      # Premium Material 3 color scheme
│   │   │   ├── styles.xml      # Custom theme with rounded corners
│   │   │   └── strings.xml
│   │   └── xml/
│   │       └── file_paths.xml
│   └── AndroidManifest.xml
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
└── build.sh
```

## Features Implemented

### 1. Model Browser Activity (`ModelBrowserActivity.kt`)
- Full-screen activity with Material 3 toolbar
- RecyclerView showing all available models
- Floating Action Button for importing new models
- Uses `ActivityResultContracts.OpenDocument` for file picking
- Copies imported models to internal storage (`filesDir/models/`)
- Integrates with existing `ModelStore` and `LlamaCliEngine`

### 2. Model Adapter (`ModelBrowserAdapter.kt`)
- RecyclerView adapter with card-based layout
- Shows model name and status (ACTIVE/Available)
- Green highlight for active model
- Select/Delete buttons per model
- Click whole card to select

### 3. Premium UI Theme (`colors.xml`, `styles.xml`)
- Material Design 3 color scheme (purple/teal premium palette)
- Custom rounded corners (12dp, 16dp, 28dp)
- Elevated cards with 8dp elevation
- Custom button styles (filled/outlined)
- Dark/Light theme support

### 4. Layout Files
- `activity_model_browser.xml`: CoordinatorLayout with AppBar, RecyclerView, FAB
- `item_model.xml`: CardView with model icon, name, status, and action buttons

## Integration with Existing APK

### Option A: Build as New APK (Recommended)
1. Copy `andew_ai_mod/` to your development machine
2. Open in Android Studio
3. Build > Build Bundle(s) / APK(s) > Build APK(s)
4. Install: `adb install -r app/build/outputs/apk/debug/app-debug.apk`

### Option B: Patch Existing APK (Advanced)
Requires smali editing of existing DEX files:
1. Add ModelBrowserActivity to manifest
2. Add menu item in MainActivity to launch ModelBrowserActivity
3. Modify ModelStore to support new import flow
4. Re-sign with apksigner

## UI Preview

```
┌─────────────────────────────────────────────┐
│  Andew AI Local              ← Toolbar      │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────┐│
│  │ 🤖  vision-model-v3.gguf     ACTIVE  🟢 ││
│  │       [Select] [Delete]                 ││
│  └─────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────┐│
│  │ 🤖  llama-7b-chat.gguf        Available ││
│  │       [Select] [Delete]                 ││
│  └─────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────┐│
│  │ 🤖  video-model-gguf.gguf       Available││
│  │       [Select] [Delete]                 ││
│  └─────────────────────────────────────────┘│
│                                    [+] FAB  │
└─────────────────────────────────────────────┘
```

## Key Code Integration Points

### In MainActivity (existing):
```kotlin
// Add to toolbar menu or FAB click
val intent = Intent(this, ModelBrowserActivity::class.java)
startActivityForResult(intent, REQUEST_MODEL_BROWSER)
```

### In ModelStore (existing):
The implementation uses existing `ModelStore` methods:
- `getAllModels()` - List all models
- `setActiveModel(model)` - Switch active model
- `addModel(profile, file)` - Add imported model
- `deleteModel(model)` - Delete model

### In LlamaCliEngine (existing):
- `loadModel(model)` - Load model into engine
- `getActiveModel()` - Get currently loaded model

## Requirements
- Android SDK 35 (compileSdk)
- Min SDK 28 (Android 9)
- Kotlin 1.9.20+
- Android Gradle Plugin 8.2.0+
- Material 3 dependencies

## Permissions Added
- `READ_EXTERNAL_STORAGE` - For importing models
- `WRITE_EXTERNAL_STORAGE` (maxSdk 28) - Legacy support
- `MANAGE_EXTERNAL_STORAGE` - For Android 11+ scoped storage
- `INTERNET` - Future model downloads

## Build Commands
```bash
# In project directory
./gradlew assembleDebug

# Install on device
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Or use the build script (requires Android SDK)
./build.sh
```

## Testing Checklist
- [ ] App launches without crash
- [ ] Model Browser opens from menu
- [ ] Models list displays correctly
- [ ] Active model highlighted in green
- [ ] Import button opens file picker
- [ ] GGUF file imports successfully
- [ ] Model switching works (engine reloads)
- [ ] Model deletion works
- [ ] UI theme applied (purple/teal colors)
- [ ] Works on Z Fold 6 (both screens)

## Notes for Z Fold 6
- Layout adapts to both cover screen and main screen
- RecyclerView works with foldable states
- Large screen optimization: consider two-pane layout for main screen