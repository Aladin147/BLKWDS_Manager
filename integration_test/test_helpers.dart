import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'dart:async';

/// Helper class for integration tests to improve reliability
class IntegrationTestHelpers {
  /// Finds a widget by text with retry logic
  static Future<Finder> findByTextWithRetry(
    WidgetTester tester,
    String text, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
  }) async {
    final finder = find.text(text);
    int attempts = 0;

    while (attempts < maxAttempts) {
      await tester.pumpAndSettle(pumpDuration);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      attempts++;
    }

    // If we get here, we couldn't find the widget
    throw Exception('Could not find widget with text: $text after $maxAttempts attempts');
  }

  /// Finds a widget by type with retry logic
  static Future<Finder> findByTypeWithRetry<T extends Widget>(
    WidgetTester tester, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
  }) async {
    final finder = find.byType(T);
    int attempts = 0;

    while (attempts < maxAttempts) {
      await tester.pumpAndSettle(pumpDuration);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      attempts++;
    }

    // If we get here, we couldn't find the widget
    throw Exception('Could not find widget of type: $T after $maxAttempts attempts');
  }

  /// Taps a widget with retry logic
  static Future<void> tapWithRetry(
    WidgetTester tester,
    Finder finder, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await tester.tap(finder);
        await tester.pumpAndSettle(pumpDuration);
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          throw Exception('Failed to tap widget after $maxAttempts attempts: $e');
        }
        await tester.pumpAndSettle(pumpDuration);
      }
    }
  }

  /// Enters text with retry logic
  static Future<void> enterTextWithRetry(
    WidgetTester tester,
    Finder finder,
    String text, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await tester.enterText(finder, text);
        await tester.pumpAndSettle(pumpDuration);
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          throw Exception('Failed to enter text after $maxAttempts attempts: $e');
        }
        await tester.pumpAndSettle(pumpDuration);
      }
    }
  }

  /// Waits for app to stabilize with enhanced reliability
  static Future<void> waitForAppStability(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
    Duration pumpInterval = const Duration(milliseconds: 100),
  }) async {
    try {
      // First attempt to pump and settle
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Additional wait to ensure app is stable
      final startTime = DateTime.now();
      bool isStable = false;

      while (!isStable) {
        if (DateTime.now().difference(startTime) > timeout) {
          LogService.debug('Timeout reached while waiting for app stability');
          break; // Timeout reached
        }

        try {
          // Use pump with a small interval instead of pumpAndSettle to avoid issues with continuous animations
          await tester.pump(pumpInterval);

          // Try pumpAndSettle with a short timeout to check if the app is stable
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
          isStable = true; // If we get here without exceptions, app is stable
          LogService.debug('App is stable');
        } catch (e) {
          // App is still animating or processing, wait a bit more
          await Future.delayed(const Duration(milliseconds: 100));
          LogService.debug('Waiting for app stability: $e');
        }
      }
    } catch (e) {
      LogService.error('Error while waiting for app stability', e);
      // Continue with the test even if we couldn't achieve perfect stability
      // This makes tests more resilient to UI changes
    }
  }

  /// Finds a widget by key with retry logic
  static Future<Finder> findByKeyWithRetry(
    WidgetTester tester,
    Key key, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
  }) async {
    final finder = find.byKey(key);
    int attempts = 0;

    while (attempts < maxAttempts) {
      await tester.pumpAndSettle(pumpDuration);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      attempts++;
    }

    // If we get here, we couldn't find the widget
    throw Exception('Could not find widget with key: $key after $maxAttempts attempts');
  }

  /// Scrolls until a widget is found with enhanced reliability
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollableFinder, {
    double delta = 100.0,
    int maxScrolls = 50,
    Duration pumpDuration = const Duration(milliseconds: 300),
  }) async {
    int scrollCount = 0;
    while (scrollCount < maxScrolls && finder.evaluate().isEmpty) {
      try {
        await tester.drag(scrollableFinder, Offset(0, -delta));
        // Use pump instead of pumpAndSettle to avoid issues with continuous animations
        await tester.pump(pumpDuration);
        await tester.pump(pumpDuration);
        scrollCount++;
        LogService.debug('Scrolling attempt $scrollCount');
      } catch (e) {
        LogService.error('Error while scrolling', e);
        // Wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (finder.evaluate().isEmpty) {
      LogService.error('Could not find widget by scrolling after $scrollCount attempts');
      throw Exception('Could not find widget by scrolling after $scrollCount attempts');
    }
  }

  /// Performs a long press with retry logic
  static Future<void> longPressWithRetry(
    WidgetTester tester,
    Finder finder, {
    int maxAttempts = 5,
    Duration pumpDuration = const Duration(seconds: 1),
    Duration longPressDuration = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await tester.longPress(finder);
        // Use pump instead of pumpAndSettle to avoid issues with continuous animations
        await tester.pump(pumpDuration);
        await tester.pump(pumpDuration);
        LogService.debug('Long press successful');
        return; // Success
      } catch (e) {
        attempts++;
        LogService.error('Long press attempt $attempts failed', e);
        if (attempts >= maxAttempts) {
          throw Exception('Failed to long press widget after $maxAttempts attempts: $e');
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  /// Waits for a specific widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 500),
  }) async {
    final startTime = DateTime.now();
    bool widgetFound = false;

    while (!widgetFound) {
      if (DateTime.now().difference(startTime) > timeout) {
        LogService.error('Timeout waiting for widget to appear');
        throw Exception('Timeout waiting for widget to appear');
      }

      try {
        await tester.pump(checkInterval);
        if (finder.evaluate().isNotEmpty) {
          widgetFound = true;
          LogService.debug('Widget found');
        }
      } catch (e) {
        LogService.debug('Error while waiting for widget: $e');
        // Continue waiting
      }
    }
  }

  /// Waits for a specific widget to disappear
  static Future<void> waitForWidgetToDisappear(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 500),
  }) async {
    final startTime = DateTime.now();
    bool widgetGone = false;

    while (!widgetGone) {
      if (DateTime.now().difference(startTime) > timeout) {
        LogService.error('Timeout waiting for widget to disappear');
        throw Exception('Timeout waiting for widget to disappear');
      }

      try {
        await tester.pump(checkInterval);
        if (finder.evaluate().isEmpty) {
          widgetGone = true;
          LogService.debug('Widget disappeared');
        }
      } catch (e) {
        LogService.debug('Error while waiting for widget to disappear: $e');
        // Continue waiting
      }
    }
  }
}
