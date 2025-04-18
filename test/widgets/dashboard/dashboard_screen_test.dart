import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_screen.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import 'package:blkwds_manager/services/navigation_service.dart';

// Generate mocks
@GenerateMocks([NavigationService])
void main() {
  // Mock the NavigationService
  late MockNavigationService mockNavigationService;

  setUp(() {
    mockNavigationService = MockNavigationService();
    
    // Replace the NavigationService with our mock
    NavigationService.instance = mockNavigationService;
  });

  testWidgets('DashboardScreen renders correctly when loading', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('DashboardScreen renders error state correctly', (WidgetTester tester) async {
    // Override the DashboardController to return an error
    final originalController = DashboardController();
    DashboardController.override = (context) {
      final controller = DashboardController();
      controller.isLoading.value = false;
      controller.errorMessage.value = 'Test error message';
      return controller;
    };

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    
    // Wait for the widget to rebuild
    await tester.pump();

    // Verify that the error state is displayed
    expect(find.text('Error loading data'), findsOneWidget);
    expect(find.text('Test error message'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Reset the override
    DashboardController.override = null;
  });

  testWidgets('DashboardScreen renders content correctly when data is loaded', (WidgetTester tester) async {
    // Override the DashboardController to return mock data
    DashboardController.override = (context) {
      final controller = DashboardController();
      
      // Set up mock data
      controller.isLoading.value = false;
      controller.errorMessage.value = null;
      
      controller.gearList.value = [
        Gear(id: 1, name: 'Camera 1', category: 'Camera', isOut: true),
        Gear(id: 2, name: 'Microphone 1', category: 'Audio', isOut: false),
      ];
      
      controller.memberList.value = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];
      
      controller.projectList.value = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
      ];
      
      controller.bookingList.value = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime.now(), 
          endDate: DateTime.now().add(const Duration(days: 1)),
          gearIds: [1, 2],
        ),
      ];
      
      controller.recentActivity.value = [
        ActivityLog(
          id: 1,
          action: 'Gear checked out',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          details: {'gearId': 1, 'memberId': 1},
          gearId: 1,
          memberId: 1,
          checkedOut: true,
        ),
      ];
      
      controller.gearOutCount.value = 1;
      controller.bookingsTodayCount.value = 1;
      controller.gearReturningCount.value = 0;
      controller.studioBookingToday.value = null;
      
      return controller;
    };

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    
    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Verify that the main components are displayed
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Recent Gear Activity'), findsOneWidget);
    
    // Verify that the member dropdown is displayed
    expect(find.text('John Doe'), findsOneWidget);
    
    // Verify that the gear items are displayed
    expect(find.text('Camera 1'), findsOneWidget);
    
    // Reset the override
    DashboardController.override = null;
  });

  testWidgets('DashboardScreen navigation buttons work correctly', (WidgetTester tester) async {
    // Override the DashboardController to return mock data
    DashboardController.override = (context) {
      final controller = DashboardController();
      
      // Set up mock data
      controller.isLoading.value = false;
      controller.errorMessage.value = null;
      
      controller.gearList.value = [];
      controller.memberList.value = [Member(id: 1, name: 'John Doe', role: 'Photographer')];
      controller.projectList.value = [];
      controller.bookingList.value = [];
      controller.recentActivity.value = [];
      
      controller.gearOutCount.value = 0;
      controller.bookingsTodayCount.value = 0;
      controller.gearReturningCount.value = 0;
      controller.studioBookingToday.value = null;
      
      return controller;
    };

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    
    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Tap the Calendar button
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pump();
    
    // Verify that the navigation service was called
    verify(mockNavigationService.navigateToCalendar()).called(1);
    
    // Tap the Settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    
    // Verify that the navigation service was called
    verify(mockNavigationService.navigateToSettings()).called(1);
    
    // Reset the override
    DashboardController.override = null;
  });

  testWidgets('DashboardScreen quick action buttons work correctly', (WidgetTester tester) async {
    // Override the DashboardController to return mock data
    DashboardController.override = (context) {
      final controller = DashboardController();
      
      // Set up mock data
      controller.isLoading.value = false;
      controller.errorMessage.value = null;
      
      controller.gearList.value = [];
      controller.memberList.value = [Member(id: 1, name: 'John Doe', role: 'Photographer')];
      controller.projectList.value = [];
      controller.bookingList.value = [];
      controller.recentActivity.value = [];
      
      controller.gearOutCount.value = 0;
      controller.bookingsTodayCount.value = 0;
      controller.gearReturningCount.value = 0;
      controller.studioBookingToday.value = null;
      
      return controller;
    };

    // Mock the NavigationService to return a result for navigateToAddGear
    when(mockNavigationService.navigateToAddGear()).thenAnswer((_) async => true);

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    
    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Tap the Add Gear button
    await tester.tap(find.text('Add Gear'));
    await tester.pump();
    
    // Verify that the navigation service was called
    verify(mockNavigationService.navigateToAddGear()).called(1);
    
    // Tap the Open Booking Panel button
    await tester.tap(find.text('Open Booking Panel'));
    await tester.pump();
    
    // Verify that the navigation service was called
    verify(mockNavigationService.navigateToBookingPanel()).called(1);
    
    // Tap the Manage Members button
    await tester.tap(find.text('Manage Members'));
    await tester.pump();
    
    // Verify that the navigation service was called
    verify(mockNavigationService.navigateToMemberManagement()).called(1);
    
    // Reset the override
    DashboardController.override = null;
  });

  testWidgets('DashboardScreen refresh button works correctly', (WidgetTester tester) async {
    // Override the DashboardController to return mock data
    DashboardController.override = (context) {
      final controller = DashboardController();
      
      // Set up mock data
      controller.isLoading.value = false;
      controller.errorMessage.value = null;
      
      controller.gearList.value = [];
      controller.memberList.value = [Member(id: 1, name: 'John Doe', role: 'Photographer')];
      controller.projectList.value = [];
      controller.bookingList.value = [];
      controller.recentActivity.value = [];
      
      controller.gearOutCount.value = 0;
      controller.bookingsTodayCount.value = 0;
      controller.gearReturningCount.value = 0;
      controller.studioBookingToday.value = null;
      
      // Mock the refreshEssentialData method
      controller.refreshEssentialData = () async {
        // Simulate a successful refresh
        return;
      };
      
      return controller;
    };

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    
    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Tap the refresh button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    
    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for the refresh to complete
    await tester.pumpAndSettle();
    
    // Verify that the loading indicator is no longer displayed
    expect(find.byType(CircularProgressIndicator), findsNothing);
    
    // Reset the override
    DashboardController.override = null;
  });
}
