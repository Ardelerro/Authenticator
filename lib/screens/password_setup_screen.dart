import 'package:authenticator/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:authenticator/services/auth_service.dart';


class PasswordSetupScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  PasswordSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final password = _passwordController.text;
                  await _authService.setPassword(password);

                  if (!context.mounted) {
                    return;
                  }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );                },
                child: const Text('Set Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}