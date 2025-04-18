# BLKWDS Manager Testing Checklist

This document provides a comprehensive checklist for testing the BLKWDS Manager application. It covers unit tests, widget tests, and integration tests, with specific guidelines for each component type.

## Table of Contents

1. [General Testing Guidelines](#general-testing-guidelines)
2. [Unit Testing Checklist](#unit-testing-checklist)
3. [Widget Testing Checklist](#widget-testing-checklist)
4. [Integration Testing Checklist](#integration-testing-checklist)
5. [Test Coverage Checklist](#test-coverage-checklist)
6. [Test Maintenance Checklist](#test-maintenance-checklist)

## General Testing Guidelines

### Test Structure

- [ ] Use descriptive test names that explain what is being tested
- [ ] Group related tests using the `group` function
- [ ] Use `setUp` and `tearDown` for common test setup and cleanup
- [ ] Keep tests independent of each other
- [ ] Test one concept per test
- [ ] Use clear assertions with descriptive failure messages

### Test Data

- [ ] Use factory methods or helper functions for creating test data
- [ ] Keep test data realistic but minimal
- [ ] Avoid hardcoding test data when possible
- [ ] Clean up test data after tests complete

### Mocking

- [ ] Mock external dependencies to isolate the unit under test
- [ ] Document mock behavior clearly
- [ ] Use consistent mocking patterns across tests
- [ ] Verify mock interactions when appropriate

## Unit Testing Checklist

### Models

- [ ] Test constructors create instances with correct values
- [ ] Test `fromMap` and `toMap` methods work correctly
- [ ] Test equality and comparison methods
- [ ] Test validation methods
- [ ] Test any business logic methods
- [ ] Test edge cases (null values, empty strings, etc.)

#### Example:

```dart
test('Member.fromMap creates instance from map correctly', () {
  final map = {
    'id': 1,
    'name': 'Test User',
    'role': 'Tester',
  };

  final member = Member.fromMap(map);

  expect(member.id, 1);
  expect(member.name, 'Test User');
  expect(member.role, 'Tester');
});
```

### Services

- [ ] Test CRUD operations
- [ ] Test error handling and recovery
- [ ] Test edge cases and boundary conditions
- [ ] Test retry mechanisms
- [ ] Test transaction handling
- [ ] Test service initialization and cleanup

#### Example:

```dart
test('should insert a member successfully', () async {
  // Arrange
  final member = TestData.createTestMember(
    name: 'John Doe',
    role: 'Developer',
  );

  // Act
  final id = await DBService.insertMember(member);

  // Assert
  expect(id, isPositive);

  // Verify the member was inserted
  final result = await db.query('member', where: 'id = ?', whereArgs: [id]);
  expect(result, isNotEmpty);
  expect(result.first['name'], equals('John Doe'));
  expect(result.first['role'], equals('Developer'));
});
```

### Controllers

- [ ] Test initialization and state setup
- [ ] Test data loading and error handling
- [ ] Test state updates and notifications
- [ ] Test user interaction handling
- [ ] Test navigation and routing
- [ ] Test error handling and recovery
- [ ] Test controller disposal and cleanup

#### Example:

```dart
test('should update filtered bookings when filter changes', () async {
  // Arrange
  final controller = BookingPanelController();
  await controller.initialize();
  
  // Initial state
  expect(controller.filteredBookingList.value.length, equals(controller.bookingList.value.length));
  
  // Act - Apply a filter
  final filter = BookingFilter(projectId: 1);
  controller.updateFilter(filter);
  
  // Assert
  expect(controller.filteredBookingList.value.length, lessThan(controller.bookingList.value.length));
  expect(controller.filteredBookingList.value.every((b) => b.projectId == 1), isTrue);
});
```

### Utilities

- [ ] Test utility functions with various inputs
- [ ] Test edge cases and boundary conditions
- [ ] Test error handling
- [ ] Test performance for critical utilities

#### Example:

```dart
test('should format date correctly', () {
  // Arrange
  final date = DateTime(2025, 7, 3);
  
  // Act
  final result = DateUtils.formatDate(date);
  
  // Assert
  expect(result, equals('July 3, 2025'));
});
```

## Widget Testing Checklist

### Basic Widget Tests

- [ ] Test widget renders correctly
- [ ] Test widget displays correct initial state
- [ ] Test widget responds to state changes
- [ ] Test widget layout and appearance
- [ ] Test widget accessibility (semantics, contrast, etc.)

#### Example:

```dart
testWidgets('Dashboard screen renders title correctly', (WidgetTester tester) async {
  // Build the dashboard screen
  await tester.pumpWidget(
    const MaterialApp(
      home: DashboardScreen(),
    ),
  );

  // Verify that the app title is displayed
  expect(find.text('BLKWDS Manager'), findsOneWidget);
});
```

### Interactive Widget Tests

- [ ] Test widget responds to user interactions (tap, swipe, etc.)
- [ ] Test form inputs and validation
- [ ] Test button actions and callbacks
- [ ] Test navigation and routing
- [ ] Test error states and loading indicators
- [ ] Test empty states and placeholders

#### Example:

```dart
testWidgets('QuickActionsPanel calls callbacks when buttons are tapped', (WidgetTester tester) async {
  // Arrange
  bool addGearCalled = false;
  bool openBookingPanelCalled = false;
  
  // Build the widget
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: QuickActionsPanel(
          onAddGear: () { addGearCalled = true; },
          onOpenBookingPanel: () { openBookingPanelCalled = true; },
          onManageMembers: () {},
          onManageProjects: () {},
          onManageGear: () {},
        ),
      ),
    ),
  );

  // Act - Tap the Add Gear button
  await tester.tap(find.text('Add Gear'));
  await tester.pumpAndSettle();
  
  // Assert
  expect(addGearCalled, isTrue);
  
  // Act - Tap the Open Booking Panel button
  await tester.tap(find.text('Open Booking Panel'));
  await tester.pumpAndSettle();
  
  // Assert
  expect(openBookingPanelCalled, isTrue);
});
```

### Complex Widget Tests

- [ ] Test widget with mock controllers and services
- [ ] Test widget with various data scenarios
- [ ] Test widget state management
- [ ] Test widget error handling
- [ ] Test widget performance
- [ ] Test widget interactions with other widgets

#### Example:

```dart
testWidgets('GearPreviewList filters gear items correctly', (WidgetTester tester) async {
  // Arrange
  final mockController = MockDashboardController();
  when(mockController.gearList).thenReturn(ValueNotifier<List<Gear>>([
    Gear(id: 1, name: 'Camera 1', category: 'Camera', isOut: true),
    Gear(id: 2, name: 'Camera 2', category: 'Camera', isOut: false),
  ]));
  
  // Build the widget
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GearPreviewList(controller: mockController),
      ),
    ),
  );
  
  // Verify initial state - all gear visible
  expect(find.text('Camera 1'), findsOneWidget);
  expect(find.text('Camera 2'), findsOneWidget);
  
  // Act - Filter to show only checked out gear
  await tester.tap(find.text('Checked Out'));
  await tester.pumpAndSettle();
  
  // Assert - Only checked out gear visible
  expect(find.text('Camera 1'), findsOneWidget);
  expect(find.text('Camera 2'), findsNothing);
});
```

## Integration Testing Checklist

### Basic Integration Tests

- [ ] Test app launches and initializes correctly
- [ ] Test navigation between main screens
- [ ] Test basic user flows
- [ ] Test app state persistence
- [ ] Test app error handling and recovery

#### Example:

```dart
testWidgets('Verify app launches and dashboard loads', (WidgetTester tester) async {
  // Start the app
  app.main();
  await tester.pumpAndSettle();

  // Verify that the app title is displayed
  expect(find.text('BLKWDS Manager'), findsOneWidget);

  // Verify that the dashboard is loaded
  expect(find.text('Quick Actions'), findsOneWidget);
  expect(find.text('Recent Gear Activity'), findsOneWidget);
});
```

### Critical User Flow Tests

- [ ] Test gear check-in/check-out flow
- [ ] Test booking creation and management flow
- [ ] Test project management flow
- [ ] Test member management flow
- [ ] Test settings and data export flow
- [ ] Test error handling and recovery in user flows

#### Example:

```dart
testWidgets('Complete gear check-out and check-in flow', (WidgetTester tester) async {
  // Start the app
  app.main();
  await tester.pumpAndSettle();

  // Prepare test data
  await _prepareTestData();

  // Wait for the dashboard to load
  await IntegrationTestHelpers.waitForAppStability(tester);

  // Select a member from the dropdown
  final dropdownFinder = await IntegrationTestHelpers.findByTypeWithRetry<DropdownButton<Member>>(tester);
  await IntegrationTestHelpers.tapWithRetry(tester, dropdownFinder);
  
  final memberFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Test Member');
  await IntegrationTestHelpers.tapWithRetry(tester, memberFinder.last);

  // Check out the gear
  final checkOutFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Check Out');
  await IntegrationTestHelpers.tapWithRetry(tester, checkOutFinder.first);

  // Add a note in the dialog
  final textFieldFinder = await IntegrationTestHelpers.findByTypeWithRetry<TextField>(tester);
  await IntegrationTestHelpers.enterTextWithRetry(tester, textFieldFinder.last, 'Integration test checkout');

  // Confirm the check-out
  final confirmFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Confirm');
  await IntegrationTestHelpers.tapWithRetry(tester, confirmFinder);

  // Verify the gear status is updated
  final checkInFinder = await IntegrationTestHelpers.findByTextWithRetry(tester, 'Check In');
  expect(checkInFinder, findsOneWidget);

  // Clean up test data
  await _cleanupTestData();
});
```

### Advanced Integration Tests

- [ ] Test app performance under load
- [ ] Test app behavior with large datasets
- [ ] Test app behavior with network connectivity issues
- [ ] Test app behavior with database corruption
- [ ] Test app behavior with low device resources

## Test Coverage Checklist

### Code Coverage

- [ ] Aim for at least 80% code coverage for critical components
- [ ] Aim for at least 70% code coverage for the overall application
- [ ] Identify and document areas with low coverage
- [ ] Prioritize increasing coverage for critical components

### Component Coverage

- [ ] Test all models
- [ ] Test all services
- [ ] Test all controllers
- [ ] Test all screens
- [ ] Test all critical widgets
- [ ] Test all critical user flows

### Edge Case Coverage

- [ ] Test error handling and recovery
- [ ] Test boundary conditions
- [ ] Test with invalid or unexpected inputs
- [ ] Test with empty or null values
- [ ] Test with large datasets
- [ ] Test with resource constraints

## Test Maintenance Checklist

### Test Organization

- [ ] Keep tests organized by type (unit, widget, integration)
- [ ] Keep tests organized by component (models, services, controllers, widgets)
- [ ] Use consistent naming conventions
- [ ] Use consistent test structure
- [ ] Document test requirements and assumptions

### Test Reliability

- [ ] Ensure tests are deterministic (same input always produces same output)
- [ ] Avoid flaky tests (tests that sometimes pass and sometimes fail)
- [ ] Use appropriate timeouts and delays
- [ ] Clean up test data and resources after tests
- [ ] Isolate tests from each other

### Test Performance

- [ ] Keep tests fast (unit tests should run in milliseconds)
- [ ] Optimize slow tests
- [ ] Use appropriate test granularity (unit tests for small units, integration tests for larger flows)
- [ ] Run tests in parallel when possible
- [ ] Use test sharding for large test suites

### Test Documentation

- [ ] Document test requirements and assumptions
- [ ] Document test data and setup
- [ ] Document test coverage goals and achievements
- [ ] Document known limitations and edge cases
- [ ] Document test maintenance procedures

## Specific Component Testing Guidelines

### ValueNotifier Testing

- [ ] Test initial state is correct
- [ ] Test state updates correctly when value changes
- [ ] Test listeners are notified when value changes
- [ ] Test ValueNotifier is disposed properly
- [ ] Test ValueListenableBuilder rebuilds when value changes

#### Example:

```dart
test('ValueNotifier updates and notifies listeners', () {
  // Arrange
  final notifier = ValueNotifier<int>(0);
  int listenerCallCount = 0;
  int? latestValue;
  
  notifier.addListener(() {
    listenerCallCount++;
    latestValue = notifier.value;
  });
  
  // Act
  notifier.value = 1;
  
  // Assert
  expect(listenerCallCount, equals(1));
  expect(latestValue, equals(1));
  
  // Clean up
  notifier.dispose();
});
```

### Controller Testing

- [ ] Test controller initialization
- [ ] Test controller state management
- [ ] Test controller error handling
- [ ] Test controller interaction with services
- [ ] Test controller disposal

#### Example:

```dart
test('Controller initializes state correctly', () async {
  // Arrange
  final mockDBService = MockDBService();
  when(mockDBService.getMembers()).thenAnswer((_) async => [
    Member(id: 1, name: 'Test Member', role: 'Tester'),
  ]);
  
  // Act
  final controller = MemberController(dbService: mockDBService);
  await controller.initialize();
  
  // Assert
  expect(controller.isLoading.value, isFalse);
  expect(controller.members.value.length, equals(1));
  expect(controller.members.value.first.name, equals('Test Member'));
  
  // Clean up
  controller.dispose();
});
```

### Database Service Testing

- [ ] Test database initialization
- [ ] Test CRUD operations
- [ ] Test transaction handling
- [ ] Test error handling and recovery
- [ ] Test database integrity checks
- [ ] Test database migrations

#### Example:

```dart
test('should handle transaction rollback on error', () async {
  // Arrange
  final db = await DBService.getDatabase();
  final initialCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM member'));
  
  // Act & Assert
  expect(() async {
    await DBService.executeTransaction((txn) async {
      // This should succeed
      await txn.insert('member', {'name': 'Test Member', 'role': 'Tester'});
      
      // This should fail and cause rollback
      await txn.insert('non_existent_table', {'column': 'value'});
    });
  }, throwsA(isA<DatabaseException>()));
  
  // Verify transaction was rolled back
  final finalCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM member'));
  expect(finalCount, equals(initialCount)); // Count should not have changed
});
```

## Conclusion

This testing checklist provides a comprehensive guide for testing the BLKWDS Manager application. By following this checklist, you can ensure that your tests are thorough, reliable, and maintainable.

Remember that testing is an ongoing process, and this checklist should be updated as the application evolves and new testing requirements emerge.
