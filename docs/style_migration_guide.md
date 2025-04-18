# BLKWDS Manager Style Migration Guide

This document provides guidance for migrating from the legacy styling components to the new enhanced styling system.

## Overview

The BLKWDS Manager app is transitioning to a new enhanced styling system that provides:

- Improved visual consistency
- Better animations and hover effects
- More flexible styling options
- Better performance
- Proper handling of deprecated Flutter APIs

This migration will be gradual, with both legacy and enhanced components available during the transition period.

## Migration Strategy

1. **Complete Screen Migration**: Migrate entire screens at once, replacing all legacy components.
2. **Direct Replacement**: Replace legacy components with enhanced versions without maintaining parallel support.
3. **Remove Legacy Files**: Delete legacy component files after migration to prevent conflicts.
4. **Comprehensive Testing**: Test each screen thoroughly after migration.

## Component Mapping

### Buttons

| Legacy | Enhanced | Notes |
|--------|----------|-------|
| `BLKWDSButton` | `BLKWDSEnhancedButton` | Enhanced version has better hover effects and loading states |
| `BLKWDSButtonType.primary` | `BLKWDSEnhancedButtonType.primary` | |
| `BLKWDSButtonType.secondary` | `BLKWDSEnhancedButtonType.secondary` | |
| `BLKWDSButtonType.danger` | `BLKWDSEnhancedButtonType.error` | Name changed for consistency |
| `isSmall` | Use `padding` parameter | More flexible sizing |

### Cards

| Legacy | Enhanced | Notes |
|--------|----------|-------|
| `BLKWDSCard` | `BLKWDSEnhancedCard` | Enhanced version has better hover effects and gradients |
| `BLKWDSCardType.standard` | `BLKWDSEnhancedCardType.standard` | |
| `BLKWDSCardType.primary` | `BLKWDSEnhancedCardType.primary` | |
| `BLKWDSCardType.secondary` | `BLKWDSEnhancedCardType.secondary` | |
| `BLKWDSCardType.success` | `BLKWDSEnhancedCardType.success` | |
| `BLKWDSCardType.warning` | `BLKWDSEnhancedCardType.warning` | |
| `BLKWDSCardType.error` | `BLKWDSEnhancedCardType.error` | |
| `hasShadow` | `isElevated` | Name changed for clarity |

### Text

| Legacy | Enhanced | Notes |
|--------|----------|-------|
| `Text` with manual styling | `BLKWDSEnhancedText` | New component for consistent text styling |
| Manual style application | Factory constructors like `BLKWDSEnhancedText.headingLarge()` | Simplified styling |

## Migration Examples

### Button Migration

**Legacy:**
```dart
BLKWDSButton(
  label: 'Submit',
  onPressed: _handleSubmit,
  type: BLKWDSButtonType.primary,
  icon: Icons.send,
  isSmall: true,
  isLoading: _isLoading,
)
```

**Enhanced:**
```dart
BLKWDSEnhancedButton(
  label: 'Submit',
  onPressed: _handleSubmit,
  type: BLKWDSEnhancedButtonType.primary,
  icon: Icons.send,
  padding: EdgeInsets.symmetric(
    horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
    vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
  ),
  isLoading: _isLoading,
)
```

**Using Helper:**
```dart
StyleMigrationHelper.createEnhancedButton(
  label: 'Submit',
  onPressed: _handleSubmit,
  type: BLKWDSButtonType.primary,
  icon: Icons.send,
  isSmall: true,
  isLoading: _isLoading,
)
```

### Card Migration

**Legacy:**
```dart
BLKWDSCard(
  type: BLKWDSCardType.primary,
  onTap: _handleCardTap,
  useGradient: true,
  animateOnHover: true,
  child: Text('Card Content'),
)
```

**Enhanced:**
```dart
BLKWDSEnhancedCard(
  type: BLKWDSEnhancedCardType.primary,
  onTap: _handleCardTap,
  useGradient: true,
  animateOnHover: true,
  child: BLKWDSEnhancedText(
    text: 'Card Content',
  ),
)
```

**Using Helper:**
```dart
StyleMigrationHelper.createEnhancedCard(
  type: BLKWDSCardType.primary,
  onTap: _handleCardTap,
  useGradient: true,
  animateOnHover: true,
  child: Text('Card Content'),
)
```

### Text Migration

**Legacy:**
```dart
Text(
  'Heading Text',
  style: BLKWDSTypography.headlineLarge.copyWith(
    color: BLKWDSColors.blkwdsGreen,
    fontWeight: FontWeight.bold,
  ),
)
```

**Enhanced:**
```dart
BLKWDSEnhancedText.headingLarge(
  'Heading Text',
  isPrimary: true,
  isBold: true,
)
```

**Using Helper:**
```dart
StyleMigrationHelper.createEnhancedText(
  'Heading Text',
  style: BLKWDSTypography.headlineLarge,
  isPrimary: true,
  isBold: true,
)
```

## Migration Checklist

When migrating a screen:

1. Import the enhanced widgets: `import 'package:blkwds_manager/widgets/blkwds_enhanced_widgets.dart';`
2. Import the migration helper: `import 'package:blkwds_manager/utils/style_migration_helper.dart';`
3. Replace buttons with `BLKWDSEnhancedButton` or use the helper
4. Replace cards with `BLKWDSEnhancedCard` or use the helper
5. Replace text with `BLKWDSEnhancedText` or use the helper
6. Test the screen thoroughly to ensure all interactions work as expected
7. Update the migration status in the project documentation

## Troubleshooting

If you encounter issues during migration:

1. Check the component mapping table for the correct replacement
2. Use the migration helper to simplify the transition
3. Refer to the style demo screen for examples of the enhanced components
4. Consult the unit tests for the enhanced components for usage examples

## Timeline

- **Phase 1 (Current)**: Complete migration of Dashboard screen
- **Phase 2**: Migration of Settings and Booking Panel screens
- **Phase 3**: Migration of remaining screens
- **Phase 4**: Final cleanup and optimization

## Resources

- Style Demo Screen: Navigate to Settings > Style Demo
- Enhanced Components Source: `lib/widgets/blkwds_enhanced_*.dart`
- Migration Helper: `lib/utils/style_migration_helper.dart`
- Unit Tests: `test/widgets/blkwds_enhanced_widgets_test.dart`
