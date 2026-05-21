import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/app_theme.dart';
import 'models/app_user.dart';
import 'services/auth_provider.dart';
import 'services/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/coach/coach_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QuickFitApp());
}

class QuickFitApp extends StatelessWidget {
  const QuickFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title: 'QuickFit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const _RootRouter(),
        ),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LogoWidget(),
              const SizedBox(height: 32),
              CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final user = auth.currentUser!;
    if (user.role == UserRole.coach) {
      return const CoachHomeScreen();
    }
    return const StudentHomeScreen();
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryOf(context),
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Quick'),
              TextSpan(
                  text: 'Fit',
                  style: TextStyle(color: AppTheme.primary)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your fitness journey starts here',
          style: TextStyle(
              fontSize: 13, color: AppTheme.textSecondaryOf(context)),
        ),
      ],
    );
  }
}
