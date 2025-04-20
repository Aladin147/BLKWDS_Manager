import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/theme/blkwds_style_enhancer.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';
import 'package:blkwds_manager/theme/blkwds_typography.dart';

void main() {
  group('BLKWDSStyleEnhancer', () {
    test('enhanceContainer creates correct BoxDecoration', () {
      // Test default values
      final defaultDecoration = BLKWDSStyleEnhancer.enhanceContainer();
      expect(defaultDecoration.color, equals(BLKWDSColors.backgroundMedium));
      expect(defaultDecoration.borderRadius, isNotNull);
      expect(defaultDecoration.boxShadow, isNotNull);
      expect(defaultDecoration.gradient, isNull);

      // Test primary container
      final primaryDecoration = BLKWDSStyleEnhancer.enhanceContainer(isPrimary: true);
      expect(primaryDecoration.color, equals(BLKWDSColors.blkwdsGreen));
      expect(primaryDecoration.boxShadow, isNotNull);

      // Test with gradient
      final gradientDecoration = BLKWDSStyleEnhancer.enhanceContainer(useGradient: true);
      expect(gradientDecoration.gradient, isNotNull);
      expect(gradientDecoration.color, isNull); // Color should be null when gradient is used

      // Test with custom values
      final customDecoration = BLKWDSStyleEnhancer.enhanceContainer(
        backgroundColor: Colors.purple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        isElevated: false,
      );
      expect(customDecoration.color, equals(Colors.purple));
      expect((customDecoration.borderRadius as BorderRadius).topLeft.x, equals(20));
      expect(customDecoration.border, isNotNull);
      expect(customDecoration.boxShadow, isEmpty);
    });

    test('enhanceButton creates correct ButtonStyle', () {
      // Test default values
      final defaultStyle = BLKWDSStyleEnhancer.enhanceButton();
      expect(defaultStyle.backgroundColor, isNotNull);
      expect(defaultStyle.foregroundColor, isNotNull);
      expect(defaultStyle.elevation, isNotNull);

      // Test secondary button
      final secondaryStyle = BLKWDSStyleEnhancer.enhanceButton(isPrimary: false);
      expect(secondaryStyle.backgroundColor, isNotNull);
      expect(secondaryStyle.foregroundColor, isNotNull);

      // Test with custom values
      final customStyle = BLKWDSStyleEnhancer.enhanceButton(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(20),
        isElevated: false,
      );
      expect(customStyle.backgroundColor, isNotNull);
      expect(customStyle.foregroundColor, isNotNull);
      expect(customStyle.padding, isNotNull);
      expect(customStyle.elevation!.resolve({})?.toDouble(), equals(0.0));
    });

    test('enhanceCard creates correct BoxDecoration', () {
      // Test default values
      final defaultDecoration = BLKWDSStyleEnhancer.enhanceCard();
      expect(defaultDecoration.color, equals(BLKWDSColors.backgroundMedium));
      expect(defaultDecoration.borderRadius, isNotNull);
      expect(defaultDecoration.boxShadow, isNotNull);

      // Test with custom values
      final customDecoration = BLKWDSStyleEnhancer.enhanceCard(
        backgroundColor: Colors.teal,
        isPrimary: true,
        useGradient: true,
      );
      expect(customDecoration.gradient, isNotNull);
      expect(customDecoration.color, isNull); // Color should be null when gradient is used
    });

    test('enhanceText creates correct TextStyle', () {
      // Test default values
      final baseStyle = BLKWDSTypography.bodyMedium;
      final defaultStyle = BLKWDSStyleEnhancer.enhanceText(baseStyle);
      expect(defaultStyle.color, equals(baseStyle.color));
      expect(defaultStyle.fontWeight, equals(baseStyle.fontWeight));

      // Test primary text
      final primaryStyle = BLKWDSStyleEnhancer.enhanceText(baseStyle, isPrimary: true);
      expect(primaryStyle.color, equals(BLKWDSColors.blkwdsGreen));

      // Test with custom values
      final customStyle = BLKWDSStyleEnhancer.enhanceText(
        baseStyle,
        color: Colors.amber,
        letterSpacing: 2.0,
        height: 1.8,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      );
      expect(customStyle.color, equals(Colors.amber));
      expect(customStyle.letterSpacing, equals(2.0));
      expect(customStyle.height, equals(1.8));
      expect(customStyle.fontWeight, equals(FontWeight.bold));
      expect(customStyle.decoration, equals(TextDecoration.underline));
    });
  });
}
