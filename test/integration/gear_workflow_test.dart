import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/gear.dart';
import 'package:blkwds_manager/models/member.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/screens/gear/gear_list_screen.dart';
import 'package:blkwds_manager/controllers/gear_controller.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/snackbar_service.dart';

@GenerateMocks([DBService, ErrorService, ContextualErrorHandler, SnackbarService])
import 'gear_workflow_test.mocks.dart';

void main() {
  group('Gear Check-in/out Workflow', () {
    late MockDBService mockDBService;
    late MockErrorService mockErrorService;
    late MockContextualErrorHandler mockErrorHandler;
    late MockSnackbarService mockSnackbarService;
    late GearController gearController;
    
    setUp(() {
      mockDBService = MockDBService();
      mockErrorService = MockErrorService();
      mockErrorHandler = MockContextualErrorHandler();
      mockSnackbarService = MockSnackbarService();
      
      gearController = GearController(
        dbService: mockDBService,
        errorService: mockErrorService,
        errorHandler: mockErrorHandler,
        snackbarService: mockSnackbarService,
      );
      
      // Mock gear list
      final gearList = [
        Gear(
          id: '1',
          name: 'Test Gear 1',
          category: 'Camera',
          status: GearStatus.available,
          serialNumber: 'SN12345',
          notes: 'Test notes',
          lastCheckedOut: null,
          lastCheckedIn: null,
          checkedOutBy: null,
        ),
        Gear(
          id: '2',
          name: 'Test Gear 2',
          category: 'Lens',
          status: GearStatus.available,
          serialNumber: 'SN67890',
          notes: 'Test notes 2',
          lastCheckedOut: null,
          lastCheckedIn: null,
          checkedOutBy: null,
        ),
      ];
      
      // Mock member
      final member = Member(
        id: '1',
        name: 'Test Member',
        email: 'test@example.com',
        phone: '123-456-7890',
        status: MemberStatus.active,
      );
      
      // Setup mock responses
      when(mockDBService.getGearList()).thenAnswer((_) async => gearList);
      when(mockDBService.getMemberById('1')).thenAnswer((_) async => member);
      
      // Mock successful gear checkout
      when(mockDBService.checkoutGear(any, any)).thenAnswer((_) async => true);
      when(mockDBService.checkinGear(any)).thenAnswer((_) async => true);
    });
    
    testWidgets('should display gear list and allow checkout', (WidgetTester tester) async {
      // Arrange - build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: GearListScreen(
            gearController: gearController,
          ),
        ),
      );
      
      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Assert - verify gear items are displayed
      expect(find.text('Test Gear 1'), findsOneWidget);
      expect(find.text('Test Gear 2'), findsOneWidget);
      
      // Act - tap on the first gear item to open details
      await tester.tap(find.text('Test Gear 1'));
      await tester.pumpAndSettle();
      
      // Assert - verify gear details are displayed
      expect(find.text('SN12345'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
      
      // Verify checkout button is available
      expect(find.textContaining('Check Out'), findsOneWidget);
      
      // Act - tap checkout button
      await tester.tap(find.textContaining('Check Out'));
      await tester.pumpAndSettle();
      
      // Verify checkout was called
      verify(mockDBService.checkoutGear(any, any)).called(1);
      
      // Verify success message was shown
      verify(mockSnackbarService.showSuccess(any, any)).called(1);
    });
    
    testWidgets('should allow checking in gear', (WidgetTester tester) async {
      // Arrange - create checked out gear
      final checkedOutGear = Gear(
        id: '3',
        name: 'Checked Out Gear',
        category: 'Audio',
        status: GearStatus.checkedOut,
        serialNumber: 'SN54321',
        notes: 'Checked out gear',
        lastCheckedOut: DateTime.now(),
        lastCheckedIn: null,
        checkedOutBy: '1', // Member ID
      );
      
      // Mock the checked out gear
      when(mockDBService.getGearList()).thenAnswer((_) async => [checkedOutGear]);
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: GearListScreen(
            gearController: gearController,
          ),
        ),
      );
      
      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Assert - verify checked out gear is displayed
      expect(find.text('Checked Out Gear'), findsOneWidget);
      
      // Act - tap on the gear item to open details
      await tester.tap(find.text('Checked Out Gear'));
      await tester.pumpAndSettle();
      
      // Assert - verify gear details are displayed
      expect(find.text('SN54321'), findsOneWidget);
      expect(find.text('Checked out gear'), findsOneWidget);
      
      // Verify check-in button is available
      expect(find.textContaining('Check In'), findsOneWidget);
      
      // Act - tap check-in button
      await tester.tap(find.textContaining('Check In'));
      await tester.pumpAndSettle();
      
      // Verify check-in was called
      verify(mockDBService.checkinGear(any)).called(1);
      
      // Verify success message was shown
      verify(mockSnackbarService.showSuccess(any, any)).called(1);
    });
  });
}
