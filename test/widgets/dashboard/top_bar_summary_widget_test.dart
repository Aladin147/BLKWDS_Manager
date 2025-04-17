import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import 'package:blkwds_manager/screens/dashboard/widgets/top_bar_summary_widget.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';

// Generate mocks
@GenerateMocks([DashboardController])
void main() {
  late MockDashboardController mockController;

  setUp(() {
    mockController = MockDashboardController();
    
    // Set up the ValueNotifiers in the mock controller
    when(mockController.gearOutCount).thenReturn(ValueNotifier<int>(5));
    when(mockController.bookingsTodayCount).thenReturn(ValueNotifier<int>(3));
    when(mockController.gearReturningCount).thenReturn(ValueNotifier<int>(2));
    when(mockController.studioBookingToday).thenReturn(ValueNotifier<Booking?>(null));
  });

  testWidgets('TopBarSummaryWidget displays correct statistics', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopBarSummaryWidget(
            controller: mockController,
          ),
        ),
      ),
    );

    // Verify that the statistics are displayed correctly
    expect(find.text('Gear Out'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);

    expect(find.text('Bookings Today'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    expect(find.text('Gear Returning'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);

    expect(find.text('Studio:'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsOneWidget);
  });

  testWidgets('TopBarSummaryWidget updates when statistics change', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopBarSummaryWidget(
            controller: mockController,
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Update the statistics
    mockController.gearOutCount.value = 10;
    mockController.bookingsTodayCount.value = 6;
    mockController.gearReturningCount.value = 4;

    // Rebuild the widget
    await tester.pump();

    // Verify that the statistics have been updated
    expect(find.text('10'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('TopBarSummaryWidget displays studio booking correctly', (WidgetTester tester) async {
    // Create a mock studio booking
    final mockBooking = Booking(
      id: 1,
      projectId: 2,
      startDate: DateTime(2023, 1, 1, 9, 0), // 9:00 AM
      endDate: DateTime(2023, 1, 1, 17, 0),   // 5:00 PM
      gearIds: [1, 2, 3],
    );

    // Update the mock controller
    when(mockController.studioBookingToday).thenReturn(ValueNotifier<Booking?>(mockBooking));

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopBarSummaryWidget(
            controller: mockController,
          ),
        ),
      ),
    );

    // Verify that the studio booking is displayed correctly
    expect(find.text('Studio:'), findsOneWidget);
    expect(find.text('BOOKED'), findsOneWidget);
    expect(find.text('9:00 AM – 5:00 PM'), findsOneWidget);
  });

  testWidgets('TopBarSummaryWidget has correct colors and styling', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopBarSummaryWidget(
            controller: mockController,
          ),
        ),
      ),
    );

    // Find the container
    final container = tester.widget<Container>(find.byType(Container).first);
    
    // Verify the container decoration
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, BLKWDSColors.backgroundDark);

    // Find the summary cards
    final cards = tester.widgetList<Card>(find.byType(Card));
    expect(cards.length, 4); // 4 summary cards
  });
}
