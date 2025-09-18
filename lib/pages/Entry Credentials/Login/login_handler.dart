import 'package:flutter/material.dart';
import '../../../components/styling.dart';
import '../../../routes/routes.dart';
import '../../Main App/widget_tree.dart';
import '../../../components/notifiers.dart';

class LoginHandler {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Use shared notifiers
  ValueNotifier<bool> get obscurePassword => obscurePasswordNotifier;
  ValueNotifier<bool> get isLoading => loginIsLoadingNotifier;
  ValueNotifier<bool> get showSuccess => loginShowSuccessNotifier;

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login(BuildContext context) async {
    FocusScope.of(context).unfocus();
    // Capture navigator before any awaits to avoid re-reading context later.
    final navigator = Navigator.of(context);

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Missing Information'),
          content: email.isEmpty && password.isEmpty
              ? const Text('Please enter email and password')
              : email.isEmpty
                  ? const Text('Please enter your email')
                  : const Text('Please enter your password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      );
      return;
    }

    isLoading.value = true;

    try {
      await ApiRoutes.login(email, password);

      if (!context.mounted) return;

      isLoading.value = false;
      showSuccess.value = true;
      await Future.delayed(const Duration(milliseconds: 600));

      if (!navigator.mounted) return;
      navigator.pushReplacement(_buildHomeRoute());

      dispose();
      return;
    } catch (e) {
      showSuccess.value = false;

      // Guard before showing dialog after an await.
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Route _buildHomeRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const WidgetTree(),
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnim = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offsetAnim, child: child);
      },
    );
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }
}
