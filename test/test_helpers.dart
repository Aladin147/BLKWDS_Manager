import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/log_level.dart';

/// Initialize test environment
void initializeTestEnvironment() {
  // Initialize sqflite_ffi for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Set log level to avoid verbose logs during tests
  LogService.setLogLevel(LogLevel.error);
}

/// Wrapper to pump a widget for testing
Future<void> pumpTestWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ),
  );
}

/// Find a widget by key
Finder findByKey(String key) {
  return find.byKey(Key(key));
}

/// Find a widget by text
Finder findByText(String text) {
  return find.text(text);
}

/// Find a widget by type
Finder findByType(Type type) {
  return find.byType(type);
}

/// Tap on a widget
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enter text in a text field
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
