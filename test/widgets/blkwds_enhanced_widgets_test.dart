import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/widgets/blkwds_enhanced_widgets.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';

void main() {
  group('BLKWDSEnhancedText', () {
    testWidgets('renders correctly with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedText(
              text: 'Test Text',
            ),
          ),
        ),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('applies primary color when isPrimary is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedText(
              text: 'Primary Text',
              isPrimary: true,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Primary Text'));
      expect(textWidget.style?.color, equals(BLKWDSColors.blkwdsGreen));
    });

    testWidgets('applies bold style when isBold is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedText(
              text: 'Bold Text',
              isBold: true,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Bold Text'));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('factory constructors create correct text styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BLKWDSEnhancedText.displayLarge('Display Large'),
                BLKWDSEnhancedText.headingLarge('Heading Large'),
                BLKWDSEnhancedText.titleLarge('Title Large'),
                BLKWDSEnhancedText.bodyLarge('Body Large'),
                BLKWDSEnhancedText.labelLarge('Label Large'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Display Large'), findsOneWidget);
      expect(find.text('Heading Large'), findsOneWidget);
      expect(find.text('Title Large'), findsOneWidget);
      expect(find.text('Body Large'), findsOneWidget);
      expect(find.text('Label Large'), findsOneWidget);
    });
  });

  group('BLKWDSEnhancedButton', () {
    testWidgets('renders correctly with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Icon Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton(
              label: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Loading Button'), findsNothing); // Text should be replaced with loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('icon factory constructor creates icon-only button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedButton.icon(
              icon: Icons.favorite,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('BLKWDSEnhancedCard', () {
    testWidgets('renders correctly with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedCard(
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('applies tap handler when onTap is provided', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      expect(find.text('Tappable Card'), findsOneWidget);

      await tester.tap(find.text('Tappable Card'));
      expect(tapped, isTrue);
    });

    testWidgets('applies hover animation when animateOnHover is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BLKWDSEnhancedCard(
              animateOnHover: true,
              child: const Text('Animated Card'),
            ),
          ),
        ),
      );

      expect(find.text('Animated Card'), findsOneWidget);
      expect(find.byType(MouseRegion), findsWidgets);
      expect(find.byType(AnimatedScale), findsOneWidget);
    });
  });
}
