bool isValidEmail(String email) {
  final e = email.trim();
  // Very light validation: something@something.something
  final at = e.indexOf('@');
  if (at <= 0 || at == e.length - 1) return false;
  final dot = e.lastIndexOf('.');
  if (dot < at + 2 || dot >= e.length - 1) return false;
  return true;
}

// Returns a list of unmet password requirements.
List<String> passwordRequirementErrors(String pass) {
  final errors = <String>[];
  if (pass.length < 6) {
    errors.add('Password must be at least 6 characters.');
  }
  if (!RegExp(r'[A-Z]').hasMatch(pass)) {
    errors.add('Passwords must have at least one uppercase (A-Z).');
  }
  if (!RegExp(r'[0-9]').hasMatch(pass)) {
    errors.add('Passwords must have at least one digit (0-9).');
  }
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(pass)) {
    errors.add('Passwords must have at least one non alphanumeric character.');
  }
  return errors;
}

