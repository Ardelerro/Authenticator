import 'package:authenticator/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:authenticator/screens/password_setup_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Toggle Dark Mode"),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (!context.mounted) {
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PasswordSetupScreen()
                      )
                    );
                  },
                  child: const Text(
                    'Password Reset',
                    style: TextStyle(
                      color: Colors.white
                    ),
                    ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
