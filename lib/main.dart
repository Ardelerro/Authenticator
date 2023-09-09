import 'package:authenticator/screens/settings_screen.dart';
import 'package:authenticator/services/theme_provider.dart';
import 'package:authenticator/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:authenticator/screens/login_screen.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<ThemeProvider>(context, listen: true).themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/settings': (context) => const SettingsScreen(),
        
      },
    );
  }
}
