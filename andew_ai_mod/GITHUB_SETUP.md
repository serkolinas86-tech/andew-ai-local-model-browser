# GitHub Setup Instructions for Andew AI Local - Model Browser

## 📋 Prerequisites
1. GitHub account
2. GitHub CLI (`gh`) installed OR use GitHub web interface
3. Personal Access Token with `repo` scope (you already have this!)

## 🚀 Step-by-Step Setup

### 1. Install GitHub CLI (on your machine)
```bash
# Windows (via winget)
winget install --id GitHub.cli

# Or download from: https://cli.github.com/
```

### 2. Login to GitHub
```bash
gh auth login
# Choose: GitHub.com → HTTPS → Login with token
# Paste your token: ghp_eQ...YacY (the one with repo scope)
```

### 3. Create Repository & Push Code
```bash
cd /c/Users/user/AppData/Local/hermes/workspace/andew_ai_mod
gh repo create andew-ai-local-model-browser --public --source=. --push
```

### 4. Add GitHub Secrets (REQUIRED for signing)

Go to: `https://github.com/YOUR_USERNAME/andew-ai-local-model-browser/settings/secrets/actions`

**Add these 3 Repository Secrets:**

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `KEYSTORE_BASE64` | Base64 encoded keystore file | Run `generate_keystore.sh` locally, copy output |
| `KEYSTORE_PASSWORD` | `andewai123` | From generate_keystore.sh output |
| `KEY_PASSWORD` | `andewai123` | From generate_keystore.sh output |

**To generate keystore locally:**
```bash
cd /c/Users/user/AppData/Local/hermes/workspace/andew_ai_mod
chmod +x generate_keystore.sh
./generate_keystore.sh
# Copy the base64 output to KEYSTORE_BASE64 secret
```

### 5. Trigger Build

**Option A: Automatic (on push)**
```bash
git add .
git commit -m "Trigger build"
git push
```

**Option B: Manual with Model (via GitHub UI)**
1. Go to: `https://github.com/YOUR_USERNAME/andew-ai-local-model-browser/actions`
2. Click "Build & Sign APK" workflow
3. Click "Run workflow"
4. Fill in:
   - `model_url`: Direct download link to your GGUF model (e.g., Hugging Face)
   - `model_name`: `mllm-7b-q4_k_m.gguf`
5. Click "Run workflow"

### 6. Download Signed APK

After workflow completes (~10-15 minutes):
1. Go to Actions → Latest run
2. Click "andew-ai-local-signed-apk" artifact
3. Download `app-debug-aligned.apk` (optimized) or `app-debug-signed.apk`

### 7. Install on Z Fold 6
```bash
adb install -r app-debug-aligned.apk
```

---

## 📁 Project Files Ready
All files are in: `/c/Users/user/AppData/Local/hermes/workspace/andew_ai_mod/`

Key files:
- `.github/workflows/build-apk.yml` - GitHub Actions workflow
- `generate_keystore.sh` - Generates keystore for signing
- `app/src/main/...` - Complete Android project with Model Browser

---

## 🔗 Alternative: Use GitHub Web Interface

If you prefer not to use CLI:

1. **Create repo on GitHub.com** → `andew-ai-local-model-browser`
2. **Upload files** → Drag & drop the `andew_ai_mod` folder contents
3. **Add Secrets** → Settings → Secrets and variables → Actions
4. **Run Workflow** → Actions → Build & Sign APK → Run workflow