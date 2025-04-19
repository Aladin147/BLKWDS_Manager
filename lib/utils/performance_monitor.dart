import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/log_service.dart';

/// PerformanceMonitor
/// A utility class for monitoring and logging performance metrics
class PerformanceMonitor {
  // Singleton instance
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  final Map<String, List<double>> _metrics = {};
  final Map<String, Stopwatch> _activeStopwatches = {};

  // Frame metrics
  bool _isMonitoringFrames = false;
  final List<Duration> _frameDurations = [];
  int _droppedFrames = 0;

  // Memory metrics
  Timer? _memoryMonitorTimer;
  final List<int> _memoryUsage = [];

  /// Start measuring a performance metric
  void startMeasurement(String metricName) {
    final stopwatch = Stopwatch()..start();
    _activeStopwatches[metricName] = stopwatch;
    LogService.debug('Started measuring: $metricName');
  }

  /// Stop measuring a performance metric and record the result
  double stopMeasurement(String metricName) {
    final stopwatch = _activeStopwatches.remove(metricName);
    if (stopwatch == null) {
      LogService.error('No active measurement found for: $metricName');
      return -1;
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds.toDouble();

    if (!_metrics.containsKey(metricName)) {
      _metrics[metricName] = [];
    }
    _metrics[metricName]!.add(elapsedMs);

    LogService.debug('Stopped measuring: $metricName, elapsed: ${elapsedMs}ms');
    return elapsedMs;
  }

  /// Get the average value for a metric
  double getAverageMetric(String metricName) {
    final values = _metrics[metricName];
    if (values == null || values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Get the maximum value for a metric
  double getMaxMetric(String metricName) {
    final values = _metrics[metricName];
    if (values == null || values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Get the minimum value for a metric
  double getMinMetric(String metricName) {
    final values = _metrics[metricName];
    if (values == null || values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Start monitoring frame performance
  void startFrameMonitoring() {
    if (_isMonitoringFrames) return;

    _isMonitoringFrames = true;
    _frameDurations.clear();
    _droppedFrames = 0;

    // Enable frame timing
    debugPrintBeginFrameBanner = true;
    debugPrintEndFrameBanner = true;

    // Listen to frame timings
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);

    LogService.debug('Started frame monitoring');
  }

  /// Stop monitoring frame performance
  void stopFrameMonitoring() {
    if (!_isMonitoringFrames) return;

    _isMonitoringFrames = false;

    // Disable frame timing
    debugPrintBeginFrameBanner = false;
    debugPrintEndFrameBanner = false;

    // Remove listener
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);

    LogService.debug('Stopped frame monitoring. Frames: ${_frameDurations.length}, Dropped: $_droppedFrames');
  }

  /// Callback for frame timings
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final duration = Duration(microseconds:
          timing.totalSpan.inMicroseconds);
      _frameDurations.add(duration);

      // Check for dropped frames (> 16.67ms for 60fps)
      if (duration.inMicroseconds > 16670) {
        _droppedFrames++;
      }
    }
  }

  /// Get the average frame rate
  double getAverageFrameRate() {
    if (_frameDurations.isEmpty) return 0;

    final avgDurationMs = _frameDurations
        .map((d) => d.inMicroseconds / 1000)
        .reduce((a, b) => a + b) / _frameDurations.length;

    // Convert ms per frame to frames per second
    return 1000 / avgDurationMs;
  }

  /// Get the percentage of dropped frames
  double getDroppedFramePercentage() {
    if (_frameDurations.isEmpty) return 0;

    return (_droppedFrames / _frameDurations.length) * 100;
  }

  /// Start monitoring memory usage
  void startMemoryMonitoring({Duration interval = const Duration(seconds: 1)}) {
    _memoryUsage.clear();

    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = Timer.periodic(interval, (_) {
      _captureMemoryUsage();
    });

    LogService.debug('Started memory monitoring with interval: ${interval.inMilliseconds}ms');
  }

  /// Stop monitoring memory usage
  void stopMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;

    LogService.debug('Stopped memory monitoring. Samples: ${_memoryUsage.length}');
  }

  /// Capture current memory usage
  void _captureMemoryUsage() {
    // This is a simplified approach using a placeholder value
    // In a real app, you'd use platform-specific methods to get accurate memory usage
    final currentMemoryUsage = 100 * 1024 * 1024; // Placeholder: 100 MB
    _memoryUsage.add(currentMemoryUsage);

    LogService.debug('Memory usage: ${(currentMemoryUsage / 1024 / 1024).toStringAsFixed(2)} MB');
  }

  /// Get the average memory usage in MB
  double getAverageMemoryUsageMB() {
    if (_memoryUsage.isEmpty) return 0;

    final avgBytes = _memoryUsage.reduce((a, b) => a + b) / _memoryUsage.length;
    return avgBytes / (1024 * 1024); // Convert to MB
  }

  /// Get the maximum memory usage in MB
  double getMaxMemoryUsageMB() {
    if (_memoryUsage.isEmpty) return 0;

    final maxBytes = _memoryUsage.reduce((a, b) => a > b ? a : b);
    return maxBytes / (1024 * 1024); // Convert to MB
  }

  /// Reset all metrics
  void resetAllMetrics() {
    _metrics.clear();
    _activeStopwatches.clear();
    _frameDurations.clear();
    _droppedFrames = 0;
    _memoryUsage.clear();

    LogService.debug('Reset all performance metrics');
  }

  /// Generate a performance report
  String generateReport() {
    final buffer = StringBuffer();

    buffer.writeln('=== PERFORMANCE REPORT ===');
    buffer.writeln();

    // Custom metrics
    if (_metrics.isNotEmpty) {
      buffer.writeln('--- CUSTOM METRICS ---');
      for (final entry in _metrics.entries) {
        final metricName = entry.key;
        final values = entry.value;

        if (values.isEmpty) continue;

        final avg = getAverageMetric(metricName);
        final min = getMinMetric(metricName);
        final max = getMaxMetric(metricName);

        buffer.writeln('$metricName:');
        buffer.writeln('  Average: ${avg.toStringAsFixed(2)}ms');
        buffer.writeln('  Min: ${min.toStringAsFixed(2)}ms');
        buffer.writeln('  Max: ${max.toStringAsFixed(2)}ms');
        buffer.writeln('  Samples: ${values.length}');
        buffer.writeln();
      }
    }

    // Frame metrics
    if (_frameDurations.isNotEmpty) {
      buffer.writeln('--- FRAME METRICS ---');
      buffer.writeln('Average FPS: ${getAverageFrameRate().toStringAsFixed(2)}');
      buffer.writeln('Dropped Frames: $_droppedFrames (${getDroppedFramePercentage().toStringAsFixed(2)}%)');
      buffer.writeln('Total Frames: ${_frameDurations.length}');
      buffer.writeln();
    }

    // Memory metrics
    if (_memoryUsage.isNotEmpty) {
      buffer.writeln('--- MEMORY METRICS ---');
      buffer.writeln('Average Memory Usage: ${getAverageMemoryUsageMB().toStringAsFixed(2)} MB');
      buffer.writeln('Max Memory Usage: ${getMaxMemoryUsageMB().toStringAsFixed(2)} MB');
      buffer.writeln('Samples: ${_memoryUsage.length}');
      buffer.writeln();
    }

    buffer.writeln('=========================');

    return buffer.toString();
  }
}
