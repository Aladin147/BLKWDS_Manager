# Changelog Management

This document provides guidelines for managing the BLKWDS Manager changelog.

## Overview

The changelog is a crucial part of our documentation that helps track changes to the codebase over time. It provides a chronological list of notable changes for each version of the application.

## Changelog Structure

Our changelog follows the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format with some modifications to avoid Markdown linting issues:

1. **Version Header**: Each version has a header in the format `## [1.0.0-rcXX] - YYYY-MM-DD`
2. **Categories**: Changes are grouped into categories using bold text instead of Markdown headings:
   - **Added**: New features or components
   - **Fixed**: Bug fixes
   - **Improved**: Enhancements to existing features
   - **Changed**: Changes in existing functionality

## Updating the Changelog

### Manual Update

1. Open `changelog.md` in your editor
2. Add a new version section at the top of the file using the template from `docs/templates/changelog_template.md`
3. Fill in the details for each category
4. Save the file and commit the changes

### Using the Update Script

We provide a script to help with updating the changelog:

```bash
dart scripts/update_changelog.dart
```

This script will:
1. Read the current changelog
2. Extract the latest version number
3. Create a new version entry with the next version number and today's date
4. Insert the new entry at the top of the changelog
5. Save the file

After running the script, you'll need to:
1. Fill in the details for each category
2. Save the file and commit the changes

## Best Practices

1. **Be Concise**: Keep entries brief but descriptive
2. **Use Past Tense**: Use past tense for verbs (e.g., "Added", "Fixed", "Improved", "Changed")
3. **Group Related Changes**: Keep related changes together
4. **Prioritize**: List the most important changes first
5. **Be Consistent**: Follow the established format and style
6. **Update Regularly**: Update the changelog as part of your commit process, not as an afterthought
7. **Never Modify Previous Versions**: Once a version is released, its changelog entries should not be modified

## Avoiding Common Issues

1. **Duplicate Headings**: We use bold text for categories instead of Markdown headings to avoid duplicate heading warnings from Markdown linters
2. **Inconsistent Formatting**: Use the template to ensure consistent formatting
3. **Missing Information**: Make sure to include all notable changes
4. **Too Much Detail**: The changelog should be readable and focused on notable changes, not every single commit

## Template

See `docs/templates/changelog_template.md` for a template to use when updating the changelog.
