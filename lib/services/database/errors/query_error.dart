import 'database_error.dart';

/// Query error class
///
/// This class represents database query errors in the application.
class QueryError extends DatabaseError {
  /// The SQL query that caused the error
  final String? query;

  /// The query parameters that caused the error
  final List<dynamic>? parameters;

  /// Create a new QueryError
  ///
  /// [message] is the error message
  /// [operation] is the operation that was being performed
  /// [table] is the table that was being accessed
  /// [query] is the SQL query that caused the error
  /// [parameters] are the query parameters that caused the error
  /// [originalError] is the original error that caused this exception
  /// [stackTrace] is the stack trace of the original error
  QueryError(
    String message,
    String operation, {
    String? table,
    this.query,
    this.parameters,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          operation,
          table: table,
          isTransient: false, // Query errors are typically not transient
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Create a user-friendly error message
  @override
  String toString() {
    final tableInfo = table != null ? ' on table "$table"' : '';
    final queryInfo = query != null ? '\nQuery: $query' : '';
    final paramsInfo = parameters != null && parameters!.isNotEmpty
        ? '\nParameters: $parameters'
        : '';
    return 'Database query error during $operation$tableInfo: $message$queryInfo$paramsInfo';
  }
}
