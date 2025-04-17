# Database Error Handling System

## Overview

The database error handling system provides a robust approach to handling database errors in the application. It includes error classification, retry mechanisms, and transaction support to ensure database operations are reliable and resilient.

## Key Components

### 1. Database Error Hierarchy

The system includes a hierarchy of database error classes to better classify and handle different types of database errors:

- **DatabaseError**: Base class for all database errors
- **ConnectionError**: Errors related to database connections
- **QueryError**: Errors related to SQL queries
- **TransactionError**: Errors related to database transactions
- **SchemaError**: Errors related to database schema
- **ConstraintError**: Errors related to database constraints

Each error class provides context-specific information to help diagnose and resolve the issue.

### 2. Database Error Handler

The `DatabaseErrorHandler` class provides methods for classifying and handling database errors:

- **classifyError**: Classifies a database error into a specific error type
- **handleError**: Handles a database error by logging it and returning a DatabaseError
- **isTransientError**: Determines if a database error is transient and can be retried

### 3. Retry Mechanism

The `DatabaseRetry` class provides methods for retrying database operations with exponential backoff:

- **retry**: Retries a database operation if it fails with a transient error
- **retryWithTransaction**: Retries a database operation with a transaction

The retry mechanism includes configurable parameters such as maximum attempts, initial delay, maximum delay, and backoff factor.

### 4. Database Service Wrapper

The `DBServiceWrapper` class provides a wrapper around the database service with enhanced error handling:

- **executeQuery**: Executes a database query with error handling and retry
- **executeTransaction**: Executes a database transaction with error handling and retry
- **query**, **insert**, **update**, **delete**: Wrappers for common database operations

## Usage

### Basic Query

```dart
final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
  db,
  'gear',
  operationName: 'getAllGear',
);
```

### Transaction

```dart
return await DBServiceWrapper.executeTransaction(
  db,
  (txn) async {
    // Transaction operations
    final projectId = await txn.insert('project', projectMap);
    
    // More operations...
    
    return projectId;
  },
  'insertProject',
  table: 'project',
);
```

### Custom Retry Configuration

```dart
return await DBServiceWrapper.query(
  db,
  'gear',
  operationName: 'getAllGear',
  config: RetryConfig(
    maxAttempts: 5,
    initialDelayMs: 200,
    maxDelayMs: 10000,
    backoffFactor: 3.0,
  ),
);
```

## Benefits

1. **Improved Reliability**: Retry mechanisms for transient errors
2. **Better Error Classification**: Specific error types for different database issues
3. **Enhanced Debugging**: Detailed error messages with context information
4. **Transaction Support**: Proper transaction handling with rollback on failure
5. **Configurable Retry**: Customizable retry parameters for different operations

## Best Practices

1. **Use Transactions**: Use transactions for operations that need to be atomic
2. **Provide Context**: Always provide operation names and table names for better error reporting
3. **Handle Errors**: Catch and handle database errors appropriately in the UI
4. **Log Errors**: Ensure errors are properly logged for debugging
5. **Use Retry Wisely**: Configure retry parameters based on the criticality of the operation
