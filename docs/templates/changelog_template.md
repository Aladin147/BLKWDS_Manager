# Changelog Template

When updating the changelog, use this template to ensure consistent formatting and avoid duplicate heading issues.

## New Version Template

```markdown
## [1.0.0-rcXX] - YYYY-MM-DD

**Added:**
- Feature or component that was added
- Another feature or component that was added

**Fixed:**
- Issue that was fixed
- Another issue that was fixed

**Improved:**
- Component or feature that was improved
- Another component or feature that was improved

**Changed:**
- Component or feature that was changed
- Another component or feature that was changed
```

## Guidelines for Changelog Updates

1. **Use Bold Headings**: Use `**Added:**`, `**Fixed:**`, `**Improved:**`, and `**Changed:**` instead of Markdown headings (`###`) to avoid duplicate heading warnings.

2. **Version Numbering**:
   - For release candidates, use `1.0.0-rcXX` format
   - For stable releases, use `1.0.0` format
   - For patch releases, use `1.0.X` format

3. **Date Format**: Use `YYYY-MM-DD` format for dates

4. **Entry Format**:
   - Start each entry with a capital letter
   - Do not end entries with periods
   - Use past tense for verbs (e.g., "Added", "Fixed", "Improved", "Changed")
   - Be concise but descriptive

5. **Grouping**:
   - Group related changes together
   - List the most important changes first

6. **Categories**:
   - **Added**: New features or components
   - **Fixed**: Bug fixes
   - **Improved**: Enhancements to existing features
   - **Changed**: Changes in existing functionality

7. **Updating Process**:
   - Always add new entries at the top of the file
   - Never modify existing entries for previous versions
   - If you need to add a note to a previous version, add it as a new entry in the current version

## Example

```markdown
## [1.0.0-rc45] - 2025-07-04

**Added:**
- New documentation for database schema
- Helper methods for date formatting

**Fixed:**
- Bug in the calendar view that caused incorrect date display
- Performance issue in the gear list screen

**Improved:**
- Loading time for the dashboard screen
- Error messages for database operations

**Changed:**
- Refactored the booking creation workflow
- Updated the color scheme for better contrast
```
