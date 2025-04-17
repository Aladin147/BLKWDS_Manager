import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// MemberAvatarWidget
/// A widget for displaying member avatars with initials or photos
class MemberAvatarWidget extends StatelessWidget {
  /// The member to display
  final Member member;

  /// The size of the avatar
  final double size;

  /// Whether to show the member name below the avatar
  final bool showName;

  /// Whether to show the member role below the name
  final bool showRole;

  /// Custom background color (overrides role-based color)
  final Color? backgroundColor;

  /// Custom text color for initials
  final Color? textColor;

  /// Custom border color
  final Color? borderColor;

  /// Border width
  final double borderWidth;

  /// Constructor
  const MemberAvatarWidget({
    super.key,
    required this.member,
    this.size = 40,
    this.showName = false,
    this.showRole = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Get initials from member name
    final initials = _getInitials(member.name);

    // Get role-based color
    final roleColor = _getColorForRole(member.role);

    // Build avatar
    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? roleColor.withValues(alpha: 50),
        border: Border.all(
          color: borderColor ?? roleColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor ?? roleColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (!showName && !showRole) {
      return avatarWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatarWidget,
        if (showName) ...[
          const SizedBox(height: 4),
          Text(
            member.name,
            style: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (showRole && member.role != null && member.role!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            member.role!,
            style: BLKWDSTypography.labelSmall.copyWith(
              color: BLKWDSColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Get initials from a name
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return nameParts[0][0].toUpperCase() + nameParts[nameParts.length - 1][0].toUpperCase();
  }

  /// Get color based on role
  Color _getColorForRole(String role) {
    final normalizedRole = role.toLowerCase().trim();

    // Map roles to specific colors
    switch (normalizedRole) {
      case 'director':
        return Colors.red;
      case 'producer':
        return Colors.orange;
      case 'cinematographer':
        return Colors.amber;
      case 'sound engineer':
        return Colors.blue;
      case 'editor':
        return Colors.green;
      case 'gaffer':
        return Colors.purple;
      case 'grip':
        return Colors.brown;
      case 'production assistant':
        return Colors.teal;
      case 'vfx artist':
        return Colors.indigo;
      case 'colorist':
        return Colors.deepOrange;
      case 'set designer':
        return Colors.lightBlue;
      case 'costume designer':
        return Colors.pink;
      case 'makeup artist':
        return Colors.deepPurple;
      case 'script supervisor':
        return Colors.cyan;
      case 'location manager':
        return Colors.lime;
      default:
        return BLKWDSColors.accentTeal;
    }
  }
}
