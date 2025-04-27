class ValidationUtils {
  /// Characters typically considered invalid in file names or specific text inputs.
  static const List<String> _invalidCharacters = [
    r'\', // Backslash
    r'/', // Forward slash
    r':', // Colon
    r'*', // Asterisk
    r'?', // Question mark
    r'"', // Double quote
    r'<', // Less than
    r'>', // Greater than
    r'|', // Pipe
    '\t', // Tab
    '\n', // Newline (Enter)
  ];

  /// Validates email format.
  /// Returns null if valid, error message otherwise.
  /// Allows empty/null input (use a separate 'required' validator if needed).
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return null; // Valid if empty (unless required validator added elsewhere)
    }
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
      // A common, more robust regex for emails
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
    }
    return null; // Valid
  }

  /// Validates phone number format (basic international format).
  /// Returns null if valid, error message otherwise.
  /// Allows empty/null input.
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Valid if empty
    }
    // Basic E.164 format check (optional +, digits only)
    final RegExp phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      return 'Bitte geben Sie eine gültige Telefonnummer ein (z.B. +4912345678).';
    }
    return null; // Valid
  }

  /// Validates URL format (basic check).
  /// Returns null if valid, error message otherwise.
  /// Allows empty/null input.
  static String? validateURL(String? url) {
    if (url == null || url.isEmpty) {
      return null; // Valid if empty
    }
    // Basic URL check (allows http/https, domain, optional port/path)
    // Consider using the 'url_launcher' package's `canLaunch` or a more robust regex
    // if stricter validation is needed.
    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(url)) {
      return 'Bitte geben Sie eine gültige URL ein.';
    }
    return null; // Valid
  }

  /// Validates date format (YYYY-MM-DD).
  /// Returns null if valid, error message otherwise.
  /// Allows empty/null input.
  static String? validateDate(String? date) {
    if (date == null || date.isEmpty) {
      return null; // Valid if empty
    }
    final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      return 'Bitte geben Sie ein Datum im Format JJJJ-MM-TT ein.';
    }
    // Optional: Add check for valid date ranges (e.g., month 1-12, day 1-31)
    // try {
    //   DateTime.parse(date);
    // } catch (e) {
    //   return 'Ungültiges Datum.';
    // }
    return null; // Valid format
  }

  /// Validates general text input: checks for invalid characters and optional minimum length.
  ///
  /// Returns null if valid, error message otherwise.
  /// Allows empty/null input unless minLength > 0.
  ///
  /// Parameters:
  ///   - `value`: The text input string to validate.
  ///   - `minLength`: The minimum required length. Defaults to 0 (no minimum).
  ///   - `fieldName`: Optional name of the field for clearer error messages.
  static String? validateTextInput(String? value,
      {int minLength = 1, String? fieldName}) {
    // 1. Handle empty/null cases first, based on minLength
    if (value == null || value.trim().isEmpty) {
      // Use trim() to treat whitespace-only as empty
      if (minLength > 0) {
        if (fieldName != null) {
          return 'Das Feld "$fieldName" darf nicht leer sein.';
        } else {
          return 'Dieses Feld darf nicht leer sein.';
        }
      } else {
        return null; // Empty is valid if minLength is 0 or less
      }
    }

    // 2. Check for invalid characters
    for (final char in _invalidCharacters) {
      if (value.contains(char)) {
        // Escape the character for display in the error message if needed
        String displayChar = char;
        if (char == '\t') displayChar = '\\t (Tab)';
        if (char == '\n') displayChar = '\\n (Enter)';
        return 'Enthält ungültige Zeichen: "$displayChar".';
      }
    }

    // 3. Check minimum length (only if not empty and minLength is set)
    if (minLength > 0 && value.length < minLength) {
      return 'Muss mindestens $minLength Zeichen lang sein.';
    }

    // 4. All checks passed
    return null; // Valid
  }

  /// Creates a validator that checks if the field is required (not null or empty/whitespace).
  static String? Function(String?) required([String? fieldName]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        if (fieldName != null) {
          return 'Das Feld "$fieldName" darf nicht leer sein.';
        } else {
          return 'Dieses Feld darf nicht leer sein.';
        }
      }
      return null;
    };
  }

  /// Combines multiple validators.
  /// Executes them in order and returns the first error message encountered.
  /// Returns null if all validators pass.
  static String? Function(String?) combineValidators(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error; // Return the first error found
        }
      }
      return null; // All validators passed
    };
  }
}
