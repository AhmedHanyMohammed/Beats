import 'package:flutter/material.dart';
import '../../../../components/styling.dart';
import '../../../../components/notifiers.dart';
import '../../../../routes/routes.dart';
import '../Reset Password/new_password.dart';

class ForgotPasswordHandler {
  final emailCtrl = TextEditingController();

  ValueNotifier<bool> get isLoading => forgotIsLoadingNotifier;
  ValueNotifier<bool> get showSuccess => forgotShowSuccessNotifier;

  Future<void> sendReset(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Missing Email'),
          content: const Text('Please enter your email address'),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('OK', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      );
      return;
    }

    isLoading.value = true;
    try {
      await ApiRoutes.forgotPassword(email);
      showSuccess.value = true;
      if (!context.mounted) return;
      // Inline feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset email sent to $email')),
      );
      // Go directly to New Password screen (user will paste token).
      navigator.push(MaterialPageRoute(
        builder: (_) => NewPasswordPage(email: email),
      ));
    } catch (e) {
      showSuccess.value = false;
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Request Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() => emailCtrl.dispose();
}
