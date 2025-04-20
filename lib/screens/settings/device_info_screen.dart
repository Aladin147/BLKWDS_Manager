import 'package:flutter/material.dart';
import '../../services/device_info_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../utils/platform_util.dart';
import '../../widgets/blkwds_widgets.dart';

/// DeviceInfoScreen
/// Screen for displaying device information
class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, dynamic> _deviceInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceInfo = await DeviceInfoService.getDetailedDeviceInfo();
      setState(() {
        _deviceInfo = deviceInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceInfo = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDeviceInfoList(),
    );
  }

  Widget _buildDeviceInfoList() {
    if (_deviceInfo.containsKey('error')) {
      return Center(
        child: Text(
          'Error: ${_deviceInfo['error']}',
          style: BLKWDSTypography.bodyLarge.copyWith(color: BLKWDSColors.errorRed),
        ),
      );
    }

    final List<MapEntry<String, dynamic>> entries = _deviceInfo.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      itemCount: entries.length + 1, // +1 for the platform section
      itemBuilder: (context, index) {
        if (index == 0) {
          // Platform section
          return BLKWDSCard(
            margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
            child: Padding(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform',
                    style: BLKWDSTypography.headlineSmall,
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  _buildInfoRow('Platform Type', PlatformUtil.isAndroid ? 'Android' : 'Windows'),
                  _buildInfoRow('Is Mobile', PlatformUtil.isMobile.toString()),
                  _buildInfoRow('Is Desktop', PlatformUtil.isDesktop.toString()),
                  _buildInfoRow('Supports File Explorer', PlatformUtil.supportsFileExplorer.toString()),
                  _buildInfoRow('Requires Runtime Permissions', PlatformUtil.requiresRuntimePermissions.toString()),
                  _buildInfoRow('Supports Hover', PlatformUtil.supportsHover.toString()),
                  _buildInfoRow('Has Physical Keyboard', PlatformUtil.hasPhysicalKeyboard.toString()),
                  _buildInfoRow('Is Touch Primary', PlatformUtil.isTouchPrimary.toString()),
                ],
              ),
            ),
          );
        }

        final entry = entries[index - 1];
        return BLKWDSCard(
          margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
          child: ListTile(
            title: Text(
              _formatKey(entry.key),
              style: BLKWDSTypography.titleMedium,
            ),
            subtitle: Text(
              entry.value.toString(),
              style: BLKWDSTypography.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: BLKWDSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: BLKWDSTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case with spaces
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}
