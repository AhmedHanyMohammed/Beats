import 'package:flutter/material.dart';
import '../../../../components/containers.dart';
import '../Link Sender/forgot_password.dart';
import 'new_password_handler.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, required this.email, this.token});

  final String email;
  final String? token;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  late final NewPasswordHandler _handler;

  @override
  void initState() {
    super.initState();
    _handler = NewPasswordHandler(email: widget.email, token: widget.token);
  }

  @override
  void dispose() {
    _handler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            navBackButton(context, fallback: ForgotPasswordPage()),
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
                          label: 'OTP Code',
                          hint: 'Token',
                          controller: _handler.tokenCtrl,
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<bool>(
                          valueListenable: _handler.obscurePassword,
                          builder: (_, obscure, __) {
                            return buildLabeledInput(
                              label: 'New Password',
                              hint: '••••••••',
                              controller: _handler.passwordCtrl,
                              isPassword: true,
                              obscure: obscure,
                              onToggle: _handler.toggleObscure,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<bool>(
                          valueListenable: _handler.obscurePassword,
                          builder: (_, obscure, __) {
                            return buildLabeledInput(
                              label: 'Rewrite Password',
                              hint: '••••••••',
                              controller: _handler.confirmCtrl,
                              isPassword: true,
                              obscure: obscure,
                              onToggle: _handler.toggleObscure,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
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
                                        text: 'Change Password',
                                        onPressed: () => _handler.submit(context),
                                        isLoading: isLoading,
                                        showSuccess: showSuccess,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}