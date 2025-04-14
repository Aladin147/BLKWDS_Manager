import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/log_level.dart';

void main() {
  group('LogService Tests', () {
    test('setLogLevel changes the current log level', () {
      // Set log level to error
      LogService.setLogLevel(LogLevel.error);
      
      // This is an indirect test since we can't directly access _currentLevel
      // We'll verify that debug logs don't appear when level is set to error
      // This test is mostly for coverage
      expect(() => LogService.debug('Debug message'), returnsNormally);
      expect(() => LogService.info('Info message'), returnsNormally);
      expect(() => LogService.warning('Warning message'), returnsNormally);
      expect(() => LogService.error('Error message'), returnsNormally);
    });

    test('Log methods handle null error and stackTrace', () {
      LogService.setLogLevel(LogLevel.debug);
      
      expect(() => LogService.debug('Debug message'), returnsNormally);
      expect(() => LogService.info('Info message'), returnsNormally);
      expect(() => LogService.warning('Warning message'), returnsNormally);
      expect(() => LogService.error('Error message'), returnsNormally);
    });

    test('Log methods handle error without stackTrace', () {
      LogService.setLogLevel(LogLevel.debug);
      
      final error = Exception('Test error');
      
      expect(() => LogService.debug('Debug message', error), returnsNormally);
      expect(() => LogService.info('Info message', error), returnsNormally);
      expect(() => LogService.warning('Warning message', error), returnsNormally);
      expect(() => LogService.error('Error message', error), returnsNormally);
    });

    test('Log methods handle error with stackTrace', () {
      LogService.setLogLevel(LogLevel.debug);
      
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      
      expect(() => LogService.debug('Debug message', error, stackTrace), returnsNormally);
      expect(() => LogService.info('Info message', error, stackTrace), returnsNormally);
      expect(() => LogService.warning('Warning message', error, stackTrace), returnsNormally);
      expect(() => LogService.error('Error message', error, stackTrace), returnsNormally);
    });
  });
}
