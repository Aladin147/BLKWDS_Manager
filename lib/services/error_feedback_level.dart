/// ErrorFeedbackLevel
/// Enum for error feedback levels
/// 
/// This enum defines the different levels of feedback that can be provided to the user
/// when an error occurs. The levels are:
/// 
/// - silent: No feedback is provided to the user, but the error is still logged
/// - snackbar: A snackbar is shown to the user with the error message
/// - dialog: A dialog is shown to the user with the error message
/// - banner: A banner is shown at the top of the screen with the error message
/// - page: A full-screen error page is shown to the user
enum ErrorFeedbackLevel {
  /// No feedback is provided to the user, but the error is still logged
  silent,
  
  /// A snackbar is shown to the user with the error message
  snackbar,
  
  /// A dialog is shown to the user with the error message
  dialog,
  
  /// A banner is shown at the top of the screen with the error message
  banner,
  
  /// A full-screen error page is shown to the user
  page,
}
