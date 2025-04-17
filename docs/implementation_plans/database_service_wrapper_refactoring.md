# Database Service Wrapper Refactoring Implementation Plan

## Overview

This document outlines the plan for refactoring the remaining database operations in DBService to consistently use DBServiceWrapper methods. This refactoring will improve error handling, provide retry capabilities, and ensure consistent behavior across all database operations.

## Goals

1. Identify all direct database operations in DBService that aren't using the DBServiceWrapper methods
2. Refactor these operations to use the appropriate DBServiceWrapper methods
3. Ensure consistent error handling across all database operations
4. Add or update tests to verify the refactored operations
5. Document the changes and update any affected documentation

## Implementation Strategy

### Phase 1: Audit (1 day)

1. Identify all direct database operations in DBService:
   - Direct query operations (`db.query`)
   - Direct insert operations (`db.insert`)
   - Direct update operations (`db.update`)
   - Direct delete operations (`db.delete`)
   - Direct transaction operations (`db.transaction`)
   - Direct raw query operations (`db.rawQuery`, `db.rawInsert`, etc.)

2. Categorize operations by type and complexity:
   - Simple CRUD operations
   - Complex operations with transactions
   - Operations with custom error handling
   - Operations with specific return type conversions

3. Create a detailed inventory of all operations to be refactored

### Phase 2: Refactoring (3 days)

#### Day 1: Simple CRUD Operations

1. Refactor direct query operations to use `DBServiceWrapper.query`
2. Refactor direct insert operations to use `DBServiceWrapper.insert`
3. Refactor direct update operations to use `DBServiceWrapper.update`
4. Refactor direct delete operations to use `DBServiceWrapper.delete`
5. Run tests after each batch of similar operations to ensure functionality is preserved

#### Day 2: Transaction Operations

1. Refactor direct transaction operations to use `DBServiceWrapper.executeTransaction`
2. Ensure proper error handling within transactions
3. Verify transaction rollback behavior on error
4. Run tests after each transaction refactoring to ensure functionality is preserved

#### Day 3: Complex Operations

1. Refactor operations with custom error handling
2. Refactor operations with specific return type conversions
3. Refactor any remaining direct database operations
4. Run tests after each complex operation refactoring to ensure functionality is preserved

### Phase 3: Testing (2 days)

#### Day 1: Unit Tests

1. Update existing unit tests to reflect the new implementation
2. Add new unit tests for previously untested database operations
3. Verify error handling behavior with specific test cases
4. Test retry mechanisms for transient errors

#### Day 2: Integration Tests

1. Test the refactored operations in the context of the application
2. Verify that all features using database operations still work correctly
3. Test error scenarios to ensure proper error handling
4. Test performance to ensure no significant degradation

### Phase 4: Documentation (1 day)

1. Update code documentation with new method signatures and behavior
2. Update any affected documentation in the project
3. Document the benefits of the refactoring
4. Create examples of proper usage of DBServiceWrapper methods

## Detailed Refactoring Examples

### Example 1: Simple Query Operation

**Before:**
```dart
static Future<List<Member>> getAllMembers() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('member');
  return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
}
```

**After:**
```dart
static Future<List<Member>> getAllMembers() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
    db,
    'member',
    operationName: 'getAllMembers',
  );
  return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
}
```

### Example 2: Transaction Operation

**Before:**
```dart
static Future<int> updateProject(Project project) async {
  final db = await database;

  // Begin transaction
  return await db.transaction((txn) async {
    // Update project
    await txn.update(
      'project',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );

    // Delete existing project-member associations
    await txn.delete(
      'project_member',
      where: 'projectId = ?',
      whereArgs: [project.id],
    );

    // Insert new project-member associations
    for (final memberId in project.memberIds) {
      await txn.insert('project_member', {
        'projectId': project.id,
        'memberId': memberId,
      });
    }

    return project.id!;
  });
}
```

**After:**
```dart
static Future<int> updateProject(Project project) async {
  final db = await database;

  // Begin transaction
  return await DBServiceWrapper.executeTransaction(
    db,
    (txn) async {
      // Update project
      await DBServiceWrapper.update(
        txn,
        'project',
        project.toMap(),
        where: 'id = ?',
        whereArgs: [project.id],
        operationName: 'updateProject_update',
      );

      // Delete existing project-member associations
      await DBServiceWrapper.delete(
        txn,
        'project_member',
        where: 'projectId = ?',
        whereArgs: [project.id],
        operationName: 'updateProject_deleteMembers',
      );

      // Insert new project-member associations
      for (final memberId in project.memberIds) {
        await DBServiceWrapper.insert(
          txn,
          'project_member',
          {
            'projectId': project.id,
            'memberId': memberId,
          },
          operationName: 'updateProject_insertMember',
        );
      }

      return project.id!;
    },
    'updateProject',
    table: 'project',
  );
}
```

## Success Criteria

1. All direct database operations in DBService are refactored to use DBServiceWrapper methods
2. All tests pass successfully
3. No regression in functionality
4. Consistent error handling across all database operations
5. Documentation is updated to reflect the changes

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Thorough testing after each batch of refactoring |
| Performance degradation | Performance testing before and after refactoring |
| Missed operations | Comprehensive audit before starting refactoring |
| Inconsistent error handling | Standardized approach to error handling in all operations |

## Timeline

- Phase 1 (Audit): 1 day
- Phase 2 (Refactoring): 3 days
- Phase 3 (Testing): 2 days
- Phase 4 (Documentation): 1 day

**Total**: 7 working days

## Conclusion

This refactoring will significantly improve the reliability and consistency of database operations in the BLKWDS Manager application. By ensuring all operations use the DBServiceWrapper methods, we'll benefit from consistent error handling, retry capabilities, and better debugging information.
