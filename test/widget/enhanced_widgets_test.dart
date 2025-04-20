import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/widgets/blkwds_enhanced_button.dart';
import 'package:blkwds_manager/widgets/blkwds_enhanced_card.dart';
import 'package:blkwds_manager/widgets/blkwds_enhanced_form_field.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';

void main() {
  group('BLKWDSEnhancedButton', () {
    testWidgets('should render correctly with primary type', (WidgetTester tester) async {
      // Arrange
      bool buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Test Button',
              onPressed: () {
                buttonPressed = true;
              },
              type: BLKWDSEnhancedButtonType.primary,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Button'), findsOneWidget);

      // Test button press
      await tester.tap(find.byType(BLKWDSEnhancedButton));
      expect(buttonPressed, isTrue);
    });

    testWidgets('should render correctly with secondary type', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Secondary Button',
              onPressed: () {},
              type: BLKWDSEnhancedButtonType.secondary,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('should be disabled when onPressed is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Disabled Button',
              onPressed: null,
              type: BLKWDSEnhancedButtonType.primary,
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<BLKWDSEnhancedButton>(
        find.byType(BLKWDSEnhancedButton)
      );
      expect(button.onPressed, isNull);
    });
  });

  group('BLKWDSEnhancedCard', () {
    testWidgets('should render with correct content', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('should apply padding when specified', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedCard(
              padding: EdgeInsets.all(16.0),
              child: Text('Padded Content'),
            ),
          ),
        ),
      );

      // Assert
      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Padded Content'),
          matching: find.byType(Padding),
        ).first,
      );

      expect(paddingWidget.padding, EdgeInsets.all(16.0));
    });
  });

  group('BLKWDSEnhancedFormField', () {
    testWidgets('should render with label and hint text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedFormField(
              controller: TextEditingController(),
              label: 'Test Label',
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should update text when typing', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedFormField(
              controller: controller,
              label: 'Input Field',
            ),
          ),
        ),
      );

      // Type text
      await tester.enterText(find.byType(TextFormField), 'Hello World');

      // Assert
      expect(controller.text, 'Hello World');
    });

    testWidgets('should show validation error when validator returns error', (WidgetTester tester) async {
      // Arrange
      final formKey = GlobalKey<FormState>();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: BLKWDSEnhancedFormField(
                controller: TextEditingController(),
                label: 'Error Field',
                validator: (value) => 'This field has an error',
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pump();

      // Assert
      expect(find.text('This field has an error'), findsOneWidget);
    });
  });
}
