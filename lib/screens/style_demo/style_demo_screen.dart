import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_enhanced_widgets.dart';
import '../../widgets/blkwds_scaffold.dart';
import '../../services/snackbar_service.dart';

/// StyleDemoScreen
/// A screen to showcase the enhanced styling components
class StyleDemoScreen extends StatelessWidget {
  const StyleDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Style Demo',
      showHomeButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Section
            BLKWDSEnhancedText.headingLarge(
              'Typography',
              isPrimary: true,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildTypographySection(),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Cards Section
            BLKWDSEnhancedText.headingLarge(
              'Cards',
              isPrimary: true,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildCardsSection(context),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Buttons Section
            BLKWDSEnhancedText.headingLarge(
              'Buttons',
              isPrimary: true,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildButtonsSection(),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Colors Section
            BLKWDSEnhancedText.headingLarge(
              'Colors',
              isPrimary: true,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            _buildColorsSection(),
            const SizedBox(height: BLKWDSConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BLKWDSEnhancedText.displayLarge('Display Large'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.displayMedium('Display Medium'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.headingLarge('Heading Large'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.headingMedium('Heading Medium'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.titleLarge('Title Large'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.bodyLarge('Body Large - Regular text content for important information'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.bodyMedium('Body Medium - Regular text content for most UI elements'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.labelLarge('Label Large - For buttons and important UI elements'),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Text Variations
        BLKWDSEnhancedText.headingMedium('Text Variations'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedText.bodyMedium('Regular Text'),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),
        BLKWDSEnhancedText.bodyMedium('Bold Text', isBold: true),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),
        BLKWDSEnhancedText.bodyMedium('Italic Text', isItalic: true),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),
        BLKWDSEnhancedText.bodyMedium('Underlined Text', hasUnderline: true),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),
        BLKWDSEnhancedText.bodyMedium('Primary Color Text', isPrimary: true),
        const SizedBox(height: BLKWDSConstants.spacingXSmall),
        BLKWDSEnhancedText.bodyMedium('Custom Color Text', color: BLKWDSColors.accentTeal),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard Card
        BLKWDSEnhancedText.headingMedium('Standard Card'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.titleLarge('Standard Card'),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'This is a standard card with default styling. It uses the background medium color and has standard elevation.',
              ),
            ],
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Primary Card
        BLKWDSEnhancedText.headingMedium('Primary Card'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedCard(
          type: BLKWDSEnhancedCardType.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.titleLarge('Primary Card'),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'This is a primary card with the brand green color. It has higher elevation and stands out more.',
              ),
            ],
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Card with Gradient
        BLKWDSEnhancedText.headingMedium('Card with Gradient'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedCard(
          useGradient: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.titleLarge('Gradient Card'),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'This card uses a subtle gradient background for a more premium look.',
              ),
            ],
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Card with Animation
        BLKWDSEnhancedText.headingMedium('Card with Hover Animation'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedCard(
          animateOnHover: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.titleLarge('Animated Card'),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'This card animates on hover, providing a subtle interaction effect. Hover over it to see the animation.',
              ),
            ],
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Card with Tap Action
        BLKWDSEnhancedText.headingMedium('Card with Tap Action'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedCard(
          onTap: () {
            SnackbarService.showInfo(context, 'Card tapped!');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.titleLarge('Tappable Card'),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'This card has a tap action. Tap it to see a snackbar message.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Button
        BLKWDSEnhancedText.headingMedium('Primary Button'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedButton(
          label: 'Primary Button',
          onPressed: () {},
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Secondary Button
        BLKWDSEnhancedText.headingMedium('Secondary Button'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedButton(
          label: 'Secondary Button',
          type: BLKWDSEnhancedButtonType.secondary,
          onPressed: () {},
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Button with Icon
        BLKWDSEnhancedText.headingMedium('Button with Icon'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedButton(
          label: 'Button with Icon',
          icon: Icons.add,
          onPressed: () {},
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Icon Button
        BLKWDSEnhancedText.headingMedium('Icon Button'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedButton.icon(
          icon: Icons.favorite,
          onPressed: () {},
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Loading Button
        BLKWDSEnhancedText.headingMedium('Loading Button'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        BLKWDSEnhancedButton(
          label: 'Loading Button',
          isLoading: true,
          onPressed: () {},
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Button Variations
        BLKWDSEnhancedText.headingMedium('Button Variations'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        Wrap(
          spacing: BLKWDSConstants.spacingSmall,
          runSpacing: BLKWDSConstants.spacingSmall,
          children: [
            BLKWDSEnhancedButton(
              label: 'Primary',
              type: BLKWDSEnhancedButtonType.primary,
              onPressed: () {},
            ),
            BLKWDSEnhancedButton(
              label: 'Secondary',
              type: BLKWDSEnhancedButtonType.secondary,
              onPressed: () {},
            ),
            BLKWDSEnhancedButton(
              label: 'Tertiary',
              type: BLKWDSEnhancedButtonType.tertiary,
              onPressed: () {},
            ),
            BLKWDSEnhancedButton(
              label: 'Success',
              type: BLKWDSEnhancedButtonType.success,
              onPressed: () {},
            ),
            BLKWDSEnhancedButton(
              label: 'Warning',
              type: BLKWDSEnhancedButtonType.warning,
              onPressed: () {},
            ),
            BLKWDSEnhancedButton(
              label: 'Error',
              type: BLKWDSEnhancedButtonType.error,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Colors
        BLKWDSEnhancedText.headingMedium('Primary Colors'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        _buildColorGrid([
          _ColorItem('BLKWDS Green', BLKWDSColors.blkwdsGreen),
          _ColorItem('Deep Black', BLKWDSColors.deepBlack),
          _ColorItem('White', BLKWDSColors.white, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Slate Grey', BLKWDSColors.slateGrey),
        ]),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Background Colors
        BLKWDSEnhancedText.headingMedium('Background Colors'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        _buildColorGrid([
          _ColorItem('Background Dark', BLKWDSColors.backgroundDark),
          _ColorItem('Background Medium', BLKWDSColors.backgroundMedium),
          _ColorItem('Background Light', BLKWDSColors.backgroundLight),
        ]),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Accent Colors
        BLKWDSEnhancedText.headingMedium('Accent Colors'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        _buildColorGrid([
          _ColorItem('Accent Teal', BLKWDSColors.accentTeal),
          _ColorItem('Mustard Orange', BLKWDSColors.mustardOrange, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Electric Mint', BLKWDSColors.electricMint, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Alert Coral', BLKWDSColors.alertCoral, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Accent Purple', BLKWDSColors.accentPurple),
        ]),
        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Status Colors
        BLKWDSEnhancedText.headingMedium('Status Colors'),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        _buildColorGrid([
          _ColorItem('Success Green', BLKWDSColors.successGreen, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Warning Amber', BLKWDSColors.warningAmber, textColor: BLKWDSColors.deepBlack),
          _ColorItem('Error Red', BLKWDSColors.errorRed),
          _ColorItem('Info Blue', BLKWDSColors.infoBlue),
        ]),
      ],
    );
  }

  Widget _buildColorGrid(List<_ColorItem> colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: BLKWDSConstants.spacingSmall,
        mainAxisSpacing: BLKWDSConstants.spacingSmall,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return Container(
          decoration: BoxDecoration(
            color: color.color,
            borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
          ),
          padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                color.name,
                style: BLKWDSTypography.labelSmall.copyWith(
                  color: color.textColor ?? BLKWDSColors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  final Color? textColor;

  _ColorItem(this.name, this.color, {this.textColor});
}
