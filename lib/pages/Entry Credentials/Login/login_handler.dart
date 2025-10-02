import 'package:flutter/material.dart';
import '../../../components/styling.dart';
import '../../../routes/routes.dart';
import '../../Main App/widget_tree.dart';
import '../../../components/notifiers.dart';
import '../../../routes/message_handler.dart';
import '../../../routes/user_prefs.dart';
import '../../../utils/validators.dart';

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
    final navigator = Navigator.of(context);

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    // Required fields
    if (email.isEmpty || password.isEmpty) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Missing Information'),
          content: email.isEmpty && password.isEmpty
              ? const Text('Please enter email and password')
              : email.isEmpty
                  ? const Text('Please enter your email')
                  : const Text('Please enter your password'),
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

    // Friendly email format validation
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
      final obj = await ApiRoutes.login(email, password);

      // Extract a first name from common places in the response
      String first = '';
      final candidates = [
        obj['fullName'],
        obj['name'],
        (obj['user'] is Map ? (obj['user'] as Map)['fullName'] : null),
        (obj['profile'] is Map ? (obj['profile'] as Map)['fullName'] : null),
      ];
      for (final c in candidates) {
        if (c is String && c.trim().isNotEmpty) {
          final trimmed = c.trim();
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.isNotEmpty) first = parts.first;
          break;
        }
      }

      // Fallback: derive from email local-part
      if (first.isEmpty) {
        final localPart = email.split('@').first;
        final cleaned = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
        if (cleaned.isNotEmpty) {
          final parts = cleaned.split(RegExp(r'\s+'));
          if (parts.isNotEmpty) first = parts.first;
          if (first.isNotEmpty) {
            first = first[0].toUpperCase() + first.substring(1);
          }
        }
      }

      if (first.isNotEmpty) {
        userFirstNameNotifier.value = first;
        await UserPrefs.instance.setFirstName(first);
      }

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
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid_credentials') || msg.contains('401') || msg.contains('unauthorized')) {
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Email or password is incorrect.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        );
      } else {
        await MessageHandler.showErrorDialog(
          context,
          title: 'Login Failed',
          error: e,
        );
      }
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
