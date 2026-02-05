# Submodule Integration Guide

This guide explains how to integrate the `copilot-instructions` repository as a git submodule into your project, along with best practices and common workflows.

## Table of Contents

- [Why Use as a Submodule?](#why-use-as-a-submodule)
- [Initial Setup](#initial-setup)
- [Directory Structure](#directory-structure)
- [GitHub Copilot Configuration](#github-copilot-configuration)
- [Team Workflows](#team-workflows)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## Why Use as a Submodule?

**Benefits:**
- ✅ **Version Control**: Pin specific versions of instructions for reproducibility
- ✅ **Easy Updates**: Pull latest best practices with a single command
- ✅ **Consistency**: Use same instructions across multiple projects
- ✅ **Team Collaboration**: Organization fork allows team customizations
- ✅ **Git History**: Track when instruction versions changed in your project

**When NOT to use:**
- ❌ If you need heavy customization (consider forking instead)
- ❌ For one-off projects that won't benefit from updates
- ❌ If team is unfamiliar with git submodules

## Initial Setup

### Step 1: Add Submodule

```bash
# Navigate to your project root
cd /path/to/your/project

# Add submodule
git submodule add https://github.com/yourusername/copilot-instructions.git .github/copilot-instructions

# Expected output:
# Cloning into '/path/to/your/project/.github/copilot-instructions'...
# remote: Enumerating objects: ...
```

This creates:
- `.gitmodules` file with submodule configuration
- `.github/copilot-instructions/` directory with the submodule content

### Step 2: Create Symlink or Direct Reference

**Option A: Symlink (For Small Projects)**

GitHub Copilot looks for `.github/copilot-instructions.md`. Create a symlink:

```bash
cd .github
ln -s copilot-instructions/copilot-instructions.md copilot-instructions.md

# Verify symlink
ls -la copilot-instructions.md
# Should show: copilot-instructions.md -> copilot-instructions/copilot-instructions.md
```

**Windows (PowerShell as Administrator):**
```powershell
cd .github
New-Item -ItemType SymbolicLink -Path "copilot-instructions.md" -Target "copilot-instructions\copilot-instructions.md"
```

**Option B: Domain-Specific Instructions (Recommended for Large Projects)**

To avoid response timeouts with large instruction files, symlink directly to domain-specific instructions:

```bash
cd .github

# For backend-focused projects
ln -s copilot-instructions/instructions/backend.instructions.md copilot-instructions.md

# For web-focused projects
ln -s copilot-instructions/instructions/web.instructions.md copilot-instructions.md

# For ops/infrastructure projects
ln -s copilot-instructions/instructions/ops.instructions.md copilot-instructions.md

# For scripting projects
ln -s copilot-instructions/instructions/scripting.instructions.md copilot-instructions.md
```

**Option C: Lightweight Orchestrator (Best for Mixed Projects)**

Create a custom lightweight orchestrator that loads only what you need:

```bash
cat > .github/copilot-instructions.md << 'EOF'
# Project-Specific Copilot Instructions

## Active Domains
<!-- Only include domains actively used in this project -->

### Backend
[Include: copilot-instructions/instructions/backend.instructions.md]

<!-- Uncomment only when working on these areas:
### Web Frontend
[Include: copilot-instructions/instructions/web.instructions.md]

### Infrastructure
[Include: copilot-instructions/instructions/ops.instructions.md]
-->
EOF
```

### Step 3: Commit Changes

```bash
git add .gitmodules .github/copilot-instructions .github/copilot-instructions.md
git commit -m "Add Copilot instructions as submodule with symlink"
git push
```

## Directory Structure

After setup, your project structure should look like:

```
your-project/
├── .git/
├── .gitmodules                        # Submodule configuration
├── .github/
│   ├── copilot-instructions/          # Submodule (separate git repo)
│   │   ├── .git                       # Submodule's git directory
│   │   ├── copilot-instructions.md    # Main orchestrator
│   │   ├── instructions/              # Domain-specific instructions
│   │   ├── examples/                  # Code examples
│   │   └── README.md
│   ├── copilot-instructions.md        # Symlink → copilot-instructions/copilot-instructions.md
│   └── workflows/                     # Your CI/CD workflows
├── src/
└── README.md
```

**Key Points:**
- The submodule is a separate git repository inside your project
- The symlink allows Copilot to find the main file automatically
- All paths within the submodule remain relative

## GitHub Copilot Configuration

### Automatic Loading

With the symlink in place, GitHub Copilot automatically loads instructions:

1. **File Detection**: Copilot loads `.github/copilot-instructions.md`
2. **Symlink Resolution**: Follows symlink to submodule content
3. **Relative Paths**: All references to `instructions/` and `examples/` work correctly

### Verification

To verify Copilot is loading instructions:

1. Open a file that matches an `applyTo` pattern (e.g., `src/main.py`)
2. Start typing a function definition
3. Copilot suggestions should follow the instruction patterns (type hints, docstrings, etc.)

### Custom Project Instructions

To add project-specific customizations:

**Option A: Extend in parent project**
```bash
# Create project-specific instructions
cat > .github/project-instructions.md << 'EOF'
# Project-Specific Instructions

## Custom Conventions
- Database: PostgreSQL 15 with AsyncPG
- Authentication: JWT with Redis sessions
- API Style: REST with OpenAPI 3.1

[Rest of your customizations...]
EOF
```

Then reference in your code or IDE settings.

**Option B: Fork and Customize**

For teams with significant customizations:
1. Fork this repository to your organization
2. Add team-specific standards
3. Use your fork as the submodule source

## Team Workflows

### Scenario 1: Organization with Multiple Projects

**Setup:**

1. **Fork to Organization**
   ```bash
   # On GitHub: Fork yourusername/copilot-instructions → yourorg/copilot-instructions
   ```

2. **Customize Fork**
   ```bash
   git clone https://github.com/yourorg/copilot-instructions.git
   cd copilot-instructions
   
   # Add team standards
   vim copilot-instructions.md  # Add team-specific section
   
   git commit -am "Add team conventions"
   git push
   
   # Tag release
   git tag -a v1.0.0 -m "Team standards v1.0.0"
   git push --tags
   ```

3. **Add to All Projects**
   ```bash
   # In each project
   git submodule add https://github.com/yourorg/copilot-instructions.git .github/copilot-instructions
   ```

### Scenario 2: Updating Team Instructions

When you update your organization's fork:

```bash
# Update fork with new team standards
cd copilot-instructions
git commit -am "Update Python standards to 3.12"
git tag -a v1.1.0 -m "Python 3.12 standards"
git push --tags

# Update in each project
cd /path/to/project1
git submodule update --remote .github/copilot-instructions
git add .github/copilot-instructions
git commit -m "Update to copilot-instructions v1.1.0"

# Repeat for other projects
```

**Automation Script** (`scripts/update-copilot-all.sh`):
```bash
#!/bin/bash
set -euo pipefail

PROJECTS=(
    "project-alpha"
    "project-beta"
    "project-gamma"
)

INSTRUCTION_VERSION="${1:-latest}"

for project in "${PROJECTS[@]}"; do
    echo "==> Updating $project"
    cd "$project"
    
    git checkout main
    git pull
    
    cd .github/copilot-instructions
    if [[ "$INSTRUCTION_VERSION" == "latest" ]]; then
        git pull origin main
    else
        git checkout "$INSTRUCTION_VERSION"
    fi
    cd ../..
    
    git add .github/copilot-instructions
    git commit -m "Update Copilot instructions to $INSTRUCTION_VERSION"
    git push
    
    cd ..
done

echo "✅ All projects updated"
```

Usage:
```bash
# Update all to latest
./scripts/update-copilot-all.sh

# Update all to specific version
./scripts/update-copilot-all.sh v1.1.0
```

### Scenario 3: Syncing with Upstream

If your organization fork wants community improvements:

```bash
cd copilot-instructions

# Add upstream (one-time)
git remote add upstream https://github.com/original/copilot-instructions.git
git fetch upstream

# Review upstream changes
git log HEAD..upstream/main

# Merge or rebase
git merge upstream/main
# Or: git rebase upstream/main

# Resolve conflicts if any
git push origin main

# Create new team release
git tag -a v1.2.0 -m "Merge upstream improvements"
git push --tags
```

## CI/CD Integration

### Ensuring Submodules in CI

Most CI systems need explicit submodule initialization:

**GitHub Actions:**
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive  # Initialize submodules
      
      - name: Verify Copilot Instructions
        run: |
          test -f .github/copilot-instructions/copilot-instructions.md
          echo "✅ Copilot instructions loaded"
      
      # Rest of your CI steps...
```

**GitLab CI:**
```yaml
variables:
  GIT_SUBMODULE_STRATEGY: recursive

test:
  script:
    - test -f .github/copilot-instructions/copilot-instructions.md
    - echo "✅ Copilot instructions loaded"
```

**Jenkins:**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    extensions: [[$class: 'SubmoduleOption', 
                                  recursiveSubmodules: true]]
                ])
            }
        }
    }
}
```

### Pre-commit Hooks

Ensure submodules are updated before commit:

**.git/hooks/pre-commit:**
```bash
#!/bin/bash

echo "Checking submodule status..."

# Check if submodule is up to date
if ! git submodule status | grep -q '^-'; then
    echo "✅ Submodules OK"
    exit 0
fi

echo "❌ Submodules not initialized!"
echo "Run: git submodule update --init --recursive"
exit 1
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Troubleshooting

### Issue: Submodule Directory Empty

**Symptoms:** `.github/copilot-instructions/` exists but is empty

**Solution:**
```bash
git submodule init
git submodule update
```

### Issue: Detached HEAD in Submodule

**Symptoms:** `cd .github/copilot-instructions && git status` shows "HEAD detached at..."

**Explanation:** Submodules check out specific commits, not branches

**Solution (if you want to track a branch):**
```bash
cd .github/copilot-instructions
git checkout main
cd ../..
git add .github/copilot-instructions
git commit -m "Update submodule to track main branch"
```

### Issue: Submodule Changes Not Appearing

**Symptoms:** Updated submodule but changes not visible in project

**Solution:**
```bash
# In project root
git submodule update --remote --merge
git add .github/copilot-instructions
git commit -m "Update submodule"
```

### Issue: Conflicts During Submodule Update

**Symptoms:** Merge conflicts in `.github/copilot-instructions` during git pull

**Solution:**
```bash
# Accept remote version
git checkout --theirs .github/copilot-instructions
git add .github/copilot-instructions

# Or accept local version
git checkout --ours .github/copilot-instructions
git add .github/copilot-instructions

# Continue merge/rebase
git merge --continue
# Or: git rebase --continue
```

### Issue: Response Timeouts / Slow Copilot Performance

**Symptoms:** 
- Copilot suggestions are slow or timeout
- "Copilot is not responding" errors
- Long wait times for code completions

**Root Cause:** The full instruction file is too large for Copilot to process efficiently

**Solutions:**

1. **Use Domain-Specific Instructions** (Recommended):
   ```bash
   cd .github
   # Remove full orchestrator symlink
   rm copilot-instructions.md
   
   # Link to specific domain only
   ln -s copilot-instructions/instructions/backend.instructions.md copilot-instructions.md
   ```

2. **Create Minimal Custom Orchestrator**:
   ```bash
   cat > .github/copilot-instructions.md << 'EOF'
   # Minimal Copilot Instructions
   
   ## Core Principles
   - TDD: Write tests first
   - Security: Validate inputs, no hardcoded secrets
   - Quality: Functions < 50 lines, classes < 300 lines
   
   ## Domain Instructions
   For detailed standards, see:
   - Backend: .github/copilot-instructions/instructions/backend.instructions.md
   - Web: .github/copilot-instructions/instructions/web.instructions.md
   - Ops: .github/copilot-instructions/instructions/ops.instructions.md
   EOF
   ```

3. **Rotate Instructions by Context**:
   ```bash
   # Script to switch instruction sets
   cat > scripts/switch-copilot-context.sh << 'EOF'
   #!/bin/bash
   CONTEXT=$1
   cd .github
   rm -f copilot-instructions.md
   
   case $CONTEXT in
     backend)
       ln -s copilot-instructions/instructions/backend.instructions.md copilot-instructions.md
       ;;
     web)
       ln -s copilot-instructions/instructions/web.instructions.md copilot-instructions.md
       ;;
     ops)
       ln -s copilot-instructions/instructions/ops.instructions.md copilot-instructions.md
       ;;
     *)
       echo "Usage: $0 {backend|web|ops}"
       exit 1
       ;;
   esac
   echo "✅ Switched to $CONTEXT instructions"
   EOF
   
   chmod +x scripts/switch-copilot-context.sh
   
   # Usage
   ./scripts/switch-copilot-context.sh backend
   ```

4. **Split Work Sessions**:
   - Work on one domain at a time (backend, then frontend, then ops)
   - Switch instruction files between sessions
   - Keep context focused and manageable

### Issue: Symlink Not Working on Windows

**Symptoms:** Copilot not loading instructions on Windows

**Solutions:**

1. **Enable Developer Mode** (Windows 10+):
   - Settings → Update & Security → For Developers → Developer Mode

2. **Use Git Config**:
   ```bash
   git config --global core.symlinks true
   ```

3. **Alternative: Copy Instead of Symlink**:
   ```bash
   # In .github/
   cp copilot-instructions/copilot-instructions.md copilot-instructions.md
   
   # Note: Must manually update when submodule updates
   ```

### Issue: Removing Submodule

**Complete Removal:**
```bash
# Deinitialize
git submodule deinit -f .github/copilot-instructions

# Remove from git
git rm -f .github/copilot-instructions

# Remove submodule directory from .git
rm -rf .git/modules/.github/copilot-instructions

# Remove symlink if exists
rm .github/copilot-instructions.md

# Commit
git commit -m "Remove Copilot instructions submodule"
```

## Advanced Topics

### Shallow Clones

For faster clones with less history:

```bash
# Add with shallow clone
git submodule add --depth 1 https://github.com/yourorg/copilot-instructions.git .github/copilot-instructions

# Update shallow
git submodule update --remote --depth 1
```

Add to `.gitmodules`:
```ini
[submodule ".github/copilot-instructions"]
    path = .github/copilot-instructions
    url = https://github.com/yourorg/copilot-instructions.git
    shallow = true
```

### Multiple Submodules

If using multiple instruction repositories:

```bash
git submodule add https://github.com/org/copilot-backend.git .github/copilot-backend
git submodule add https://github.com/org/copilot-frontend.git .github/copilot-frontend

# Aggregate in main instructions
cat > .github/copilot-instructions.md << 'EOF'
# Aggregate Instructions

- Backend: See [copilot-backend/](copilot-backend/)
- Frontend: See [copilot-frontend/](copilot-frontend/)
EOF
```

### Submodule in Monorepo

For monorepos, place at root or per package:

```bash
# Root level (shared across all packages)
git submodule add https://github.com/org/copilot.git .github/copilot-instructions

# Per package
packages/
├── frontend/
│   └── .github/copilot-instructions/  # Submodule
└── backend/
    └── .github/copilot-instructions/  # Submodule
```

## Best Practices Summary

✅ **DO:**
- **Use domain-specific instructions** to avoid timeouts (backend.instructions.md, web.instructions.md, etc.)
- **Start small**: Link to one instruction file first, add more as needed
- **Rotate contexts**: Switch instruction files based on current work domain
- Use symlinks for Copilot auto-detection
- Pin specific versions/tags for production projects
- Document submodule version in project README
- Initialize submodules in CI/CD
- Tag releases in your organization fork
- Sync with upstream periodically for community improvements
- **Monitor performance**: If Copilot slows down, reduce instruction file size

❌ **DON'T:**
- **Load all instructions at once** if you experience timeouts
- **Use the full orchestrator** for large projects (causes performance issues)
- Make direct edits in submodule (do it in the source repo)
- Commit submodule changes without updating parent
- Forget to document submodule version requirements
- Use `--recursive` blindly if you have nested submodules you don't need

## Additional Resources

- [Git Submodules Official Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub: Working with Submodules](https://github.blog/2016-02-01-working-with-submodules/)
- [Pro Git Book: Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

---

**Questions or Issues?**
- Open an issue in the main repository
- Check existing issues for common problems
- Contribute improvements to this guide
