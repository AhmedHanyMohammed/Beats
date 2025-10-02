import 'package:flutter/material.dart';
import '../../../../components/styling.dart';
import '../../../../components/notifiers.dart';
import '../../../../routes/routes.dart';
import '../Reset Password/new_password.dart';
import '../../../../routes/message_handler.dart';
import '../../../../utils/validators.dart';

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
        builder: (dialogContext) => AlertDialog(
          title: const Text('Missing Email'),
          content: const Text('Please enter your email address'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      );
      return;
    }

    if (!isValidEmail(email)) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Invalid Email'),
          content: const Text('Please enter a valid email address.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
    } catch (e, st) {
      showSuccess.value = false;
      if (!context.mounted) return;
      MessageHandler.devLog(e, st);
      await MessageHandler.showErrorDialog(
        context,
        title: 'Request Failed',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() => emailCtrl.dispose();
}
