import 'package:flutter/material.dart';
import '../../../../routes/routes.dart';
import '../../../Main App/widget_tree.dart';
import '../../../../routes/message_handler.dart';
import '../../../../utils/validators.dart';

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

    // Validate inputs with friendly messages
    if (token.isEmpty) {
      await _alert(context, 'Invalid Input', 'Token is required.');
      return;
    }
    if (pass != confirm) {
      await _alert(context, 'Invalid Input', 'Passwords do not match.');
      return;
    }

    final reqErrors = passwordRequirementErrors(pass);
    if (reqErrors.isNotEmpty) {
      await _alert(context, 'Invalid Password', reqErrors.join('\n'));
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
    } catch (e, st) {
      if (!context.mounted) return;
      MessageHandler.devLog(e, st);
      await MessageHandler.showErrorDialog(
        context,
        title: 'Reset Failed',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _alert(BuildContext context, String title, String msg) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
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
