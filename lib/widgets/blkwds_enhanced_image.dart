import 'dart:io';
import 'package:flutter/material.dart';
import '../services/log_service.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';

/// BLKWDSEnhancedImage
/// A robust image widget that handles various image sources with graceful fallbacks
class BLKWDSEnhancedImage extends StatelessWidget {
  /// The image source path (can be a file path, asset path, or network URL)
  final String? imagePath;

  /// The width of the image
  final double? width;

  /// The height of the image
  final double? height;

  /// How to fit the image within its bounds
  final BoxFit fit;

  /// Border radius for the image
  final double borderRadius;

  /// Icon to display when image is not available
  final IconData fallbackIcon;

  /// Color for the fallback icon
  final Color fallbackIconColor;

  /// Background color for the fallback icon
  final Color fallbackBackgroundColor;

  /// Constructor
  const BLKWDSEnhancedImage({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BLKWDSConstants.borderRadius,
    this.fallbackIcon = Icons.image,
    this.fallbackIconColor = BLKWDSColors.textSecondary,
    this.fallbackBackgroundColor = BLKWDSColors.backgroundLight,
  });

  @override
  Widget build(BuildContext context) {
    // If no image path is provided, show fallback
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildFallbackWidget();
    }

    // Determine image source type
    if (_isAssetPath(imagePath!)) {
      // Asset image
      return _buildAssetImage();
    } else if (_isNetworkPath(imagePath!)) {
      // Network image
      return _buildNetworkImage();
    } else {
      // File image
      return _buildFileImage();
    }
  }

  /// Build a widget for asset images
  Widget _buildAssetImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          LogService.error('Failed to load asset image: $imagePath', error, stackTrace);
          return _buildFallbackWidget();
        },
      ),
    );
  }

  /// Build a widget for network images
  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          LogService.error('Failed to load network image: $imagePath', error, stackTrace);
          return _buildFallbackWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildLoadingWidget(loadingProgress);
        },
      ),
    );
  }

  /// Build a widget for file images
  Widget _buildFileImage() {
    final file = File(imagePath!);
    
    // Check if file exists
    try {
      if (!file.existsSync()) {
        LogService.error('Image file does not exist: $imagePath', null);
        return _buildFallbackWidget();
      }
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            LogService.error('Failed to load file image: $imagePath', error, stackTrace);
            return _buildFallbackWidget();
          },
        ),
      );
    } catch (e) {
      LogService.error('Error checking file existence: $imagePath', e);
      return _buildFallbackWidget();
    }
  }

  /// Build a loading widget
  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          color: fallbackIconColor,
        ),
      ),
    );
  }

  /// Build a fallback widget when image can't be loaded
  Widget _buildFallbackWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: fallbackIconColor,
          size: (width != null && height != null) 
              ? (width! < height! ? width! * 0.5 : height! * 0.5)
              : 24,
        ),
      ),
    );
  }

  /// Check if the path is an asset path
  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || path.startsWith('packages/');
  }

  /// Check if the path is a network path
  bool _isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
