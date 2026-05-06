#!/bin/bash
# =============================================================================
#  github_setup.sh — Initialize and push to GitHub
#  Usage: ./github_setup.sh <your-github-username>
# =============================================================================

set -euo pipefail

REPO_NAME="backup-and-cleanup-script"
USERNAME="${1:-}"

if [[ -z "${USERNAME}" ]]; then
    echo "Usage: $0 <github-username>"
    echo "Example: $0 johndoe"
    exit 1
fi

REPO_URL="https://github.com/${USERNAME}/${REPO_NAME}.git"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitHub Repository Setup"
echo "  Repo : ${REPO_URL}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Create project directory
mkdir -p "${REPO_NAME}"
cd "${REPO_NAME}"

# Step 2: Copy files into place
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/backup_cleanup.sh" .
cp "${SCRIPT_DIR}/README.md" .
chmod +x backup_cleanup.sh

# Step 3: Create .gitignore
cat > .gitignore <<'EOF'
# Logs
logs/
*.log
*.log.gz

# Lock file
*.lock

# OS noise
.DS_Store
Thumbs.db
EOF

# Step 4: Initialise Git repo
git init
git add .
git commit -m "feat: initial commit — automated backup & disk cleanup script

- Timestamped compressed backups with tar+gzip
- SHA-256 checksum sidecar for every archive
- Configurable retention (--days) and cleanup age (--cleanup-days)
- Structured log with monthly rotation
- Dry-run mode, backup-only, cleanup-only flags
- Lock file prevents concurrent runs
- Disk space pre-check before backup"

# Step 5: Set default branch to main
git branch -M main

echo ""
echo "  ✅ Local repository initialised."
echo ""
echo "  Next steps:"
echo "  1. Create the repo on GitHub:"
echo "     https://github.com/new  →  name it '${REPO_NAME}'"
echo ""
echo "  2. Push:"
echo "     git remote add origin ${REPO_URL}"
echo "     git push -u origin main"
echo ""
