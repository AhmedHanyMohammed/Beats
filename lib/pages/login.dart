import 'package:flutter/material.dart';
import 'forgot_password.dart';
import 'register.dart';
import '../widgets/containers.dart';
import '../widgets/styling.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showSuccess = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Missing Information'),
          content: email.isEmpty && password.isEmpty ? const Text('Please enter email and password') :
          email.isEmpty ? const Text('Please enter your email') : const Text('Please enter your password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: primaryColor),),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://beats-94c51-default-rtdb.europe-west1.firebasedatabase.app/users.json',
      );
      final res = await get(url);
      if (res.statusCode != 200) {
        throw 'Server error (${res.statusCode})';
      }

      final decoded = json.decode(res.body);
      if (decoded == null) {
        throw 'No users found';
      }

      Map<String, dynamic>? matchedUser;
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is Map &&
              (value['email'] ?? '').toString().toLowerCase() ==
                  email.toLowerCase()) {
            matchedUser = Map<String, dynamic>.from(value);
            break;
          }
        }
      }

      if (matchedUser == null) {
        throw 'Email not found';
      }

      if (matchedUser['password'] != password) {
        throw 'Wrong password';
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(_buildHomeRoute());
      return;
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() => _showSuccess = false);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Route _buildHomeRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const HomePage(),
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnim = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offsetAnim, child: child);
      },
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

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
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        buildLabeledInput(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordCtrl,
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        buildForgotPasswordLink(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
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
                  proceedButton(
                    text: 'Log In',
                    onPressed: _login,
                    isLoading: _isLoading,
                    showSuccess: _showSuccess,
                  ),
                  const SizedBox(height: 20),
                  secondOptionText(
                    prompt: "Don't have an account?",
                    actionText: 'Sign up',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
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
