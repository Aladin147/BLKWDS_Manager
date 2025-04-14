import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_constants.dart';

class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLKWDS UI Showcase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Typography', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Text('Heading - Display Large', style: BLKWDSTypography.textTheme.displayLarge),
              Text('Headline - Medium', style: BLKWDSTypography.textTheme.headlineMedium),
              Text('Title - Medium', style: BLKWDSTypography.textTheme.titleMedium),
              Text('Body - Large', style: BLKWDSTypography.textTheme.bodyLarge),
              Text('Body - Medium', style: BLKWDSTypography.textTheme.bodyMedium),
              Text('Label - Large', style: BLKWDSTypography.textTheme.labelLarge),
              const SizedBox(height: BLKWDSConstants.spacingLarge),

              const Divider(),
              const Text('Buttons', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              ElevatedButton(onPressed: () {}, child: const Text('Primary CTA')),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              TextButton(onPressed: () {}, child: const Text('Ghost Button')),
              const SizedBox(height: BLKWDSConstants.spacingLarge),

              const Divider(),
              const Text('Cards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                ),
                elevation: BLKWDSConstants.cardElevation,
                child: Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Canon R6', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Checked out by Hamza – 10:41 AM'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingLarge),

              const Divider(),
              const Text('Inputs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search Gear',
                  hintText: 'Canon R6, DJI Ronin...'
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
