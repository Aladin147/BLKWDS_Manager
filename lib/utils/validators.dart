/// Validators
/// Utility class for form validation
class Validators {
  /// Validate that a field is not empty
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate that a field has a minimum length
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validate that a date range is valid (start date is before end date)
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both start and end dates are required';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }
    
    return null;
  }

  /// Validate that a list is not empty
  static String? validateListNotEmpty(List? list, {String? fieldName}) {
    if (list == null || list.isEmpty) {
      return '${fieldName ?? 'This field'} must have at least one item';
    }
    return null;
  }
}
