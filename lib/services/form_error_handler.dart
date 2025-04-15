import 'package:flutter/material.dart';
import 'exceptions/validation_exception.dart';
import 'log_service.dart';

/// Validation result
///
/// Represents the result of a validation rule
class ValidationResult {
  /// Whether the validation passed
  final bool isValid;

  /// The error message if validation failed
  final String errorMessage;

  /// Create a new ValidationResult
  ///
  /// [isValid] is whether the validation passed
  /// [errorMessage] is the error message if validation failed
  ValidationResult({
    this.isValid = true,
    this.errorMessage = '',
  });

  /// Create a valid result
  factory ValidationResult.valid() => ValidationResult();

  /// Create an invalid result with an error message
  factory ValidationResult.invalid(String errorMessage) => ValidationResult(
        isValid: false,
        errorMessage: errorMessage,
      );
}

/// Validation rule
///
/// Base class for validation rules
abstract class ValidationRule {
  /// Validate a value
  ///
  /// Returns a ValidationResult indicating whether the value is valid
  ValidationResult validate(dynamic value);
}

/// Required validation rule
///
/// Validates that a value is not null or empty
class RequiredRule extends ValidationRule {
  /// The error message to show if validation fails
  final String errorMessage;

  /// Create a new RequiredRule
  ///
  /// [errorMessage] is the error message to show if validation fails
  RequiredRule({
    this.errorMessage = 'This field is required',
  });

  @override
  ValidationResult validate(dynamic value) {
    if (value == null) {
      return ValidationResult.invalid(errorMessage);
    }

    if (value is String && value.trim().isEmpty) {
      return ValidationResult.invalid(errorMessage);
    }

    if (value is List && value.isEmpty) {
      return ValidationResult.invalid(errorMessage);
    }

    if (value is Map && value.isEmpty) {
      return ValidationResult.invalid(errorMessage);
    }

    return ValidationResult.valid();
  }
}

/// Minimum length validation rule
///
/// Validates that a string has at least a minimum length
class MinLengthRule extends ValidationRule {
  /// The minimum length
  final int minLength;

  /// The error message to show if validation fails
  final String errorMessage;

  /// Create a new MinLengthRule
  ///
  /// [minLength] is the minimum length
  /// [errorMessage] is the error message to show if validation fails
  MinLengthRule({
    required this.minLength,
    String? errorMessage,
  }) : errorMessage = errorMessage ?? 'Must be at least $minLength characters';

  @override
  ValidationResult validate(dynamic value) {
    if (value == null) {
      return ValidationResult.valid(); // Let RequiredRule handle null values
    }

    if (value is String && value.length < minLength) {
      return ValidationResult.invalid(errorMessage);
    }

    if (value is List && value.length < minLength) {
      return ValidationResult.invalid(errorMessage);
    }

    return ValidationResult.valid();
  }
}

/// Maximum length validation rule
///
/// Validates that a string has at most a maximum length
class MaxLengthRule extends ValidationRule {
  /// The maximum length
  final int maxLength;

  /// The error message to show if validation fails
  final String errorMessage;

  /// Create a new MaxLengthRule
  ///
  /// [maxLength] is the maximum length
  /// [errorMessage] is the error message to show if validation fails
  MaxLengthRule({
    required this.maxLength,
    String? errorMessage,
  }) : errorMessage = errorMessage ?? 'Must be at most $maxLength characters';

  @override
  ValidationResult validate(dynamic value) {
    if (value == null) {
      return ValidationResult.valid(); // Let RequiredRule handle null values
    }

    if (value is String && value.length > maxLength) {
      return ValidationResult.invalid(errorMessage);
    }

    if (value is List && value.length > maxLength) {
      return ValidationResult.invalid(errorMessage);
    }

    return ValidationResult.valid();
  }
}

/// Email validation rule
///
/// Validates that a string is a valid email address
class EmailRule extends ValidationRule {
  /// The error message to show if validation fails
  final String errorMessage;

  /// Create a new EmailRule
  ///
  /// [errorMessage] is the error message to show if validation fails
  EmailRule({
    this.errorMessage = 'Please enter a valid email address',
  });

  @override
  ValidationResult validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) {
      return ValidationResult.valid(); // Let RequiredRule handle null/empty values
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return ValidationResult.invalid(errorMessage);
    }

    return ValidationResult.valid();
  }
}

/// Pattern validation rule
///
/// Validates that a string matches a regular expression pattern
class PatternRule extends ValidationRule {
  /// The pattern to match
  final RegExp pattern;

  /// The error message to show if validation fails
  final String errorMessage;

  /// Create a new PatternRule
  ///
  /// [pattern] is the pattern to match
  /// [errorMessage] is the error message to show if validation fails
  PatternRule({
    required this.pattern,
    required this.errorMessage,
  });

  @override
  ValidationResult validate(dynamic value) {
    if (value == null || value is! String || value.isEmpty) {
      return ValidationResult.valid(); // Let RequiredRule handle null/empty values
    }

    if (!pattern.hasMatch(value)) {
      return ValidationResult.invalid(errorMessage);
    }

    return ValidationResult.valid();
  }
}

/// Custom validation rule
///
/// Validates a value using a custom validation function
class CustomRule extends ValidationRule {
  /// The validation function
  final ValidationResult Function(dynamic value) validator;

  /// Create a new CustomRule
  ///
  /// [validator] is the validation function
  CustomRule({
    required this.validator,
  });

  @override
  ValidationResult validate(dynamic value) {
    return validator(value);
  }
}

/// Form error handler
///
/// Handles form validation errors
class FormErrorHandler {
  /// Validate a form
  ///
  /// [formData] is the form data to validate
  /// [rules] is a map of field names to validation rules
  ///
  /// Returns a map of field names to error messages
  static Map<String, String> validateForm(
    Map<String, dynamic> formData,
    Map<String, List<ValidationRule>> rules,
  ) {
    final errors = <String, String>{};

    rules.forEach((field, fieldRules) {
      final value = formData[field];

      for (final rule in fieldRules) {
        final result = rule.validate(value);

        if (!result.isValid) {
          errors[field] = result.errorMessage;
          break; // Stop at the first error for this field
        }
      }
    });

    return errors;
  }

  /// Validate a single field
  ///
  /// [value] is the value to validate
  /// [rules] is a list of validation rules
  ///
  /// Returns an error message if validation fails, or null if validation passes
  static String? validateField(
    dynamic value,
    List<ValidationRule> rules,
  ) {
    for (final rule in rules) {
      final result = rule.validate(value);

      if (!result.isValid) {
        return result.errorMessage;
      }
    }

    return null;
  }

  /// Create a form validator function for a TextFormField
  ///
  /// [rules] is a list of validation rules
  ///
  /// Returns a validator function that can be used with a TextFormField
  static FormFieldValidator<String> createValidator(
    List<ValidationRule> rules,
  ) {
    return (value) {
      return validateField(value, rules);
    };
  }

  /// Throw a validation exception if a form has errors
  ///
  /// [errors] is a map of field names to error messages
  ///
  /// Throws a ValidationException if the form has errors
  static void throwIfErrors(Map<String, String> errors) {
    if (errors.isNotEmpty) {
      final firstField = errors.keys.first;
      final firstError = errors[firstField]!;

      LogService.warning('Validation error: $firstField - $firstError');

      throw ValidationException(
        firstError,
        field: firstField,
      );
    }
  }
}
