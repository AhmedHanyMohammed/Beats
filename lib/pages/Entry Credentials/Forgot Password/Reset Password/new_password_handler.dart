import 'package:flutter/material.dart';
import '../../../../routes/routes.dart';
import '../../../Main App/widget_tree.dart';

class NewPasswordHandler {
  final String email;

  final tokenCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> showSuccess = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  NewPasswordHandler({required this.email, String? token}) {
    if (token != null && token.isNotEmpty) {
      tokenCtrl.text = token;
    }
  }

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final token = tokenCtrl.text.trim();
    final pass = passwordCtrl.text;
    final confirm = confirmCtrl.text;

    String? error;
    if (token.isEmpty) {
      error = 'Token is required.';
    } else if (pass.length < 6) {
      error = 'Password must be at least 6 characters.';
    } else if (pass != confirm) {
      error = 'Passwords do not match.';
    }

    if (error != null) {
      _alert(context, 'Invalid Input', error);
      return;
    }

    isLoading.value = true;
    showSuccess.value = false;
    try {
      await ApiRoutes.resetPassword(email, token, pass);
      if (!context.mounted) return;
      showSuccess.value = true;
      await _alert(context, 'Success', 'Password has been reset.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WidgetTree()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      _alert(context, 'Reset Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _alert(BuildContext context, String title, String msg) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void dispose() {
    tokenCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    isLoading.dispose();
    showSuccess.dispose();
    obscurePassword.dispose();
  }
}
