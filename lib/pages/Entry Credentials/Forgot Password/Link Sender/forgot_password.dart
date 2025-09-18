import 'package:flutter/material.dart';
import '../../../../components/containers.dart';
import '../../../../components/styling.dart';
import '../../Login/login.dart';
import 'forget_password_handler.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final ForgotPasswordHandler _handler = ForgotPasswordHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            navBackButton(context, fallback: LoginPage()),
            const SizedBox(height: 40),
            beatsLogo,
            const SizedBox(height: 70),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Forgot Password', style: headingTextStyle),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 46),
              child: Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: baseTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
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
                            text: 'Send Reset Link',
                            onPressed: () => _handler.sendReset(context),
                            isLoading: isLoading,
                            showSuccess: showSuccess,
                          );
                        },
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
