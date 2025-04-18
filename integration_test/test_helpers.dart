import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  /// Waits for app to stabilize
  static Future<void> waitForAppStability(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    // Additional wait to ensure app is stable
    final startTime = DateTime.now();
    bool isStable = false;
    
    while (!isStable) {
      if (DateTime.now().difference(startTime) > timeout) {
        break; // Timeout reached
      }
      
      try {
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        isStable = true; // If we get here without exceptions, app is stable
      } catch (e) {
        // App is still animating or processing, wait a bit more
        await Future.delayed(const Duration(milliseconds: 100));
      }
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

  /// Scrolls until a widget is found
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollableFinder, {
    double delta = 100.0,
    int maxScrolls = 50,
  }) async {
    int scrollCount = 0;
    while (scrollCount < maxScrolls && finder.evaluate().isEmpty) {
      await tester.drag(scrollableFinder, Offset(0, -delta));
      await tester.pumpAndSettle();
      scrollCount++;
    }
    
    if (finder.evaluate().isEmpty) {
      throw Exception('Could not find widget by scrolling');
    }
  }
}
