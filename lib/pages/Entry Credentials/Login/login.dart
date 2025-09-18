import 'package:flutter/material.dart';
import '../Forgot Password/Link Sender/forgot_password.dart';
import '../Register/register.dart';
import '../../../components/containers.dart';
import 'login_handler.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginHandler _handler = LoginHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            beatsLogo,
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SizedBox(
                    width: 327,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabeledInput(
                          label: 'Email',
                          hint: 'name@example.com',
                          controller: _handler.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<bool>(
                          valueListenable: _handler.obscurePassword,
                          builder: (_, obscure, __) {
                            return buildLabeledInput(
                              label: 'Password',
                              hint: '••••••••',
                              controller: _handler.passwordCtrl,
                              isPassword: true,
                              obscure: obscure,
                              onToggle: _handler.toggleObscure,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        buildForgotPasswordLink(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _handler.showSuccess,
                    builder: (_, showSuccess, __) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _handler.isLoading,
                        builder: (_, isLoading, __) {
                          return proceedButton(
                            text: 'Log In',
                            onPressed: () => _handler.login(context),
                            isLoading: isLoading,
                            showSuccess: showSuccess,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  secondOptionText(
                    prompt: "Don't have an account?",
                    actionText: 'Sign up',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
