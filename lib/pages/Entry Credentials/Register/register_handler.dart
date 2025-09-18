import 'package:flutter/material.dart';
import '../../../components/styling.dart';
import '../../../routes/routes.dart';
import '../../Main App/widget_tree.dart';
import '../../../components/notifiers.dart';

class RegisterHandler {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();


  ValueNotifier<bool> get obscurePassword => registerObscurePasswordNotifier;
  ValueNotifier<bool> get isLoading => registerIsLoadingNotifier;
  ValueNotifier<bool> get showSuccess => registerShowSuccessNotifier;

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> register(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);

    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      final msg = name.isEmpty && email.isEmpty && password.isEmpty
          ? 'Please enter name, email, and password'
          : name.isEmpty && email.isEmpty
              ? 'Please enter your name and email'
              : name.isEmpty && password.isEmpty
                  ? 'Please enter your name and password'
                  : email.isEmpty && password.isEmpty
                      ? 'Please enter your email and password'
                      : name.isEmpty
                          ? 'Please enter your name'
                          : email.isEmpty
                              ? 'Please enter your email'
                              : 'Please enter your password';

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Missing Information'),
          content: Text(msg),
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
      await ApiRoutes.registerUser(name, email, password);

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

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration Failed'),
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
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }
}
