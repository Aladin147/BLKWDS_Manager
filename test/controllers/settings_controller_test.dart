import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/screens/settings/settings_controller.dart';

// Generate mocks
@GenerateMocks([BuildContext])
import 'settings_controller_test.mocks.dart';

void main() {
  late SettingsController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = SettingsController();
    mockContext = MockBuildContext();
    controller.setContext(mockContext);
  });

  group('SettingsController Basic Tests', () {
    test('controller should initialize with default values', () {
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, null);
    });

    test('isLoading should be initialized to false', () {
      // Assert
      expect(controller.isLoading.value, false);
    });

    test('errorMessage should be initialized to null', () {
      // Assert
      expect(controller.errorMessage.value, null);
    });

    test('successMessage should be initialized to null', () {
      // Assert
      expect(controller.successMessage.value, null);
    });

    test('context should be set correctly', () {
      // Assert
      expect(controller.context, mockContext);
    });
  });
}
