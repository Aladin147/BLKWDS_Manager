import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import 'package:blkwds_manager/screens/dashboard/widgets/gear_preview_list_widget.dart';

// Import test helpers
import '../../helpers/test_database_helper.dart';

// Create a mock DashboardController
class MockDashboardController extends Mock implements DashboardController {
  @override
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  @override
  final ValueNotifier<List<ActivityLog>> recentActivity = ValueNotifier<List<ActivityLog>>([]);
}

void main() {
  late MockDashboardController mockController;
  late Function(Gear, String?) mockOnCheckout;
  late Function(Gear, String?) mockOnReturn;
  late VoidCallback mockOnViewAllGear;

  setUpAll(() {
    // Initialize the database for tests
    TestDatabaseHelper.initializeDatabase();
  });

  setUp(() {
    mockController = MockDashboardController();
    mockOnCheckout = (gear, note) {};
    mockOnReturn = (gear, note) {};
    mockOnViewAllGear = () {};

    // Set up the ValueNotifiers in the mock controller
    final mockGearList = [
      Gear(id: 1, name: 'Camera 1', category: 'Camera', isOut: true),
      Gear(id: 2, name: 'Microphone 1', category: 'Audio', isOut: false),
      Gear(id: 3, name: 'Tripod 1', category: 'Support', isOut: true),
      Gear(id: 4, name: 'Light 1', category: 'Lighting', isOut: false),
      Gear(id: 5, name: 'Camera 2', category: 'Camera', isOut: false),
    ];

    final mockActivityLogs = [
      ActivityLog(
        id: 1,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        gearId: 1,
        memberId: 1,
        checkedOut: true,
        note: 'Gear checked out',
      ),
      ActivityLog(
        id: 2,
        timestamp: DateTime.now().subtract(const Duration(hours: 25)), // Overdue
        gearId: 3,
        memberId: 2,
        checkedOut: true,
        note: 'Gear checked out',
      ),
    ];

    // Set the mock data
    mockController.gearList.value = mockGearList;
    mockController.recentActivity.value = mockActivityLogs;
  });

  testWidgets('GearPreviewListWidget displays gear list correctly', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: GearPreviewListWidget(
              controller: mockController,
              onCheckout: mockOnCheckout,
              onReturn: mockOnReturn,
              onViewAllGear: mockOnViewAllGear,
            ),
          ),
        ),
      ),
    );

    // Verify that the widget renders correctly
    expect(find.text('Recent Gear Activity'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);

    // Verify filter chips
    expect(find.text('All Gear'), findsOneWidget);
    expect(find.text('Checked Out'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);

    // Verify at least one gear item is visible
    expect(find.text('Camera 1'), findsOneWidget);

    // Verify overdue warning is displayed
    expect(find.text('OVERDUE GEAR: CHECKED OUT FOR 24+ HOURS'), findsOneWidget);
  });

  testWidgets('GearPreviewListWidget filters gear correctly', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: GearPreviewListWidget(
              controller: mockController,
              onCheckout: mockOnCheckout,
              onReturn: mockOnReturn,
              onViewAllGear: mockOnViewAllGear,
            ),
          ),
        ),
      ),
    );

    // Verify initial state (All Gear)
    expect(find.text('Camera 1'), findsOneWidget);

    // Tap on "Checked Out" filter
    await tester.tap(find.text('Checked Out'));
    await tester.pump();

    // Verify that checked out gear is displayed
    expect(find.text('Camera 1'), findsOneWidget);

    // Tap on "Available" filter
    await tester.tap(find.text('Available'));
    await tester.pump();

    // Verify that available gear is displayed
    expect(find.text('Microphone 1'), findsOneWidget);

    // Tap on "All Gear" filter to go back to initial state
    await tester.tap(find.text('All Gear'));
    await tester.pump();

    // Verify that gear is displayed again
    expect(find.text('Camera 1'), findsOneWidget);
  });

  testWidgets('GearPreviewListWidget handles empty gear list', (WidgetTester tester) async {
    // Update the mock controller to return an empty gear list
    mockController.gearList.value = [];

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: GearPreviewListWidget(
              controller: mockController,
              onCheckout: mockOnCheckout,
              onReturn: mockOnReturn,
              onViewAllGear: mockOnViewAllGear,
            ),
          ),
        ),
      ),
    );

    // Verify that the empty state message is displayed
    expect(find.text('No recent gear activity'), findsOneWidget);
  });

  testWidgets('GearPreviewListWidget calls onViewAllGear when View All button is pressed', (WidgetTester tester) async {
    // Create a mock callback that tracks if it was called
    bool viewAllCalled = false;
    mockOnViewAllGear = () {
      viewAllCalled = true;
    };

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: GearPreviewListWidget(
              controller: mockController,
              onCheckout: mockOnCheckout,
              onReturn: mockOnReturn,
              onViewAllGear: mockOnViewAllGear,
            ),
          ),
        ),
      ),
    );

    // Tap the View All button
    await tester.tap(find.text('View All'));
    await tester.pump();

    // Verify that the callback was called
    expect(viewAllCalled, true);
  });

  testWidgets('GearPreviewListWidget does not show overdue warning when no gear is overdue', (WidgetTester tester) async {
    // Update the mock controller to return activity logs with no overdue gear
    final mockActivityLogs = [
      ActivityLog(
        id: 1,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        gearId: 1,
        memberId: 1,
        checkedOut: true,
        note: 'Gear checked out',
      ),
      ActivityLog(
        id: 2,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        gearId: 3,
        memberId: 2,
        checkedOut: true,
        note: 'Gear checked out',
      ),
    ];

    mockController.recentActivity.value = mockActivityLogs;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: GearPreviewListWidget(
              controller: mockController,
              onCheckout: mockOnCheckout,
              onReturn: mockOnReturn,
              onViewAllGear: mockOnViewAllGear,
            ),
          ),
        ),
      ),
    );

    // Verify that the overdue warning is not displayed
    expect(find.text('OVERDUE GEAR: CHECKED OUT FOR 24+ HOURS'), findsNothing);
  });
}
