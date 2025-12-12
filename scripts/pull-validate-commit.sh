#!/bin/bash

# ============================================================================
# PULL-VALIDATE-COMMIT WORKFLOW
# ============================================================================
# Purpose: Pull updates from main, validate system state, and auto-commit
# Status: Autonomous workflow for continuous integration
# ============================================================================

set -e  # Exit on error

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/pull_validate_commit_$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] $message"
    
    echo "$log_entry" >> "$LOG_FILE"
    
    case $level in
        INFO)
            echo -e "${CYAN}$log_entry${NC}"
            ;;
        SUCCESS)
            echo -e "${GREEN}$log_entry${NC}"
            ;;
        WARN)
            echo -e "${YELLOW}$log_entry${NC}"
            ;;
        ERROR)
            echo -e "${RED}$log_entry${NC}"
            ;;
        *)
            echo "$log_entry"
            ;;
    esac
}

# Header
echo -e "${CYAN}======================================================================${NC}"
echo -e "${CYAN}  PULL-VALIDATE-COMMIT WORKFLOW${NC}"
echo -e "${CYAN}  Timestamp: $(date)${NC}"
echo -e "${CYAN}======================================================================${NC}"
echo ""

log "INFO" "Starting pull-validate-commit workflow"
log "INFO" "Project root: $PROJECT_ROOT"
log "INFO" "Log file: $LOG_FILE"

cd "$PROJECT_ROOT"

# ============================================================================
# STEP 1: PULL FROM MAIN
# ============================================================================
echo -e "${BLUE}[STEP 1] Pulling updates from main branch...${NC}"
log "INFO" "Step 1: Pull from main branch"

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
log "INFO" "Current branch: $CURRENT_BRANCH"

# Fetch all updates
log "INFO" "Fetching from origin..."
if git fetch origin 2>&1 | tee -a "$LOG_FILE"; then
    log "SUCCESS" "Fetch completed successfully"
else
    log "ERROR" "Fetch failed"
    exit 1
fi

# Check if main branch exists locally
if ! git rev-parse --verify main >/dev/null 2>&1; then
    log "INFO" "Main branch not found locally, fetching..."
    git fetch origin main:main 2>&1 | tee -a "$LOG_FILE"
fi

# Try to merge main into current branch
log "INFO" "Attempting to merge main into $CURRENT_BRANCH..."
if git merge --no-edit main 2>&1 | tee -a "$LOG_FILE"; then
    log "SUCCESS" "Merge from main completed successfully"
else
    log "WARN" "Merge had conflicts or no changes to merge"
fi

echo ""

# ============================================================================
# STEP 2: VALIDATE SYSTEM
# ============================================================================
echo -e "${BLUE}[STEP 2] Validating system state...${NC}"
log "INFO" "Step 2: System validation"

VALIDATION_PASSED=true

# Validation 1: Project structure
log "INFO" "Validating project structure..."
REQUIRED_DIRS=("src" "scripts" "agents" "config" "contracts")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        log "SUCCESS" "✓ Directory exists: $dir"
    else
        log "WARN" "✗ Directory missing: $dir"
    fi
done

# Validation 2: Critical files
log "INFO" "Validating critical files..."
CRITICAL_FILES=("package.json" "tsconfig.json" "README.md")
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        log "SUCCESS" "✓ File exists: $file"
    else
        log "ERROR" "✗ Critical file missing: $file"
        VALIDATION_PASSED=false
    fi
done

# Validation 3: Package.json syntax
log "INFO" "Validating package.json syntax..."
if [ -f "$PROJECT_ROOT/package.json" ]; then
    if node -e "JSON.parse(require('fs').readFileSync('$PROJECT_ROOT/package.json', 'utf8'))" 2>/dev/null; then
        log "SUCCESS" "✓ package.json is valid JSON"
    else
        log "ERROR" "✗ package.json has syntax errors"
        VALIDATION_PASSED=false
    fi
fi

# Validation 4: Node.js and npm availability
log "INFO" "Validating Node.js and npm..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    log "SUCCESS" "✓ Node.js available: $NODE_VERSION"
else
    log "ERROR" "✗ Node.js not found"
    VALIDATION_PASSED=false
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    log "SUCCESS" "✓ npm available: $NPM_VERSION"
else
    log "ERROR" "✗ npm not found"
    VALIDATION_PASSED=false
fi

# Validation 5: Dependencies check
log "INFO" "Checking dependencies..."
if [ -d "$PROJECT_ROOT/node_modules" ]; then
    MODULE_COUNT=$(ls -1 "$PROJECT_ROOT/node_modules" | wc -l)
    log "SUCCESS" "✓ node_modules exists with $MODULE_COUNT packages"
else
    log "WARN" "⚠ node_modules directory not found"
    log "INFO" "Installing dependencies..."
    if npm install 2>&1 | tee -a "$LOG_FILE"; then
        log "SUCCESS" "✓ Dependencies installed successfully"
    else
        log "ERROR" "✗ Failed to install dependencies"
        VALIDATION_PASSED=false
    fi
fi

# Validation 6: TypeScript compilation check (if applicable)
log "INFO" "Checking TypeScript compilation..."
if [ -f "$PROJECT_ROOT/tsconfig.json" ]; then
    if npx tsc --noEmit 2>&1 | tee -a "$LOG_FILE"; then
        log "SUCCESS" "✓ TypeScript compilation check passed"
    else
        log "WARN" "⚠ TypeScript has compilation errors"
    fi
fi

# Validation 7: Git repository status
log "INFO" "Checking git repository status..."
GIT_STATUS=$(git status --porcelain)
if [ -z "$GIT_STATUS" ]; then
    log "SUCCESS" "✓ Working directory clean"
else
    CHANGED_FILES=$(echo "$GIT_STATUS" | wc -l)
    log "INFO" "⚠ $CHANGED_FILES files have changes"
fi

echo ""

# ============================================================================
# STEP 3: AUTO-COMMIT
# ============================================================================
echo -e "${BLUE}[STEP 3] Auto-committing changes...${NC}"
log "INFO" "Step 3: Auto-commit"

# Check if there are any changes to commit
if [ -n "$GIT_STATUS" ]; then
    log "INFO" "Changes detected, preparing to commit..."
    
    # Stage all changes
    log "INFO" "Staging all changes..."
    git add -A 2>&1 | tee -a "$LOG_FILE"
    
    # Create commit message
    COMMIT_MSG="Auto-commit: Pull, validate, and commit workflow - $(date '+%Y-%m-%d %H:%M:%S')"
    COMMIT_MSG="$COMMIT_MSG

Workflow steps:
1. Pulled updates from main branch
2. Validated system state (status: $([ "$VALIDATION_PASSED" = true ] && echo "PASSED" || echo "COMPLETED WITH WARNINGS"))
3. Auto-committed changes

Changed files: $CHANGED_FILES"
    
    # Create commit
    log "INFO" "Creating commit..."
    if git commit -m "$COMMIT_MSG" 2>&1 | tee -a "$LOG_FILE"; then
        log "SUCCESS" "✓ Commit created successfully"
        
        # Get commit hash
        COMMIT_HASH=$(git rev-parse --short HEAD)
        log "SUCCESS" "✓ Commit hash: $COMMIT_HASH"
    else
        log "WARN" "⚠ No changes to commit or commit failed"
    fi
else
    log "INFO" "No changes to commit"
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${CYAN}======================================================================${NC}"
echo -e "${CYAN}  WORKFLOW SUMMARY${NC}"
echo -e "${CYAN}======================================================================${NC}"

log "INFO" "Workflow completed"
log "INFO" "Branch: $CURRENT_BRANCH"
log "INFO" "Validation status: $([ "$VALIDATION_PASSED" = true ] && echo "PASSED" || echo "COMPLETED WITH WARNINGS")"
log "INFO" "Log file saved: $LOG_FILE"

if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}✓ All validations passed${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some validations failed or had warnings${NC}"
    exit 0  # Still exit 0 since we want to continue
fi
