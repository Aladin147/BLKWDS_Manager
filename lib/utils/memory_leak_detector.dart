import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/log_service.dart';
import '../services/navigation_helper.dart';
import 'performance_monitor.dart';

/// MemoryLeakDetector
/// A utility class for detecting memory leaks
class MemoryLeakDetector {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  
  // Test scenarios
  final List<String> _testScenarios = [
    'navigation_cycle',
    'data_loading',
    'widget_creation',
  ];
  
  // Navigation test destinations for cycling
  final List<String> _navigationCycleDestinations = [
    'dashboard',
    'gear_list',
    'member_list',
    'project_list',
    'booking_panel',
    'calendar',
    'settings',
  ];
  
  /// Run all memory leak tests
  Future<String> runAllTests(BuildContext context) async {
    _performanceMonitor.resetAllMetrics();
    
    LogService.info('Starting memory leak tests');
    
    // Start memory monitoring
    _performanceMonitor.startMemoryMonitoring(interval: const Duration(seconds: 2));
    
    for (final scenario in _testScenarios) {
      await _runTestScenario(scenario, context);
    }
    
    // Stop memory monitoring
    _performanceMonitor.stopMemoryMonitoring();
    
    final report = _performanceMonitor.generateReport();
    LogService.info('Memory leak tests completed');
    LogService.debug(report);
    
    return report;
  }
  
  /// Run a specific test scenario
  Future<void> _runTestScenario(String scenario, BuildContext context) async {
    LogService.debug('Running memory leak test scenario: $scenario');
    
    switch (scenario) {
      case 'navigation_cycle':
        await _testNavigationCycle(context);
        break;
      case 'data_loading':
        await _testDataLoading(context);
        break;
      case 'widget_creation':
        await _testWidgetCreation(context);
        break;
      default:
        LogService.error('Unknown test scenario: $scenario');
    }
  }
  
  /// Test navigation cycle for memory leaks
  Future<void> _testNavigationCycle(BuildContext context) async {
    LogService.debug('Testing navigation cycle for memory leaks');
    
    // Capture initial memory
    final initialMemory = developer.getMemoryInfo().heapUsage;
    
    // Perform multiple navigation cycles
    for (int cycle = 0; cycle < 5; cycle++) {
      LogService.debug('Navigation cycle $cycle');
      
      for (final destination in _navigationCycleDestinations) {
        // Navigate to destination
        await _navigateTo(destination, context);
        
        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Force garbage collection if possible
      developer.collectAllGarbage();
      
      // Wait for GC to complete
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Capture final memory
    final finalMemory = developer.getMemoryInfo().heapUsage;
    
    // Calculate memory growth
    final memoryGrowth = finalMemory - initialMemory;
    final memoryGrowthMB = memoryGrowth / (1024 * 1024);
    
    LogService.debug('Navigation cycle memory growth: ${memoryGrowthMB.toStringAsFixed(2)} MB');
    
    // Add a custom metric for memory growth
    _performanceMonitor._metrics['navigation_cycle_memory_growth'] = [memoryGrowthMB];
  }
  
  /// Test data loading for memory leaks
  Future<void> _testDataLoading(BuildContext context) async {
    LogService.debug('Testing data loading for memory leaks');
    
    // Navigate to screens with data loading
    final dataLoadingScreens = ['gear_list', 'member_list', 'project_list', 'booking_panel'];
    
    // Capture initial memory
    final initialMemory = developer.getMemoryInfo().heapUsage;
    
    // Perform multiple data loading cycles
    for (int cycle = 0; cycle < 5; cycle++) {
      LogService.debug('Data loading cycle $cycle');
      
      for (final screen in dataLoadingScreens) {
        // Navigate to screen
        await _navigateTo(screen, context);
        
        // Wait for data to load
        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate back
        await _navigateBack(context);
        
        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Force garbage collection if possible
      developer.collectAllGarbage();
      
      // Wait for GC to complete
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Capture final memory
    final finalMemory = developer.getMemoryInfo().heapUsage;
    
    // Calculate memory growth
    final memoryGrowth = finalMemory - initialMemory;
    final memoryGrowthMB = memoryGrowth / (1024 * 1024);
    
    LogService.debug('Data loading memory growth: ${memoryGrowthMB.toStringAsFixed(2)} MB');
    
    // Add a custom metric for memory growth
    _performanceMonitor._metrics['data_loading_memory_growth'] = [memoryGrowthMB];
  }
  
  /// Test widget creation for memory leaks
  Future<void> _testWidgetCreation(BuildContext context) async {
    LogService.debug('Testing widget creation for memory leaks');
    
    // Navigate to the dashboard
    await _navigateTo('dashboard', context);
    
    // Capture initial memory
    final initialMemory = developer.getMemoryInfo().heapUsage;
    
    // Perform multiple widget creation cycles
    for (int cycle = 0; cycle < 10; cycle++) {
      LogService.debug('Widget creation cycle $cycle');
      
      // Navigate to booking panel (which creates many widgets)
      await _navigateTo('booking_panel', context);
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate back
      await _navigateBack(context);
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force garbage collection if possible
      developer.collectAllGarbage();
      
      // Wait for GC to complete
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Capture final memory
    final finalMemory = developer.getMemoryInfo().heapUsage;
    
    // Calculate memory growth
    final memoryGrowth = finalMemory - initialMemory;
    final memoryGrowthMB = memoryGrowth / (1024 * 1024);
    
    LogService.debug('Widget creation memory growth: ${memoryGrowthMB.toStringAsFixed(2)} MB');
    
    // Add a custom metric for memory growth
    _performanceMonitor._metrics['widget_creation_memory_growth'] = [memoryGrowthMB];
  }
  
  /// Navigate to a specific destination
  Future<void> _navigateTo(String destination, BuildContext context) async {
    switch (destination) {
      case 'dashboard':
        NavigationHelper.navigateToDashboard();
        break;
      case 'gear_list':
        NavigationHelper.navigateToGearList();
        break;
      case 'member_list':
        NavigationHelper.navigateToMemberList();
        break;
      case 'project_list':
        NavigationHelper.navigateToProjectList();
        break;
      case 'booking_panel':
        NavigationHelper.navigateToBookingPanel();
        break;
      case 'calendar':
        NavigationHelper.navigateToCalendar();
        break;
      case 'settings':
        NavigationHelper.navigateToSettings();
        break;
      default:
        LogService.error('Unknown destination: $destination');
    }
    
    // Wait for navigation to complete
    await Future.delayed(const Duration(milliseconds: 300));
  }
  
  /// Navigate back to the dashboard
  Future<void> _navigateBack(BuildContext context) async {
    NavigationHelper.navigateToDashboard();
    
    // Wait for navigation to complete
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
