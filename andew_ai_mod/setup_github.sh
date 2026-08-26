#!/bin/bash
# GitHub Setup & Push Script for Andew AI Local
# Run this on YOUR machine (not in this environment)

set -e

echo "=== Andew AI Local - GitHub Setup Script ==="
echo

# Check if we're in the right directory
if [ ! -f "build.gradle.kts" ] || [ ! -d ".github/workflows" ]; then
    echo "❌ Error: Run this from the andew_ai_mod directory"
    echo "   cd /c/Users/user/AppData/Local/hermes/workspace/andew_ai_mod"
    exit 1
fi

# Check gh CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found"
    echo "   Install: winget install --id GitHub.cli"
    echo "   Or download: https://cli.github.com/"
    exit 1
fi

# Check gh auth
if ! gh auth status &> /dev/null; then
    echo "🔐 Logging into GitHub..."
    gh auth login
fi

# Get GitHub username
GITHUB_USER=$(gh api user --jq .login)
echo "✅ Logged in as: $GITHUB_USER"

# Create repo
REPO_NAME="andew-ai-local-model-browser"
echo "📦 Creating repository: $REPO_NAME"
gh repo create "$REPO_NAME" --public --source=. --push

# Generate keystore
echo
echo "🔑 Generating keystore for signing..."
chmod +x generate_keystore.sh
./generate_keystore.sh

echo
echo "=== NEXT STEPS ==="
echo "1. Go to: https://github.com/$GITHUB_USER/$REPO_NAME/settings/secrets/actions"
echo "2. Add these 3 Repository Secrets:"
echo "   - KEYSTORE_BASE64  (copy from generate_keystore.sh output above)"
echo "   - KEYSTORE_PASSWORD  (value: andewai123)"
echo "   - KEY_PASSWORD  (value: andewai123)"
echo
echo "3. Trigger build:"
echo "   - Auto: git push (already done by --push)"
echo "   - Manual: gh workflow run build-apk.yml -f model_url='YOUR_MODEL_URL' -f model_name='mllm-7b-q4_k_m.gguf'"
echo
echo "4. Download APK from Actions artifacts after build completes"
echo
echo "✅ Setup complete!"