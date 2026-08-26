#!/bin/bash
# Build script for Andew AI Local with Model Browser
# Run this on a machine with Android SDK installed

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/build_output"
ANDROID_SDK="$ANDROID_HOME"  # Set this to your Android SDK path

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Andew AI Local - Model Browser Build Script ===${NC}"
echo "Project: $PROJECT_DIR"
echo "Android SDK: $ANDROID_SDK"

# Check Android SDK
if [ -z "$ANDROID_SDK" ] || [ ! -d "$ANDROID_SDK" ]; then
    echo -e "${RED}Error: ANDROID_HOME not set or invalid${NC}"
    echo "Please set ANDROID_HOME to your Android SDK path"
    echo "Example: export ANDROID_HOME=/path/to/android-sdk"
    exit 1
fi

# Find build tools
BUILD_TOOLS_DIR=$(find "$ANDROID_SDK/build-tools" -maxdepth 1 -type d | sort -V | tail -1)
if [ ! -d "$BUILD_TOOLS_DIR" ]; then
    echo -e "${RED}Error: No build tools found in $ANDROID_SDK/build-tools${NC}"
    exit 1
fi

AAPT2="$BUILD_TOOLS_DIR/aapt2"
APKSIGNER="$BUILD_TOOLS_DIR/apksigner"
ZIPALIGN="$BUILD_TOOLS_DIR/zipalign"
PLATFORM_JAR=$(find "$ANDROID_SDK/platforms" -name "android-*.jar" | sort -V | tail -1)

echo "Using build tools: $BUILD_TOOLS_DIR"
echo "Using platform: $PLATFORM_JAR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Compile resources with aapt2
echo -e "${YELLOW}Step 1: Compiling resources...${NC}"
"$AAPT2" compile \
    --dir "$PROJECT_DIR/src/main/res" \
    -o "$OUTPUT_DIR/compiled_res.zip"

# Step 2: Link resources
echo -e "${YELLOW}Step 2: Linking resources...${NC}"
"$AAPT2" link \
    -o "$OUTPUT_DIR/app.apk" \
    -I "$PLATFORM_JAR" \
    --manifest "$PROJECT_DIR/src/main/AndroidManifest.xml" \
    -R "$OUTPUT_DIR/compiled_res.zip" \
    --auto-add-overlay \
    --java "$OUTPUT_DIR/generated_sources" \
    --proguard-main-dex "$OUTPUT_DIR/proguard_main_dex.txt" \
    --no-version-vectors

# Step 3: Compile Kotlin/Java sources (requires kotlinc and javac)
echo -e "${YELLOW}Step 3: Compiling Kotlin sources...${NC}"
# This requires kotlinc and kotlin-stdlib
# For now, we'll create a placeholder - you'll need to compile with Gradle or Android Studio

echo -e "${YELLOW}Note: Kotlin compilation requires Gradle or Android Studio${NC}"
echo "For full build, use Android Studio or run:"
echo "  cd $PROJECT_DIR && ./gradlew assembleDebug"

# Step 4: Create keystore for signing (if not exists)
KEYSTORE="$PROJECT_DIR/andew_ai.keystore"
if [ ! -f "$KEYSTORE" ]; then
    echo -e "${YELLOW}Step 4: Creating keystore...${NC}"
    keytool -genkeypair \
        -alias andew_ai \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -keystore "$KEYSTORE" \
        -storepass "andewai123" \
        -keypass "andewai123" \
        -dname "CN=Andew AI, OU=Development, O=Andew AI, L=City, ST=State, C=US" \
        -noprompt
fi

# Step 5: Sign APK (after full build with classes.dex)
echo -e "${YELLOW}Step 5: To sign the final APK, run:${NC}"
echo "$APKSIGNER sign --ks $KEYSTORE --ks-pass pass:andewai123 --key-pass pass:andewai123 --out $OUTPUT_DIR/app-signed.apk $OUTPUT_DIR/app-unsigned.apk"
echo "$ZIPALIGN -f 4 $OUTPUT_DIR/app-signed.apk $OUTPUT_DIR/app-aligned.apk"

echo -e "${GREEN}=== Build preparation complete ===${NC}"
echo "Next steps:"
echo "1. Open project in Android Studio"
echo "2. Build > Build Bundle(s) / APK(s) > Build APK(s)"
echo "3. Or run: ./gradlew assembleDebug"
echo "4. Install: adb install -r app/build/outputs/apk/debug/app-debug.apk"