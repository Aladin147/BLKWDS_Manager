# Persistent Home Button Implementation Plan

## Overview

This document outlines the implementation plan for adding a persistent home button to the BLKWDS Manager application. The home button will provide users with a quick way to navigate back to the dashboard from any screen in the application.

## Requirements

1. The home button should be visible on all screens except the dashboard
2. The home button should be consistent with the app's design language
3. The home button should be easily accessible
4. Clicking the home button should navigate the user back to the dashboard
5. The navigation should be smooth and consistent with the app's navigation patterns

## Design Specifications

### Visual Design

1. **Icon**: Use a home icon from the Material Icons library
2. **Size**: 24x24 pixels
3. **Color**: Use the primary color from the BLKWDSColors class
4. **Position**: In the app bar, to the left of the screen title
5. **Padding**: 8px on all sides

### Behavior

1. **Tap Action**: Navigate to the dashboard screen
2. **Transition**: Use the standard navigation transition defined in the NavigationService
3. **State Preservation**: Ensure that the dashboard state is preserved when navigating back

## Implementation Steps

### 1. Create a Reusable Home Button Widget

Create a new file `lib/widgets/common/blkwds_home_button.dart` with a reusable home button widget:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/services/navigation_service.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';
import 'package:blkwds_manager/constants/app_routes.dart';

class BLKWDSHomeButton extends StatelessWidget {
  const BLKWDSHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home, size: 24),
      color: BLKWDSColors.primary,
      tooltip: 'Home',
      onPressed: () {
        NavigationService().navigateTo(
          AppRoutes.dashboard,
          clearStack: true,
        );
      },
    );
  }
}
```

### 2. Update the App Bar in the Main Scaffold

Modify the main scaffold to include the home button in the app bar. This will typically be in a file like `lib/widgets/common/blkwds_scaffold.dart` or similar:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/widgets/common/blkwds_home_button.dart';

class BLKWDSScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showHomeButton;
  final List<Widget>? actions;

  const BLKWDSScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showHomeButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showHomeButton ? const BLKWDSHomeButton() : null,
        actions: actions,
      ),
      body: body,
    );
  }
}
```

### 3. Update Screen Implementations

Update all screen implementations to use the BLKWDSScaffold with the appropriate showHomeButton parameter:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/widgets/common/blkwds_scaffold.dart';

class SomeScreen extends StatelessWidget {
  const SomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BLKWDSScaffold(
      title: 'Some Screen',
      showHomeButton: true, // Set to false for the dashboard
      body: Center(
        child: Text('Some Screen Content'),
      ),
    );
  }
}
```

For the dashboard screen, set showHomeButton to false:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/widgets/common/blkwds_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BLKWDSScaffold(
      title: 'Dashboard',
      showHomeButton: false, // No home button on the dashboard
      body: Center(
        child: Text('Dashboard Content'),
      ),
    );
  }
}
```

### 4. Update Navigation Service

Ensure that the NavigationService's navigateTo method supports the clearStack parameter:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/constants/app_routes.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {
    Object? arguments,
    bool clearStack = false,
  }) {
    if (clearStack) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } else {
      return navigatorKey.currentState!.pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }
}
```

### 5. Test the Implementation

Test the home button implementation on all screens to ensure it works correctly:

1. Verify that the home button is visible on all screens except the dashboard
2. Verify that clicking the home button navigates to the dashboard
3. Verify that the navigation is smooth and consistent with the app's navigation patterns
4. Verify that the dashboard state is preserved when navigating back

## Alternative Approaches

### 1. Floating Action Button

Instead of adding the home button to the app bar, we could implement it as a floating action button:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/services/navigation_service.dart';
import 'package:blkwds_manager/constants/app_routes.dart';
import 'package:blkwds_manager/constants/blkwds_colors.dart';

class BLKWDSScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showHomeButton;
  final List<Widget>? actions;

  const BLKWDSScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showHomeButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      floatingActionButton: showHomeButton
          ? FloatingActionButton(
              backgroundColor: BLKWDSColors.primary,
              child: const Icon(Icons.home),
              onPressed: () {
                NavigationService().navigateTo(
                  AppRoutes.dashboard,
                  clearStack: true,
                );
              },
            )
          : null,
    );
  }
}
```

### 2. Bottom Navigation Bar

Another approach would be to add a persistent bottom navigation bar with a home button:

```dart
import 'package:flutter/material.dart';
import 'package:blkwds_manager/services/navigation_service.dart';
import 'package:blkwds_manager/constants/app_routes.dart';

class BLKWDSScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showHomeButton;
  final List<Widget>? actions;

  const BLKWDSScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showHomeButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showHomeButton
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      NavigationService().navigateTo(
                        AppRoutes.dashboard,
                        clearStack: true,
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
```

## Conclusion

This implementation plan provides a comprehensive approach to adding a persistent home button to the BLKWDS Manager application. The plan includes design specifications, implementation steps, and alternative approaches to consider.

The recommended approach is to add the home button to the app bar, as this is consistent with common UI patterns and provides easy access to the dashboard from any screen in the application.

## Next Steps

1. Implement the BLKWDSHomeButton widget
2. Update the BLKWDSScaffold to include the home button
3. Update all screen implementations to use the updated scaffold
4. Test the implementation on all screens
5. Gather feedback and make adjustments as needed
