# State Management in BLKWDS Manager

This document describes the state management approach used in the BLKWDS Manager application.

## Overview

BLKWDS Manager uses Flutter's built-in **ValueNotifier** pattern for reactive state management. This approach was chosen for its simplicity, efficiency, and tight integration with Flutter's widget system.

## Architecture

The state management architecture follows these principles:

1. **Controller-based State Management**
   - Each major screen has a dedicated controller class
   - Controllers own and manage state using ValueNotifier objects
   - Controllers handle business logic and data operations

2. **Reactive UI Updates**
   - UI components listen to ValueNotifier objects using ValueListenableBuilder
   - UI is automatically updated when state changes
   - Clear separation between UI and business logic

3. **Unidirectional Data Flow**
   - Data flows from controllers to UI
   - UI triggers actions in controllers
   - Controllers update state based on actions and data operations

## Implementation Pattern

### Controller Implementation

```dart
class ExampleController {
  // State variables using ValueNotifier
  final ValueNotifier<List<Item>> items = ValueNotifier<List<Item>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Optional BuildContext for showing UI feedback
  final BuildContext? context;

  // Constructor
  ExampleController({this.context});

  // Methods to update state
  Future<void> loadItems() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Fetch data from service
      final result = await SomeService.getItems();
      items.value = result;
    } catch (e) {
      errorMessage.value = 'Failed to load items: ${e.toString()}';
      // Show error message if context is available
      if (context != null) {
        SnackbarService.showError(context!, 'Failed to load items');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Other methods to manipulate state
  void addItem(Item item) {
    final currentItems = List<Item>.from(items.value);
    currentItems.add(item);
    items.value = currentItems;
  }

  void removeItem(String itemId) {
    final currentItems = List<Item>.from(items.value);
    currentItems.removeWhere((item) => item.id == itemId);
    items.value = currentItems;
  }

  // Dispose method to clean up resources
  void dispose() {
    items.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
```

### UI Implementation

```dart
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late ExampleController controller;

  @override
  void initState() {
    super.initState();
    controller = ExampleController(context: context);
    controller.loadItems();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example Screen')),
      body: Column(
        children: [
          // Loading indicator
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLoading,
            builder: (context, isLoading, child) {
              return isLoading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink();
            },
          ),
          
          // Error message
          ValueListenableBuilder<String?>(
            valueListenable: controller.errorMessage,
            builder: (context, errorMessage, child) {
              return errorMessage != null
                  ? Text(errorMessage, style: TextStyle(color: Colors.red))
                  : const SizedBox.shrink();
            },
          ),
          
          // Item list
          Expanded(
            child: ValueListenableBuilder<List<Item>>(
              valueListenable: controller.items,
              builder: (context, items, child) {
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => controller.removeItem(item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show dialog to add new item
          final newItem = await showDialog<Item>(
            context: context,
            builder: (context) => AddItemDialog(),
          );
          
          if (newItem != null) {
            controller.addItem(newItem);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Benefits of this Approach

1. **Simplicity**
   - Easy to understand and implement
   - No external dependencies required
   - Minimal boilerplate code

2. **Performance**
   - Efficient updates with fine-grained reactivity
   - Only affected widgets rebuild when state changes
   - Low memory footprint

3. **Testability**
   - Controllers can be easily tested in isolation
   - Clear separation of concerns
   - State changes are explicit and traceable

4. **Maintainability**
   - Consistent pattern across the application
   - Clear ownership of state
   - Easy to debug and reason about

## Best Practices

1. **Always dispose ValueNotifier objects**
   - Implement dispose method in controllers
   - Call controller.dispose() in widget's dispose method

2. **Use immutable state when possible**
   - Create new lists/maps instead of modifying existing ones
   - This ensures proper notification of changes

3. **Keep controllers focused**
   - Each controller should manage a specific screen or feature
   - Break down complex state into smaller, focused controllers

4. **Handle errors gracefully**
   - Include error state in controllers
   - Provide user feedback for errors
   - Log errors for debugging

5. **Avoid deep nesting of ValueListenableBuilder**
   - Extract widgets to improve readability
   - Use multiple smaller ValueListenableBuilder widgets instead of one large one

## Conclusion

The ValueNotifier pattern provides a simple, efficient, and maintainable approach to state management in BLKWDS Manager. By following the patterns and best practices outlined in this document, we can ensure a consistent and robust implementation across the application.
