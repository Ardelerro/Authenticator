import 'package:flutter/material.dart';
import 'package:authenticator/services/auth_service.dart';
import 'package:authenticator/screens/totp_display_screen.dart';
import 'package:authenticator/screens/password_setup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    _authService.isPasswordSet().then((value) => {
          if (!value)
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PasswordSetupScreen()),
              )
            }
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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

                  final isValid = await _authService.validatePassword(password);

                  if (isValid) {
                    if (!mounted) {
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TOTPDisplayScreen()),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Password not valid",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: const Color(0xFF1DB954),
                      textColor: Colors.white,
                      fontSize: 16.0);
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
