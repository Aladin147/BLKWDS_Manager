import 'package:flutter/material.dart';
import 'test_app.dart';

/// A simplified main entry point for testing on Android
void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the test app
  runApp(const TestApp());
}
