# Typography Standardization Implementation Plan

## Overview

This document outlines the implementation plan for standardizing typography in the BLKWDS Manager application. The goal is to create a clear typography hierarchy, use predefined text styles, and ensure consistent typography usage throughout the application.

## Current State

The application currently has inconsistent typography usage:

1. Direct text style modifications in various places
2. Inconsistent font sizes, weights, and colors
3. No clear typography hierarchy
4. No predefined text styles for common use cases

This inconsistency can lead to:
- Inconsistent user experience
- Visual inconsistency across the application
- Code duplication
- Maintenance challenges

## Requirements

1. Define a clear typography hierarchy
2. Create predefined text styles for common use cases
3. Replace all direct text style modifications with predefined styles
4. Ensure consistent typography usage throughout the application

## Implementation Steps

### 1. Define Typography Hierarchy

Define a clear typography hierarchy in a new file `lib/constants/blkwds_typography.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';

class BLKWDSTypography {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BLKWDSColors.textPrimary,
    height: 1.2,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BLKWDSColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.textSecondary,
    height: 1.5,
  );

  // Caption text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BLKWDSColors.textTertiary,
    height: 1.5,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: BLKWDSColors.textOnPrimary,
    height: 1.0,
  );

  // Label text
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: BLKWDSColors.textSecondary,
    height: 1.2,
  );

  // Helper methods for common modifications
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
```

### 2. Update Theme Configuration

Update the theme configuration in `lib/constants/blkwds_theme.dart` to use the predefined text styles:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';
import 'package:blkwds_manager/constants/blkwds_typography.dart';

class BLKWDSTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: BLKWDSColors.primary,
      colorScheme: ColorScheme.dark(
        primary: BLKWDSColors.primary,
        secondary: BLKWDSColors.secondary,
        surface: BLKWDSColors.surface,
        background: BLKWDSColors.background,
        error: BLKWDSColors.error,
        onPrimary: BLKWDSColors.textOnPrimary,
        onSecondary: BLKWDSColors.textOnSecondary,
        onSurface: BLKWDSColors.textPrimary,
        onBackground: BLKWDSColors.textPrimary,
        onError: BLKWDSColors.textOnError,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: BLKWDSTypography.h1,
        displayMedium: BLKWDSTypography.h2,
        displaySmall: BLKWDSTypography.h3,
        bodyLarge: BLKWDSTypography.body,
        bodyMedium: BLKWDSTypography.bodySmall,
        labelLarge: BLKWDSTypography.button,
        bodySmall: BLKWDSTypography.caption,
        titleMedium: BLKWDSTypography.bodyBold,
        titleSmall: BLKWDSTypography.label,
      ),
      // Other theme configuration...
    );
  }
}
```

### 3. Audit the Codebase

#### 3.1 Identify Direct Text Style Modifications

Use static analysis tools to identify all direct text style modifications in the codebase:

```bash
grep -r "TextStyle" --include="*.dart" lib/
```

Create a list of files that need to be updated:

| File | Line | Current Implementation | Required Action |
|------|------|------------------------|----------------|
| *To be filled during audit* | | | |

### 4. Create Helper Widgets

Create helper widgets for common text use cases in `lib/widgets/common/blkwds_text.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_typography.dart';

class BLKWDSText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const BLKWDSText.h1(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.h1;

  const BLKWDSText.h2(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.h2;

  const BLKWDSText.h3(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.h3;

  const BLKWDSText.body(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.body;

  const BLKWDSText.bodyBold(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.bodyBold;

  const BLKWDSText.bodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.bodySmall;

  const BLKWDSText.caption(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.caption;

  const BLKWDSText.button(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.button;

  const BLKWDSText.label(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : style = BLKWDSTypography.label;

  const BLKWDSText.custom(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
```

### 5. Replace Direct Text Style Modifications

For each file identified in step 3.1, replace direct text style modifications with predefined styles:

#### Before:

```dart
Text(
  'Some heading',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)
```

#### After (Option 1 - Using BLKWDSText widget):

```dart
BLKWDSText.h1('Some heading')
```

#### After (Option 2 - Using predefined styles):

```dart
Text(
  'Some heading',
  style: BLKWDSTypography.h1,
)
```

### 6. Update Common Components

Update common components to use the predefined text styles:

#### 6.1 Update BLKWDSButton

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';
import 'package:blkwds_manager/constants/blkwds_typography.dart';

class BLKWDSButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isDanger;
  final bool isSmall;
  final IconData? icon;

  const BLKWDSButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isDanger = false,
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor();
    final Color textColor = _getTextColor();
    final TextStyle textStyle = isSmall
        ? BLKWDSTypography.button.copyWith(fontSize: 14)
        : BLKWDSTypography.button;

    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(text, style: textStyle.copyWith(color: textColor)),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backgroundColor),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 16,
              vertical: isSmall ? 8 : 12,
            ),
          ),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: textStyle.copyWith(color: textColor)),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 8 : 12,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isDanger) {
      return BLKWDSColors.error;
    }
    if (isSecondary) {
      return BLKWDSColors.secondary;
    }
    return BLKWDSColors.primary;
  }

  Color _getTextColor() {
    if (isDanger) {
      return BLKWDSColors.textOnError;
    }
    if (isSecondary) {
      return BLKWDSColors.textOnSecondary;
    }
    return BLKWDSColors.textOnPrimary;
  }
}
```

#### 6.2 Update BLKWDSCard

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';

class BLKWDSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;

  const BLKWDSCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor ?? BLKWDSColors.surface,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
```

### 7. Create Documentation

Create documentation for the typography system in `docs/ui_ux/typography_guidelines.md`:

```markdown
# Typography Guidelines

This document outlines the typography guidelines for the BLKWDS Manager application.

## Typography Hierarchy

| Level | Usage | Font Size | Font Weight | Line Height | Color |
|-------|-------|-----------|------------|-------------|-------|
| H1 | Screen titles | 24 | Bold | 1.2 | Primary |
| H2 | Section headers | 20 | Bold | 1.2 | Primary |
| H3 | Subsection headers | 18 | SemiBold | 1.2 | Primary |
| Body | Regular text | 16 | Regular | 1.5 | Secondary |
| Body Bold | Emphasized text | 16 | Bold | 1.5 | Secondary |
| Body Small | Secondary text | 14 | Regular | 1.5 | Secondary |
| Caption | Small text | 12 | Regular | 1.5 | Tertiary |
| Button | Button text | 16 | Medium | 1.0 | Varies |
| Label | Form labels | 14 | Medium | 1.2 | Secondary |

## Usage Guidelines

### Using BLKWDSText Widget

For most text elements, use the BLKWDSText widget:

```dart
BLKWDSText.h1('Screen Title')
BLKWDSText.h2('Section Header')
BLKWDSText.h3('Subsection Header')
BLKWDSText.body('Regular text content')
BLKWDSText.bodyBold('Emphasized text')
BLKWDSText.bodySmall('Secondary text content')
BLKWDSText.caption('Small text')
BLKWDSText.button('Button Text')
BLKWDSText.label('Form Label')
```

### Using Predefined Styles

For more complex text elements, use the predefined styles:

```dart
Text(
  'Screen Title',
  style: BLKWDSTypography.h1,
)
```

### Modifying Styles

To modify a predefined style, use the helper methods:

```dart
Text(
  'Custom Text',
  style: BLKWDSTypography.withColor(BLKWDSTypography.body, BLKWDSColors.error),
)
```

Or use the copyWith method:

```dart
Text(
  'Custom Text',
  style: BLKWDSTypography.body.copyWith(color: BLKWDSColors.error),
)
```
```

### 8. Test the Implementation

Test the typography implementation to ensure it works correctly:

1. Verify that all direct text style modifications have been replaced
2. Verify that typography is consistent throughout the application
3. Verify that the predefined text styles are used correctly
4. Test the typography on various screen sizes to ensure readability

## Implementation Schedule

| Task | Estimated Time | Dependencies |
|------|----------------|--------------|
| Define typography hierarchy | 1 hour | None |
| Update theme configuration | 1 hour | Typography hierarchy |
| Audit the codebase | 2 hours | None |
| Create helper widgets | 1 hour | Typography hierarchy |
| Replace direct text style modifications | 4 hours | Audit, helper widgets |
| Update common components | 2 hours | Typography hierarchy |
| Create documentation | 1 hour | All previous tasks |
| Test the implementation | 2 hours | All previous tasks |
| **Total** | **14 hours** | |

## Conclusion

This implementation plan provides a comprehensive approach to standardizing typography in the BLKWDS Manager application. By following this plan, we will ensure consistent typography throughout the application, improving the user experience and making the codebase more maintainable.

## Next Steps

1. Define the typography hierarchy
2. Update the theme configuration
3. Audit the codebase to identify all direct text style modifications
4. Create helper widgets for common text use cases
5. Replace all direct text style modifications with predefined styles
6. Update common components to use the predefined text styles
7. Create documentation for the typography system
8. Test the implementation to ensure it works correctly
