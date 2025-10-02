import 'package:flutter/material.dart';
import '../Login/login.dart';
import '../../../components/containers.dart';
import 'register_handler.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final RegisterHandler _handler = RegisterHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button limited to the Register screen only
            navBackButton(context, fallback: LoginPage()),
            const SizedBox(height: 40),
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
                          label: 'Name',
                          hint: 'Your name',
                          controller: _handler.nameCtrl,
                        ),
                        const SizedBox(height: 20),
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
                            text: 'Sign Up',
                            onPressed: () => _handler.register(context),
                            isLoading: isLoading,
                            showSuccess: showSuccess,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  secondOptionText(
                    prompt: 'Have an account?',
                    actionText: 'Log in',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
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
