/// Retry strategy
///
/// Defines how retry attempts should be handled
enum RetryStrategy {
  /// Immediate retry without delay
  immediate,

  /// Linear backoff (constant delay between attempts)
  linear,

  /// Exponential backoff (increasing delay between attempts)
  exponential,
}
