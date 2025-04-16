# Navigation Standardization Implementation Plan

This document outlines the detailed plan for standardizing navigation throughout the BLKWDS Manager application and implementing proper functionality for "View All" buttons.

## 1. Current State Analysis

### 1.1 Navigation Approaches in Use

The application currently uses multiple approaches to navigation:

1. **Direct Navigator Usage**:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => SomeScreen()),
   );
   ```

2. **Partial NavigationService Usage**:
   ```dart
   NavigationService().navigateTo(SomeScreen());
   ```

3. **Snackbar Messages Instead of Navigation**:
   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('View all would open here')),
   );
   ```

### 1.2 "View All" Button Implementations

| Location | Current Implementation | Issue |
|----------|------------------------|-------|
| Today's Bookings | Shows snackbar | No actual navigation |
| Recent Activity | Direct Navigator.push | Inconsistent with service approach |
| Gear Preview List | Custom method call | May not use navigation service |
| Studio List | Various implementations | Inconsistent approaches |

## 2. Implementation Plan

### 2.1 Standardize NavigationService

1. **Review and Update NavigationService**:
   - Ensure it supports all required navigation patterns
   - Add support for named routes
   - Implement consistent transition animations
   - Add support for passing parameters

2. **Define Named Routes**:
   - Create a routes.dart file with all application routes
   - Define constants for route names
   - Implement route generation function

3. **Update App Initialization**:
   - Configure the app to use the route system
   - Set up initial route handling

### 2.2 Update "View All" Buttons

1. **Today's Bookings Widget**:
   - Update the "View All" button to navigate to the Bookings screen
   - Pass filter parameter for today's date
   - Use NavigationService for consistency

2. **Recent Activity Widget**:
   - Replace direct Navigator.push with NavigationService
   - Ensure proper parameters are passed to the Activity Log screen

3. **Gear Preview List**:
   - Update the onViewAllGear callback to use NavigationService
   - Navigate to the Gear Management screen with appropriate filters

4. **Studio List**:
   - Implement proper navigation to Studio Management screen
   - Use NavigationService consistently

### 2.3 Standardize Other Navigation

1. **Audit All Navigation Code**:
   - Identify all instances of direct Navigator usage
   - Create a list of screens that need updating

2. **Update Each Screen**:
   - Replace direct Navigator usage with NavigationService
   - Ensure consistent transition animations
   - Update parameter passing as needed

3. **Handle Back Navigation**:
   - Ensure proper back navigation behavior
   - Implement confirmation dialogs where needed

## 3. Implementation Steps

### 3.1 NavigationService Updates

1. **Review Current Implementation**:
   - Examine the current NavigationService
   - Identify missing features or inconsistencies

2. **Enhance NavigationService**:
   ```dart
   class NavigationService {
     static final NavigationService _instance = NavigationService._internal();
     final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
     
     factory NavigationService() => _instance;
     NavigationService._internal();
     
     Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
       return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
     }
     
     Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
       return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
     }
     
     void goBack() {
       return navigatorKey.currentState!.pop();
     }
     
     // Add more navigation methods as needed
   }
   ```

3. **Create Routes Configuration**:
   ```dart
   class AppRoutes {
     static const String dashboard = '/dashboard';
     static const String bookings = '/bookings';
     static const String gearManagement = '/gear';
     static const String activityLog = '/activity';
     static const String studioManagement = '/studios';
     // Add more routes as needed
     
     static Route<dynamic> generateRoute(RouteSettings settings) {
       switch (settings.name) {
         case dashboard:
           return MaterialPageRoute(builder: (_) => DashboardScreen());
         case bookings:
           return MaterialPageRoute(builder: (_) => BookingPanelScreen());
         // Add more route cases
         default:
           return MaterialPageRoute(
             builder: (_) => Scaffold(
               body: Center(child: Text('No route defined for ${settings.name}')),
             ),
           );
       }
     }
   }
   ```

### 3.2 "View All" Button Updates

1. **Today's Bookings Widget**:
   ```dart
   BLKWDSButton(
     label: 'View All',
     onPressed: () {
       NavigationService().navigateTo(
         AppRoutes.bookings,
         arguments: {'filter': 'today'},
       );
     },
     type: BLKWDSButtonType.secondary,
     icon: Icons.visibility,
     isSmall: true,
   ),
   ```

2. **Recent Activity Widget**:
   ```dart
   TextButton.icon(
     onPressed: () {
       NavigationService().navigateTo(AppRoutes.activityLog);
     },
     icon: const Icon(Icons.visibility),
     label: const Text('View All'),
     style: TextButton.styleFrom(
       foregroundColor: BLKWDSColors.accentTeal,
     ),
   ),
   ```

3. **Gear Preview List**:
   ```dart
   GearPreviewListWidget(
     controller: _controller,
     onCheckout: _handleCheckout,
     onReturn: _handleReturn,
     onViewAllGear: () {
       NavigationService().navigateTo(AppRoutes.gearManagement);
     },
   ),
   ```

### 3.3 App Configuration Updates

1. **Update MaterialApp Configuration**:
   ```dart
   MaterialApp(
     navigatorKey: NavigationService().navigatorKey,
     initialRoute: AppRoutes.dashboard,
     onGenerateRoute: AppRoutes.generateRoute,
     // Other app configuration
   )
   ```

## 4. Testing Plan

### 4.1 Unit Tests

1. **NavigationService Tests**:
   - Test navigation methods
   - Test route generation
   - Test parameter passing

### 4.2 Widget Tests

1. **"View All" Button Tests**:
   - Test that buttons trigger correct navigation
   - Test parameter passing
   - Test transition animations

### 4.3 Integration Tests

1. **Navigation Flow Tests**:
   - Test complete navigation flows
   - Test back navigation
   - Test deep linking

## 5. Success Criteria

The navigation standardization will be considered complete when:

1. All direct Navigator usage has been replaced with NavigationService
2. All "View All" buttons navigate to the appropriate screens
3. All navigation uses consistent transition animations
4. All tests pass successfully
5. The application maintains proper state during navigation
