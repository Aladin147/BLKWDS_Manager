import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../services/app_config_service.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../services/database/database_integrity_service.dart';
import '../../services/database/database_integrity_checker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';

/// Database Integrity Screen
///
/// This screen allows the user to manage database integrity checks.
class DatabaseIntegrityScreen extends StatefulWidget {
  /// Constructor
  const DatabaseIntegrityScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseIntegrityScreen> createState() => _DatabaseIntegrityScreenState();
}

class _DatabaseIntegrityScreenState extends State<DatabaseIntegrityScreen> {
  bool _isLoading = false;
  bool _isRunningCheck = false;
  bool _enableIntegrityChecks = true;
  bool _autoFixIssues = false;
  int _checkIntervalHours = 24;
  Map<String, dynamic>? _lastCheckResults;
  DateTime? _lastCheckTime;
  final DatabaseIntegrityService _integrityService = DatabaseIntegrityService();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// Load the app configuration
  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appConfig = await AppConfigService.getConfig();
      setState(() {
        _enableIntegrityChecks = appConfig.database.enableIntegrityChecks;
        _autoFixIssues = appConfig.database.databaseIntegrityAutoFix;
        _checkIntervalHours = appConfig.database.integrityCheckIntervalHours;
        _lastCheckResults = _integrityService.lastCheckResults;
        _lastCheckTime = _integrityService.lastCheckTime;
      });
    } catch (e, stackTrace) {
      LogService.error('Error loading app configuration', e, stackTrace);
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading configuration: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save the app configuration
  Future<void> _saveConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appConfig = await AppConfigService.getConfig();
      final updatedConfig = appConfig.copyWith(
        database: appConfig.database.copyWith(
          enableIntegrityChecks: _enableIntegrityChecks,
          databaseIntegrityAutoFix: _autoFixIssues,
          integrityCheckIntervalHours: _checkIntervalHours,
        ),
      );

      await AppConfigService.saveConfig(updatedConfig);

      // Update the integrity service
      if (_enableIntegrityChecks) {
        await _integrityService.start(
          checkIntervalHours: _checkIntervalHours,
          runImmediately: false,
        );
      } else {
        await _integrityService.stop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      LogService.error('Error saving app configuration', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Run a manual integrity check
  Future<void> _runManualCheck({bool autoFix = false}) async {
    setState(() {
      _isRunningCheck = true;
    });

    try {
      final results = await _integrityService.runManualCheck(autoFix: autoFix);
      setState(() {
        _lastCheckResults = results;
        _lastCheckTime = DateTime.now();
      });

      // Show a snackbar with the results
      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No integrity issues found'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        int issueCount = 0;
        if (results.containsKey('foreign_key_issues')) {
          final issues = results['foreign_key_issues'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            issueCount += entry.value.length;
          }
        }
        if (results.containsKey('orphaned_records')) {
          final issues = results['orphaned_records'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            issueCount += entry.value.length;
          }
        }
        if (results.containsKey('consistency_issues')) {
          final issues = results['consistency_issues'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            issueCount += entry.value.length;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found $issueCount integrity issues'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: autoFix ? null : SnackBarAction(
                label: 'Fix Issues',
                onPressed: () => _fixIssues(results),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error running integrity check', e, stackTrace);
      if (!mounted) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error running integrity check: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isRunningCheck = false;
      });
    }
  }

  /// Fix integrity issues
  Future<void> _fixIssues(Map<String, dynamic> issues) async {
    setState(() {
      _isRunningCheck = true;
    });

    try {
      final db = await DBService.database;
      final fixResults = await DatabaseIntegrityChecker.fixIntegrityIssues(db, issues);

      // Update the last check results
      setState(() {
        _lastCheckResults = {
          ...issues,
          'fix_results': fixResults,
        };
      });

      // Show a snackbar with the results
      if (!mounted) return;

      if (fixResults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No issues were fixed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        int fixedCount = 0;
        for (final entry in fixResults.entries) {
          if (entry.value is List) {
            fixedCount += (entry.value as List).length;
          } else if (entry.value is Map) {
            fixedCount += (entry.value as Map).length;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fixed $fixedCount integrity issues'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error fixing integrity issues', e, stackTrace);
      if (!mounted) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fixing integrity issues: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isRunningCheck = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Integrity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Integrity Check Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Enable Integrity Checks'),
                            subtitle: const Text(
                              'Periodically check database integrity',
                            ),
                            value: _enableIntegrityChecks,
                            onChanged: (value) {
                              setState(() {
                                _enableIntegrityChecks = value;
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('Auto-Fix Issues'),
                            subtitle: const Text(
                              'Automatically fix integrity issues when found',
                            ),
                            value: _autoFixIssues,
                            onChanged: _enableIntegrityChecks
                                ? (value) {
                                    setState(() {
                                      _autoFixIssues = value;
                                    });
                                  }
                                : null,
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Check Interval'),
                            subtitle: Text(
                              'Run integrity checks every $_checkIntervalHours hours',
                            ),
                            trailing: DropdownButton<int>(
                              value: _checkIntervalHours,
                              onChanged: _enableIntegrityChecks
                                  ? (value) {
                                      if (value != null) {
                                        setState(() {
                                          _checkIntervalHours = value;
                                        });
                                      }
                                    }
                                  : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('1 hour'),
                                ),
                                DropdownMenuItem(
                                  value: 6,
                                  child: Text('6 hours'),
                                ),
                                DropdownMenuItem(
                                  value: 12,
                                  child: Text('12 hours'),
                                ),
                                DropdownMenuItem(
                                  value: 24,
                                  child: Text('24 hours'),
                                ),
                                DropdownMenuItem(
                                  value: 48,
                                  child: Text('48 hours'),
                                ),
                                DropdownMenuItem(
                                  value: 168,
                                  child: Text('Weekly'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Manual check section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manual Integrity Check',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.search),
                                  label: const Text('Run Check'),
                                  onPressed: _isRunningCheck
                                      ? null
                                      : () => _runManualCheck(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.healing),
                                  label: const Text('Check & Fix'),
                                  onPressed: _isRunningCheck
                                      ? null
                                      : () => _runManualCheck(autoFix: true),
                                ),
                              ),
                            ],
                          ),
                          if (_isRunningCheck) ...[
                            const SizedBox(height: 16),
                            const Center(child: LoadingIndicator()),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text('Running integrity check...'),
                            ),
                          ],
                          if (_lastCheckTime != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Last check: ${_formatDateTime(_lastCheckTime!)}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Results section
                  if (_lastCheckResults != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Check Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildResultsSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  /// Build the results section
  Widget _buildResultsSection() {
    if (_lastCheckResults == null) {
      return const Text('No results available');
    }

    if (_lastCheckResults!.isEmpty) {
      return const Text(
        'No integrity issues found',
        style: TextStyle(color: Colors.green),
      );
    }

    if (_lastCheckResults!.containsKey('error')) {
      return Text(
        'Error: ${_lastCheckResults!['error']}',
        style: const TextStyle(color: Colors.red),
      );
    }

    final List<Widget> sections = [];

    // Foreign key issues
    if (_lastCheckResults!.containsKey('foreign_key_issues')) {
      final issues = _lastCheckResults!['foreign_key_issues'] as Map<String, List<Map<String, dynamic>>>;
      if (issues.isNotEmpty) {
        sections.add(
          _buildIssueSection(
            'Foreign Key Issues',
            issues,
            const Icon(Icons.link_off, color: Colors.orange),
          ),
        );
      }
    }

    // Orphaned records
    if (_lastCheckResults!.containsKey('orphaned_records')) {
      final issues = _lastCheckResults!['orphaned_records'] as Map<String, List<Map<String, dynamic>>>;
      if (issues.isNotEmpty) {
        sections.add(
          _buildIssueSection(
            'Orphaned Records',
            issues,
            const Icon(Icons.person_off, color: Colors.orange),
          ),
        );
      }
    }

    // Consistency issues
    if (_lastCheckResults!.containsKey('consistency_issues')) {
      final issues = _lastCheckResults!['consistency_issues'] as Map<String, List<Map<String, dynamic>>>;
      if (issues.isNotEmpty) {
        sections.add(
          _buildIssueSection(
            'Consistency Issues',
            issues,
            const Icon(Icons.warning, color: Colors.orange),
          ),
        );
      }
    }

    // Fix results
    if (_lastCheckResults!.containsKey('fix_results')) {
      final fixResults = _lastCheckResults!['fix_results'] as Map<String, dynamic>;
      if (fixResults.isNotEmpty) {
        sections.add(
          _buildFixResultsSection(fixResults),
        );
      }
    }

    if (sections.isEmpty) {
      return const Text(
        'No integrity issues found',
        style: TextStyle(color: Colors.green),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  /// Build an issue section
  Widget _buildIssueSection(
    String title,
    Map<String, List<Map<String, dynamic>>> issues,
    Icon icon,
  ) {
    int totalIssues = 0;
    for (final entry in issues.entries) {
      totalIssues += entry.value.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              '$title ($totalIssues)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...issues.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              '${entry.key}: ${entry.value.length} issues',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }),
        const Divider(),
      ],
    );
  }

  /// Build the fix results section
  Widget _buildFixResultsSection(Map<String, dynamic> fixResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.healing, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Fixed Issues',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...fixResults.entries.map((entry) {
          final value = entry.value;
          final count = value is List
              ? value.length
              : value is Map
                  ? value.length
                  : 0;
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              '${entry.key}: $count issues fixed',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }),
        const Divider(),
      ],
    );
  }

  /// Format a DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
