import 'package:sqflite/sqflite.dart';
import 'package:blkwds_manager/services/database/db_service_wrapper.dart';
import 'package:blkwds_manager/services/database/database_retry.dart';

/// A mock database service wrapper for testing
class MockDBServiceWrapper {
  /// A record of all operations performed
  final List<Map<String, dynamic>> operations = [];
  
  /// A map of responses to return for specific operations
  final Map<String, dynamic> responses = {};
  
  /// A map of errors to throw for specific operations
  final Map<String, Exception> errors = {};
  
  /// Clear all recorded operations
  void clearOperations() {
    operations.clear();
  }
  
  /// Set a response for a specific operation
  void setResponse(String operation, dynamic response) {
    responses[operation] = response;
  }
  
  /// Set an error for a specific operation
  void setError(String operation, Exception error) {
    errors[operation] = error;
  }
  
  /// Execute a query with error handling and retry
  Future<T> executeQuery<T>(
    Database db,
    Future<T> Function() operation,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'executeQuery',
      'operationName': operationName,
      'table': table,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as T;
    }
    
    return await operation();
  }
  
  /// Execute a transaction with error handling and retry
  Future<T> executeTransaction<T>(
    Database db,
    Future<T> Function(Transaction txn) operation,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'executeTransaction',
      'operationName': operationName,
      'table': table,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as T;
    }
    
    return await db.transaction(operation);
  }
  
  /// Execute a raw SQL query with error handling and retry
  Future<List<Map<String, dynamic>>> rawQuery(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'rawQuery',
      'operationName': operationName,
      'table': table,
      'query': query,
      'parameters': parameters,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as List<Map<String, dynamic>>;
    }
    
    return await db.rawQuery(query, parameters);
  }
  
  /// Execute a raw SQL insert with error handling and retry
  Future<int> rawInsert(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'rawInsert',
      'operationName': operationName,
      'table': table,
      'query': query,
      'parameters': parameters,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as int;
    }
    
    return await db.rawInsert(query, parameters);
  }
  
  /// Execute a raw SQL update with error handling and retry
  Future<int> rawUpdate(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'rawUpdate',
      'operationName': operationName,
      'table': table,
      'query': query,
      'parameters': parameters,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as int;
    }
    
    return await db.rawUpdate(query, parameters);
  }
  
  /// Execute a raw SQL delete with error handling and retry
  Future<int> rawDelete(
    Database db,
    String query,
    List<dynamic>? parameters,
    String operationName, {
    String? table,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    operations.add({
      'type': 'rawDelete',
      'operationName': operationName,
      'table': table,
      'query': query,
      'parameters': parameters,
    });
    
    if (errors.containsKey(operationName)) {
      throw errors[operationName]!;
    }
    
    if (responses.containsKey(operationName)) {
      return responses[operationName] as int;
    }
    
    return await db.rawDelete(query, parameters);
  }
  
  /// Execute a SQL query with error handling and retry
  Future<List<Map<String, dynamic>>> query(
    Database db,
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'query_$table';
    
    operations.add({
      'type': 'query',
      'operationName': operation,
      'table': table,
      'columns': columns,
      'where': where,
      'whereArgs': whereArgs,
      'groupBy': groupBy,
      'having': having,
      'orderBy': orderBy,
      'limit': limit,
      'offset': offset,
    });
    
    if (errors.containsKey(operation)) {
      throw errors[operation]!;
    }
    
    if (responses.containsKey(operation)) {
      return responses[operation] as List<Map<String, dynamic>>;
    }
    
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
  
  /// Execute a SQL insert with error handling and retry
  Future<int> insert(
    Database db,
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'insert_$table';
    
    operations.add({
      'type': 'insert',
      'operationName': operation,
      'table': table,
      'values': values,
      'conflictAlgorithm': conflictAlgorithm,
    });
    
    if (errors.containsKey(operation)) {
      throw errors[operation]!;
    }
    
    if (responses.containsKey(operation)) {
      return responses[operation] as int;
    }
    
    return await db.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
  
  /// Execute a SQL update with error handling and retry
  Future<int> update(
    Database db,
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'update_$table';
    
    operations.add({
      'type': 'update',
      'operationName': operation,
      'table': table,
      'values': values,
      'where': where,
      'whereArgs': whereArgs,
      'conflictAlgorithm': conflictAlgorithm,
    });
    
    if (errors.containsKey(operation)) {
      throw errors[operation]!;
    }
    
    if (responses.containsKey(operation)) {
      return responses[operation] as int;
    }
    
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
  
  /// Execute a SQL delete with error handling and retry
  Future<int> delete(
    Database db,
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? operationName,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    final operation = operationName ?? 'delete_$table';
    
    operations.add({
      'type': 'delete',
      'operationName': operation,
      'table': table,
      'where': where,
      'whereArgs': whereArgs,
    });
    
    if (errors.containsKey(operation)) {
      throw errors[operation]!;
    }
    
    if (responses.containsKey(operation)) {
      return responses[operation] as int;
    }
    
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
