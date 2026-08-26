#!/bin/bash
# Integration Patch Script
# This script shows how to patch the existing Andew AI APK to add Model Browser
# Run on a machine with: apktool, aapt2, apksigner, zipalign

set -e

ORIGINAL_APK="$1"
OUTPUT_APK="$2"

if [ -z "$ORIGINAL_APK" ] || [ -z "$OUTPUT_APK" ]; then
    echo "Usage: $0 <original.apk> <output.apk>"
    echo "Example: $0 AndewAI_Local_ZFold6_RC8_APK.zip AndewAI_With_ModelBrowser.apk"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

WORK_DIR=$(mktemp -d)
echo -e "${GREEN}Working in: $WORK_DIR${NC}"

# Step 1: Decode APK with apktool
echo -e "${YELLOW}1. Decoding APK...${NC}"
apktool d "$ORIGINAL_APK" -o "$WORK_DIR/decoded" -f

# Step 2: Add ModelBrowserActivity to AndroidManifest.xml
echo -e "${YELLOW}2. Patching AndroidManifest.xml...${NC}"
MANIFEST="$WORK_DIR/decoded/AndroidManifest.xml"

# Add activity before </application>
sed -i '/<\/application>/i \
        <activity\n            android:name=".model.ModelBrowserActivity"\n            android:exported="false"\n            android:theme="@style/Theme.AndewAI"\n            android:windowSoftInputMode="adjustResize" />' "$MANIFEST"

# Add permissions if not present
if ! grep -q "READ_EXTERNAL_STORAGE" "$MANIFEST"; then
    sed -i '/<uses-permission android:name="android.permission.INTERNET" \/>/a \
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />\n\
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />\n\
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" tools:ignore="ScopedStorage" />' "$MANIFEST"
fi

# Step 3: Add Model Browser menu to MainActivity
echo -e "${YELLOW}3. Adding menu resource...${NC}"
MENU_DIR="$WORK_DIR/decoded/res/menu"
mkdir -p "$MENU_DIR"

cat > "$MENU_DIR/main_menu.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/action_model_browser"
        android:title="@string/model_browser_title"
        android:icon="@drawable/ic_model"
        app:showAsAction="ifRoom|withText" />
    <item
        android:id="@+id/action_settings"
        android:title="@string/settings"
        app:showAsAction="never" />
    <item
        android:id="@+id/action_about"
        android:title="@string/about"
        app:showAsAction="never" />
</menu>
EOF

# Step 4: Add strings
echo -e "${YELLOW}4. Adding string resources...${NC}"
STRINGS_FILE="$WORK_DIR/decoded/res/values/strings.xml"
if [ ! -f "$STRINGS_FILE" ]; then
    # Find the correct strings file
    STRINGS_FILE=$(find "$WORK_DIR/decoded/res" -name "strings.xml" | head -1)
fi

if [ -f "$STRINGS_FILE" ]; then
    # Add strings before </resources>
    sed -i '/<\/resources>/i \
    <string name="model_browser_title">Model Browser</string>\n\
    <string name="import_model">Import Model</string>\n\
    <string name="select_model">Select Model</string>\n\
    <string name="delete_model">Delete Model</string>\n\
    <string name="model_active">ACTIVE</string>\n\
    <string name="model_available">Available</string>\n\
    <string name="no_models">No models found. Tap + to import a GGUF model.</string>\n\
    <string name="import_success">Model imported successfully</string>\n\
    <string name="import_failed">Import failed: %s</string>\n\
    <string name="model_selected">Model switched: %s</string>\n\
    <string name="model_deleted">Model deleted</string>\n\
    <string name="permission_storage_rationale">Storage permission needed to import models</string>\n\
    <string name="models_folder">Models</string>\n\
    <string name="settings">Settings</string>\n\
    <string name="about">About</string>' "$STRINGS_FILE"
fi

# Step 5: Add drawable resources (ic_model, ic_add)
echo -e "${YELLOW}5. Adding drawable resources...${NC}"
DRAWABLE_DIR="$WORK_DIR/decoded/res/drawable"
mkdir -p "$DRAWABLE_DIR"

cat > "$DRAWABLE_DIR/ic_model.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
    <path
        android:fillColor="@android:color/white"
        android:pathData="M12,4.5C7,4.5 2.73,7.61 1,12c1.73,4.39 6,7.5 11,7.5s9.27,-3.11 11,-7.5C21.27,7.61 17,4.5 12,4.5zM12,17c-3.87,0 -7,-2.47 -7,-5.5s3.13,-5.5 7,-5.5 7,2.47 7,5.5 -3.13,5.5 -7,5.5zM12,9c-1.66,0 -3,1.34 -3,3s1.34,3 3,3 3,-1.34 3,-3 -1.34,-3 -3,-3z"/>
</vector>
EOF

cat > "$DRAWABLE_DIR/ic_add.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnSecondary">
    <path
        android:fillColor="@android:color/white"
        android:pathData="M19,13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
</vector>
EOF

# Step 6: Add layout files
echo -e "${YELLOW}6. Adding layout files...${NC}"
LAYOUT_DIR="$WORK_DIR/decoded/res/layout"
mkdir -p "$LAYOUT_DIR"

cat > "$LAYOUT_DIR/activity_model_browser.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background">

    <com.google.android.material.appbar.AppBarLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:theme="@style/ThemeOverlay.AppCompat.Dark.ActionBar">

        <androidx.appcompat.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="?attr/colorPrimary"
            app:popupTheme="@style/ThemeOverlay.AppCompat.Light" />
    </com.google.android.material.appbar.AppBarLayout>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/modelRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="16dp"
        android:clipToPadding="false"
        app:layout_behavior="@string/appbar_scrolling_view_behavior" />

    <com.google.android.material.floatingactionbutton.FloatingActionButton
        android:id="@+id/fabImport"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|end"
        android:layout_margin="16dp"
        android:src="@drawable/ic_add"
        android:contentDescription="Import Model"
        android:backgroundTint="@color/colorAccent" />
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$LAYOUT_DIR/item_model.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"
    android:elevation="4dp"
    app:cardCornerRadius="12dp"
    app:cardElevation="4dp"
    app:cardBackgroundColor="@color/surface">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="16dp"
        android:gravity="center_vertical">

        <ImageView
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:src="@drawable/ic_model"
            android:contentDescription="Model icon"
            android:layout_marginEnd="16dp" />

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:layout_marginEnd="16dp">

            <TextView
                android:id="@+id/modelNameText"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Model Name"
                android:textSize="16sp"
                android:textStyle="bold"
                android:textColor="@color/onSurface" />

            <TextView
                android:id="@+id/modelStatusText"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Available"
                android:textSize="12sp"
                android:textColor="@color/onSurfaceVariant" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center_vertical">

            <Button
                android:id="@+id/selectBtn"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:text="Select"
                android:textSize="12sp"
                android:textAllCaps="false"
                android:paddingHorizontal="16dp"
                style="@style/Widget.MaterialComponents.Button.OutlinedButton" />

            <Button
                android:id="@+id/deleteBtn"
                android:layout_width="wrap_content"
                android:layout_height="36dp"
                android:layout_marginStart="8dp"
                android:text="Delete"
                android:textSize="12sp"
                android:textAllCaps="false"
                android:paddingHorizontal="16dp"
                style="@style/Widget.MaterialComponents.Button.OutlinedButton" />
        </LinearLayout>
    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

# Step 7: Add color/theme resources (if not using Material3)
echo -e "${YELLOW}7. Adding color/theme resources...${NC}"
VALUES_DIR="$WORK_DIR/decoded/res/values"
mkdir -p "$VALUES_DIR"

# Check if colors.xml exists
if [ ! -f "$VALUES_DIR/colors.xml" ]; then
    cat > "$VALUES_DIR/colors.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="colorPrimary">#6750A4</color>
    <color name="colorPrimaryVariant">#4F378B</color>
    <color name="colorOnPrimary">#FFFFFF</color>
    <color name="colorSecondary">#006C4C</color>
    <color name="colorSecondaryVariant">#00533C</color>
    <color name="colorOnSecondary">#FFFFFF</color>
    <color name="colorError">#BA1A1A</color>
    <color name="colorOnError">#FFFFFF</color>
    <color name="colorBackground">#FFFBFE</color>
    <color name="colorOnBackground">#1C1B1F</color>
    <color name="colorSurface">#FFFBFE</color>
    <color name="colorOnSurface">#1C1B1F</color>
    <color name="colorSurfaceVariant">#E7E0EC</color>
    <color name="colorOnSurfaceVariant">#49454F</color>
    <color name="colorOutline">#79747E</color>
    <color name="colorOutlineVariant">#CAC4D0</color>
    <color name="colorPrimaryContainer">#EADDFF</color>
    <color name="colorOnPrimaryContainer">#21005D</color>
    <color name="colorSecondaryContainer">#A7F0D0</color>
    <color name="colorOnSecondaryContainer">#002115</color>
</resources>
EOF
fi

# Step 8: Add ModelBrowserActivity smali (this is the hard part - need to compile Kotlin to smali)
echo -e "${YELLOW}8. Adding ModelBrowserActivity smali...${NC}"
echo -e "${RED}NOTE: You need to compile ModelBrowserActivity.kt and ModelBrowserAdapter.kt to smali${NC}"
echo "Options:"
echo "  a) Compile with kotlinc + dx/d8, then add smali files"
echo "  b) Use Android Studio to build the module, then extract classes.dex"
echo "  c) Build the full project with Gradle (recommended)"

# Step 9: Rebuild APK
echo -e "${YELLOW}9. Rebuilding APK...${NC}"
apktool b "$WORK_DIR/decoded" -o "$WORK_DIR/unsigned.apk"

# Step 10: Sign APK
echo -e "${YELLOW}10. Signing APK...${NC}"
KEYSTORE="$WORK_DIR/andew_ai.keystore"
if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair -alias andew_ai -keyalg RSA -keysize 2048 -validity 10000 \
        -keystore "$KEYSTORE" -storepass "andewai123" -keypass "andewai123" \
        -dname "CN=Andew AI, OU=Development, O=Andew AI, L=City, ST=State, C=US" -noprompt
fi

apksigner sign --ks "$KEYSTORE" --ks-pass pass:andewai123 --key-pass pass:andewai123 \
    --out "$OUTPUT_APK" "$WORK_DIR/unsigned.apk"

zipalign -f 4 "$OUTPUT_APK" "$OUTPUT_APK.aligned"
mv "$OUTPUT_APK.aligned" "$OUTPUT_APK"

# Cleanup
rm -rf "$WORK_DIR"

echo -e "${GREEN}=== Done! Output: $OUTPUT_APK ===${NC}"
echo "Install with: adb install -r $OUTPUT_APK"