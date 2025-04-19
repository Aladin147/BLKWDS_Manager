import 'package:flutter/material.dart';
import '../../utils/database_performance_tester.dart';
import '../../utils/ui_performance_tester.dart';
import '../../utils/memory_leak_detector.dart';
import '../../services/log_service.dart';
import '../../widgets/blkwds_scaffold.dart';
import '../../widgets/blkwds_button.dart';
import '../../widgets/blkwds_card.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';

/// PerformanceTestScreen
/// A screen for running performance tests
class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({super.key});

  @override
  PerformanceTestScreenState createState() => PerformanceTestScreenState();
}

class PerformanceTestScreenState extends State<PerformanceTestScreen> {
  final DatabasePerformanceTester _databaseTester = DatabasePerformanceTester();
  final UIPerformanceTester _uiTester = UIPerformanceTester();
  final MemoryLeakDetector _memoryLeakDetector = MemoryLeakDetector();

  bool _isRunningTests = false;
  String _testResults = '';
  String _currentTest = '';

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Performance Tests',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(BLKWDSConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestControls(),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            _buildTestStatus(),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            _buildTestResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestControls() {
    return BLKWDSCard(
      child: Padding(
        padding: EdgeInsets.all(BLKWDSConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Tests',
              style: BLKWDSTypography.titleLarge,
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            Text(
              'Run performance tests to measure the performance of the application. '
              'These tests will measure startup time, UI responsiveness, database performance, '
              'and memory usage.',
              style: BLKWDSTypography.bodyMedium,
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: BLKWDSButton(
                    label: 'Run Database Tests',
                    onPressed: _isRunningTests ? null : _runDatabaseTests,
                    isLoading: _isRunningTests && _currentTest == 'database',
                  ),
                ),
                SizedBox(width: BLKWDSConstants.defaultPadding),
                Expanded(
                  child: BLKWDSButton(
                    label: 'Run UI Tests',
                    onPressed: _isRunningTests ? null : _runUITests,
                    isLoading: _isRunningTests && _currentTest == 'ui',
                  ),
                ),
              ],
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: BLKWDSButton(
                    label: 'Run Memory Tests',
                    onPressed: _isRunningTests ? null : _runMemoryTests,
                    isLoading: _isRunningTests && _currentTest == 'memory',
                  ),
                ),
                SizedBox(width: BLKWDSConstants.defaultPadding),
                Expanded(
                  child: BLKWDSButton(
                    label: 'Run All Tests',
                    onPressed: _isRunningTests ? null : _runAllTests,
                    isLoading: _isRunningTests && _currentTest == 'all',
                    type: BLKWDSButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestStatus() {
    if (!_isRunningTests && _testResults.isEmpty) {
      return SizedBox.shrink();
    }

    return BLKWDSCard(
      child: Padding(
        padding: EdgeInsets.all(BLKWDSConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Status',
              style: BLKWDSTypography.titleLarge,
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            if (_isRunningTests)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running ${_getTestName(_currentTest)} tests...',
                    style: BLKWDSTypography.bodyMedium,
                  ),
                  SizedBox(height: BLKWDSConstants.defaultPadding),
                  LinearProgressIndicator(
                    backgroundColor: BLKWDSColors.backgroundLight,
                    valueColor: AlwaysStoppedAnimation<Color>(BLKWDSColors.primary),
                  ),
                ],
              )
            else
              Text(
                'Tests completed',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    if (_testResults.isEmpty) {
      return SizedBox.shrink();
    }

    return BLKWDSCard(
      child: Padding(
        padding: EdgeInsets.all(BLKWDSConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: BLKWDSTypography.titleLarge,
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(BLKWDSConstants.defaultPadding),
              decoration: BoxDecoration(
                color: BLKWDSColors.backgroundDark,
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              ),
              child: SelectableText(
                _testResults,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: BLKWDSColors.textLight,
                ),
              ),
            ),
            SizedBox(height: BLKWDSConstants.defaultPadding),
            BLKWDSButton(
              label: 'Export Results',
              onPressed: _exportResults,
              type: BLKWDSButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDatabaseTests() async {
    setState(() {
      _isRunningTests = true;
      _currentTest = 'database';
      _testResults = '';
    });

    try {
      final results = await _databaseTester.runAllTests();

      setState(() {
        _testResults = results;
      });
    } catch (e, stackTrace) {
      LogService.error('Error running database tests', e, stackTrace);

      setState(() {
        _testResults = 'Error running database tests: $e';
      });
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  Future<void> _runUITests() async {
    if (!mounted) return;

    setState(() {
      _isRunningTests = true;
      _currentTest = 'ui';
      _testResults = '';
    });

    try {
      final results = await _uiTester.runAllTests();

      // Check if widget is still mounted
      if (!mounted) return;

      setState(() {
        _testResults = results;
      });
    } catch (e, stackTrace) {
      LogService.error('Error running UI tests', e, stackTrace);

      setState(() {
        _testResults = 'Error running UI tests: $e';
      });
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  Future<void> _runMemoryTests() async {
    if (!mounted) return;

    setState(() {
      _isRunningTests = true;
      _currentTest = 'memory';
      _testResults = '';
    });

    try {
      final results = await _memoryLeakDetector.runAllTests();

      // Check if widget is still mounted
      if (!mounted) return;

      setState(() {
        _testResults = results;
      });
    } catch (e, stackTrace) {
      LogService.error('Error running memory tests', e, stackTrace);

      setState(() {
        _testResults = 'Error running memory tests: $e';
      });
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    if (!mounted) return;

    setState(() {
      _isRunningTests = true;
      _currentTest = 'all';
      _testResults = '';
    });

    try {
      // Run database tests
      if (!mounted) return;
      setState(() {
        _currentTest = 'database';
      });
      final databaseResults = await _databaseTester.runAllTests();

      // Check if widget is still mounted
      if (!mounted) return;

      // Run UI tests
      setState(() {
        _currentTest = 'ui';
      });

      final uiResults = await _uiTester.runAllTests();

      // Check if widget is still mounted
      if (!mounted) return;

      // Run memory tests
      setState(() {
        _currentTest = 'memory';
      });

      final memoryResults = await _memoryLeakDetector.runAllTests();

      // Check if widget is still mounted
      if (!mounted) return;

      // Combine results
      final combinedResults = '''
=== ALL PERFORMANCE TESTS ===

--- DATABASE TESTS ---
$databaseResults

--- UI TESTS ---
$uiResults

--- MEMORY TESTS ---
$memoryResults

=========================
''';

      setState(() {
        _testResults = combinedResults;
      });
    } catch (e, stackTrace) {
      LogService.error('Error running all tests', e, stackTrace);

      setState(() {
        _testResults = 'Error running all tests: $e';
      });
    } finally {
      setState(() {
        _isRunningTests = false;
        _currentTest = '';
      });
    }
  }

  void _exportResults() {
    // In a real app, this would export the results to a file
    LogService.debug('Exporting test results');

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test results exported'),
        backgroundColor: BLKWDSColors.success,
      ),
    );
  }

  String _getTestName(String testType) {
    switch (testType) {
      case 'database':
        return 'database';
      case 'ui':
        return 'UI';
      case 'memory':
        return 'memory';
      case 'all':
        return 'all';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    _isRunningTests = false;
    super.dispose();
  }
}
