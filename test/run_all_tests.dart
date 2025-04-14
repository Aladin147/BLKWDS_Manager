import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/models/gear_test.dart' as gear_test;
import 'unit/models/member_test.dart' as member_test;
import 'unit/services/log_service_test.dart' as log_service_test;
import 'unit/services/error_service_test.dart' as error_service_test;
import 'widget/dashboard_test.dart' as dashboard_test;
import 'widget_test.dart' as widget_test;

void main() {
  group('All Tests', () {
    // Run all unit tests
    group('Unit Tests', () {
      // Models
      gear_test.main();
      member_test.main();
      
      // Services
      log_service_test.main();
      error_service_test.main();
    });
    
    // Run all widget tests
    group('Widget Tests', () {
      widget_test.main();
      dashboard_test.main();
    });
  });
}
