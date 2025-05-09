import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/screens/dashboard/widgets/quick_actions_panel.dart';

void main() {
  testWidgets('QuickActionsPanel displays all required buttons', (WidgetTester tester) async {

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActionsPanel(
            onAddGear: () {},
            onOpenBookingPanel: () {},
            onManageMembers: () {},
            onManageProjects: () {},
            onManageGear: () {},
          ),
        ),
      ),
    );

    // Verify that the panel title is displayed
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify that all required buttons are displayed
    expect(find.text('Add Gear'), findsOneWidget);
    expect(find.text('Open Booking Panel'), findsOneWidget);
    expect(find.text('Manage Members'), findsOneWidget);
    expect(find.text('Manage Projects'), findsOneWidget);
    expect(find.text('Manage Gear'), findsOneWidget);

    // Verify that optional buttons are not displayed
    expect(find.text('Manage Studios'), findsNothing);
    expect(find.text('Export Logs'), findsNothing);
  });

  testWidgets('QuickActionsPanel displays optional buttons when callbacks are provided', (WidgetTester tester) async {

    // Build the widget with optional callbacks
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActionsPanel(
            onAddGear: () {},
            onOpenBookingPanel: () {},
            onManageMembers: () {},
            onManageProjects: () {},
            onManageGear: () {},
            onManageStudios: () {},
            onExportLogs: () {},
          ),
        ),
      ),
    );

    // Verify that optional buttons are displayed
    expect(find.text('Manage Studios'), findsOneWidget);
    expect(find.text('Export Logs'), findsOneWidget);
  });

  testWidgets('QuickActionsPanel buttons call the correct callbacks', (WidgetTester tester) async {
    // Create mock callbacks
    bool addGearCalled = false;
    bool openBookingPanelCalled = false;
    bool manageMembersCalled = false;
    bool manageProjectsCalled = false;
    bool manageGearCalled = false;
    bool manageStudiosCalled = false;
    bool exportLogsCalled = false;

    // Build the widget with all callbacks
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickActionsPanel(
              onAddGear: () { addGearCalled = true; },
              onOpenBookingPanel: () { openBookingPanelCalled = true; },
              onManageMembers: () { manageMembersCalled = true; },
              onManageProjects: () { manageProjectsCalled = true; },
              onManageGear: () { manageGearCalled = true; },
              onManageStudios: () { manageStudiosCalled = true; },
              onExportLogs: () { exportLogsCalled = true; },
            ),
          ),
        ),
      ),
    );

    // Tap each button and verify that the correct callback is called
    await tester.tap(find.text('Add Gear'));
    await tester.pump();
    expect(addGearCalled, true);

    await tester.tap(find.text('Open Booking Panel'));
    await tester.pump();
    expect(openBookingPanelCalled, true);

    await tester.tap(find.text('Manage Members'));
    await tester.pump();
    expect(manageMembersCalled, true);

    await tester.tap(find.text('Manage Projects'));
    await tester.pump();
    expect(manageProjectsCalled, true);

    await tester.tap(find.text('Manage Gear'));
    await tester.pump();
    expect(manageGearCalled, true);

    await tester.tap(find.text('Manage Studios'));
    await tester.pump();
    expect(manageStudiosCalled, true);

    await tester.tap(find.text('Export Logs'));
    await tester.pump();
    expect(exportLogsCalled, true);
  });

  testWidgets('QuickActionsPanel has correct styling', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActionsPanel(
            onAddGear: () {},
            onOpenBookingPanel: () {},
            onManageMembers: () {},
            onManageProjects: () {},
            onManageGear: () {},
          ),
        ),
      ),
    );

    // Verify that the panel title is displayed
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify that the icon is displayed
    expect(find.byIcon(Icons.flash_on), findsOneWidget);

    // Verify that all buttons have the correct icons
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.videocam), findsOneWidget);
  });
}
