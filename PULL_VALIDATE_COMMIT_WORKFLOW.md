# Pull-Validate-Commit Workflow

## Overview

The Pull-Validate-Commit workflow is an automated process that:
1. **Pulls** the latest updates from the main branch
2. **Validates** the system state to ensure everything is working properly
3. **Auto-commits** any changes with a detailed commit message

This workflow ensures continuous integration and maintains code quality without manual intervention.

---

## Quick Start

### Using npm script (Recommended)
```bash
npm run workflow:pull-validate-commit
```

### Direct execution
```bash
bash scripts/pull-validate-commit.sh
```

---

## What It Does

### 1. Pull from Main Branch
- Fetches all updates from the remote repository
- Attempts to merge the main branch into the current branch
- Logs all git operations for audit purposes

### 2. System Validation

The workflow performs comprehensive validation checks:

#### Project Structure
- Verifies existence of critical directories: `src/`, `scripts/`, `agents/`, `config/`, `contracts/`

#### Critical Files
- Checks for essential files: `package.json`, `tsconfig.json`, `README.md`
- Validates JSON syntax in `package.json`

#### Environment
- Verifies Node.js and npm are installed and accessible
- Reports version numbers for both

#### Dependencies
- Checks if `node_modules` directory exists
- Automatically installs dependencies if missing
- Reports the number of installed packages

#### TypeScript Compilation
- Runs TypeScript compiler in no-emit mode (`tsc --noEmit`)
- Reports any compilation errors without blocking the workflow

#### Git Repository Status
- Checks for uncommitted changes
- Reports the number of modified files

### 3. Auto-Commit

If changes are detected:
- Stages all changes (`git add -A`)
- Creates a commit with a detailed message including:
  - Timestamp
  - Workflow steps executed
  - Validation status
  - Number of changed files
- Reports the commit hash

---

## Output and Logging

### Console Output
The script provides color-coded console output:
- **Cyan**: Headers and informational sections
- **Blue**: Step indicators
- **Green**: Success messages
- **Yellow**: Warnings
- **Red**: Errors

### Log File
Every run creates a timestamped log file in the `logs/` directory:
```
logs/pull_validate_commit_YYYYMMDD_HHMMSS.log
```

The log file contains:
- All console output
- Git command outputs
- Validation results
- Commit details

---

## Exit Codes

- **0**: Workflow completed successfully (even with warnings)
- **1**: Critical error occurred (rare, only for severe failures)

Note: The workflow is designed to be resilient and will complete even if some non-critical validations fail.

---

## Integration with CI/CD

### GitHub Actions
Add to your workflow file:
```yaml
- name: Pull, Validate, and Commit
  run: npm run workflow:pull-validate-commit
```

### Cron Job
Run automatically every hour:
```bash
0 * * * * cd /path/to/project && npm run workflow:pull-validate-commit
```

---

## Example Output

```
======================================================================
  PULL-VALIDATE-COMMIT WORKFLOW
  Timestamp: Fri Dec 12 21:50:10 UTC 2025
======================================================================

[2025-12-12 21:50:10] [INFO] Starting pull-validate-commit workflow
[2025-12-12 21:50:10] [INFO] Project root: /path/to/project
[2025-12-12 21:50:10] [INFO] Log file: /path/to/logs/pull_validate_commit_20251212_215010.log

[STEP 1] Pulling updates from main branch...
[2025-12-12 21:50:10] [INFO] Current branch: copilot/review-terminal-pull-request
[2025-12-12 21:50:10] [SUCCESS] Fetch completed successfully
[2025-12-12 21:50:10] [SUCCESS] Merge from main completed successfully

[STEP 2] Validating system state...
[2025-12-12 21:50:10] [SUCCESS] ✓ Directory exists: src
[2025-12-12 21:50:10] [SUCCESS] ✓ Directory exists: scripts
[2025-12-12 21:50:10] [SUCCESS] ✓ File exists: package.json
[2025-12-12 21:50:10] [SUCCESS] ✓ package.json is valid JSON
[2025-12-12 21:50:10] [SUCCESS] ✓ Node.js available: v20.19.6
[2025-12-12 21:50:10] [SUCCESS] ✓ npm available: 10.8.2
[2025-12-12 21:50:10] [SUCCESS] ✓ node_modules exists with 1234 packages

[STEP 3] Auto-committing changes...
[2025-12-12 21:50:34] [SUCCESS] ✓ Commit created successfully
[2025-12-12 21:50:34] [SUCCESS] ✓ Commit hash: a121dac

======================================================================
  WORKFLOW SUMMARY
======================================================================
[2025-12-12 21:50:34] [INFO] Workflow completed
[2025-12-12 21:50:34] [INFO] Validation status: PASSED
✓ All validations passed
```

---

## Customization

### Adding Custom Validations

Edit `scripts/pull-validate-commit.sh` and add your validation in Step 2:

```bash
# Validation X: Your custom check
log "INFO" "Running custom validation..."
if [ your_condition ]; then
    log "SUCCESS" "✓ Custom validation passed"
else
    log "ERROR" "✗ Custom validation failed"
    VALIDATION_PASSED=false
fi
```

### Changing Commit Message Format

Modify the `COMMIT_MSG` variable in Step 3 of the script.

---

## Troubleshooting

### Issue: Dependencies fail to install
**Solution**: Check your internet connection and npm registry access. You may need to configure a proxy.

### Issue: TypeScript compilation errors
**Solution**: This is logged as a warning. Fix TypeScript errors in your code and run the workflow again.

### Issue: Git merge conflicts
**Solution**: The script will report conflicts. Resolve them manually and re-run the workflow.

### Issue: Permission denied
**Solution**: Ensure the script is executable:
```bash
chmod +x scripts/pull-validate-commit.sh
```

---

## Related Workflows

- **Autonomous Agent**: `npm run autonomous:full-cycle`
  - Comprehensive system analysis, diagnosis, and healing
  
- **Auto Validation Agent**: `pwsh scripts/auto_validation_agent.ps1`
  - Deep system validation with enterprise index checks

- **Deployment Verification**: `pwsh validate-deployment.ps1`
  - Production deployment validation

---

## Best Practices

1. **Run regularly**: Integrate into your daily workflow or CI/CD pipeline
2. **Review logs**: Check log files periodically for trends or recurring issues
3. **Commit frequently**: The workflow works best with small, frequent changes
4. **Test first**: Ensure your code is tested before running the workflow
5. **Branch strategy**: Use feature branches and merge to main regularly

---

## Security Considerations

- The workflow automatically stages and commits all changes
- Review the changes before pushing to remote
- Consider adding a review step before auto-pushing to main
- Log files may contain sensitive information - ensure they're git-ignored

---

## Support

For issues or questions:
1. Check the log files in `logs/` directory
2. Review this documentation
3. Consult the main `README.md` for project-wide information
4. Check related workflow documentation

---

**Built for Infinity X One Systems - Real Estate Intelligence Platform**
