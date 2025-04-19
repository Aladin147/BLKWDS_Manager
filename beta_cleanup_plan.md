# BLKWDS Manager - Beta Cleanup Plan

This document outlines the plan for cleaning up the BLKWDS Manager codebase before tagging the v1.0 Beta release.

## 1. Documentation Cleanup

### 1.1 Remove Unnecessary Documentation

- [x] Move all legacy documentation to the `docs/archived` directory
- [ ] Remove the `docs/archived` directory entirely
- [ ] Remove all documentation with "TODO", "WIP", or "Draft" in their titles
- [ ] Remove all implementation plans that have been completed
- [ ] Remove all audit documents that are no longer relevant

### 1.2 Clean Up Remaining Documentation

- [ ] Update `project_status.md` to reflect the beta status
- [ ] Update `README.md` to provide clear instructions for beta testers
- [ ] Ensure all user documentation is complete and accurate
- [ ] Remove any references to future features or plans that aren't part of the beta

## 2. Code Cleanup

### 2.1 Remove Deprecated and Legacy Code

- [ ] Remove all files with "V2" in their names (they've been consolidated)
- [ ] Remove all files with "adapter" in their names (they've been replaced)
- [ ] Remove all files with "legacy", "old", or "deprecated" in their names
- [ ] Remove the `scripts` directory (not needed for beta)
- [ ] Remove any test or mock data files

### 2.2 Clean Up Remaining Code

- [ ] Remove unused imports from all files
- [ ] Remove commented-out code
- [ ] Remove debug print statements
- [ ] Remove TODO comments
- [ ] Remove any feature flags or conditional code for features that are now standard

## 3. Asset Cleanup

- [ ] Remove any unused images, icons, or other assets
- [ ] Remove any placeholder assets
- [ ] Ensure all assets are properly optimized

## 4. Configuration Cleanup

- [ ] Update version number to 1.0.0-beta in all relevant files
- [ ] Remove any development-specific configuration
- [ ] Ensure all default settings are appropriate for beta testers

## 5. Testing

After each cleanup step:

1. Build the application to ensure it compiles
2. Run the application to ensure it launches
3. Test core functionality to ensure nothing is broken

## 6. Final Steps

- [ ] Update the changelog with a beta release entry
- [ ] Tag the repository with v1.0.0-beta
- [ ] Create a beta release on GitHub
- [ ] Prepare release notes for beta testers
