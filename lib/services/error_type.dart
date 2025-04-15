/// Error types for the application
///
/// These types are used to categorize errors and provide appropriate user feedback
enum ErrorType {
  /// Database-related errors (SQLite, queries, etc.)
  database,

  /// Network-related errors (connectivity, API, etc.)
  network,

  /// Validation errors (form inputs, data validation, etc.)
  validation,

  /// Authentication errors (login, permissions, etc.)
  auth,

  /// File system errors (file not found, access denied, etc.)
  fileSystem,

  /// Permission errors (insufficient permissions, etc.)
  permission,

  /// Format errors (invalid data format, parsing errors, etc.)
  format,

  /// Conflict errors (booking conflicts, data conflicts, etc.)
  conflict,

  /// Not found errors (resource not found, etc.)
  notFound,

  /// Input errors (invalid input, etc.)
  input,

  /// State errors (invalid state, etc.)
  state,

  /// Configuration errors (invalid configuration, etc.)
  configuration,

  /// Unknown errors (unclassified errors)
  unknown,
}
