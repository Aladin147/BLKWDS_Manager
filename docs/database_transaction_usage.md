# Database Transaction Usage

## Overview

This document outlines the proper usage of transactions in the BLKWDS Manager application. Transactions are essential for maintaining data integrity, especially when multiple related operations need to be performed atomically.

## Key Improvements

1. **Enhanced Member Operations**
   - `insertMember`, `updateMember`, and `deleteMember` now use transactions
   - `deleteMember` properly cleans up related records in other tables

2. **Enhanced Studio Operations**
   - `insertStudio`, `updateStudio`, and `deleteStudio` now use transactions
   - `deleteStudio` checks for constraints before deletion

3. **Enhanced Settings Operations**
   - `updateStudioSettings` now uses transactions for both update and insert operations

4. **Foreign Key Enforcement**
   - Foreign key constraints are now enforced at the database level
   - Foreign key constraints are explicitly enabled in transactions

## Best Practices

### When to Use Transactions

Transactions should be used in the following scenarios:

1. **Multiple Related Operations**
   - When multiple database operations need to be performed atomically
   - When operations span multiple tables

2. **Data Integrity**
   - When operations need to maintain referential integrity
   - When operations need to be rolled back if any part fails

3. **Constraint Checking**
   - When operations need to check constraints before proceeding
   - When operations need to enforce business rules

### How to Use Transactions

```dart
// Example of using a transaction with DBServiceWrapper
Future<int> someOperation(int id) async {
  final db = await database;
  
  return await DBServiceWrapper.executeTransaction(
    db,
    (txn) async {
      // Perform multiple operations
      final result1 = await txn.query('table1', where: 'id = ?', whereArgs: [id]);
      
      if (result1.isEmpty) {
        throw NotFoundException('Record not found', 'someOperation');
      }
      
      await txn.update('table1', {'status': 'updated'}, where: 'id = ?', whereArgs: [id]);
      await txn.insert('table2', {'table1Id': id, 'timestamp': DateTime.now().toIso8601String()});
      
      return id;
    },
    'someOperation',
    table: 'table1',
  );
}
```

### Error Handling in Transactions

- Use the appropriate error classes from `database/errors/errors.dart`
- Throw `ConstraintError` when a constraint violation occurs
- Throw `NotFoundException` when a required record is not found
- Throw `DatabaseError` for general database errors

## Testing Transactions

The transaction usage is tested in `test/unit/services/db_service_transaction_test.dart`. The tests verify that:

1. Transactions are used correctly
2. Data is properly updated or deleted
3. Constraints are properly enforced
4. Errors are properly thrown and handled

## Future Improvements

1. **Transaction Logging**
   - Add detailed logging for transaction operations
   - Track transaction performance metrics

2. **Batch Operations**
   - Implement batch operations for better performance
   - Use transactions for batch operations

3. **Transaction Retry Logic**
   - Enhance retry logic for transient errors
   - Add exponential backoff for retries
