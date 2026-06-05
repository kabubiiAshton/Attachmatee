import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/company/company_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  runApp(const AttachmentApp());
}

class AttachmentApp extends StatelessWidget {
  const AttachmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState()..bootstrap(),
      child: MaterialApp(
        title: 'AttachMate',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Root(),
      ),
    );
  }
}

/// Shows a splash while tokens load, then routes to login or home.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }
    if (!auth.loggedIn) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
