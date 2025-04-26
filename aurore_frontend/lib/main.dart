import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/providers/auth_provider.dart' as app_auth;
import 'package:aurore_school/core/providers/qr_provider.dart';
import 'package:aurore_school/core/providers/api_service.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/core/providers/ai_detector_provider.dart';
import 'package:aurore_school/features/auth/login_screen.dart';
import 'package:aurore_school/features/auth/reset_password_screen.dart';
import 'package:aurore_school/features/auth/sign_up_screen.dart';
import 'package:aurore_school/features/dashboard/teacher/teacher_dashboard.dart';
import 'package:aurore_school/features/dashboard/student/student_dashboard.dart';
import 'package:aurore_school/features/dashboard/admin/admin_dashboard.dart';
import 'package:aurore_school/features/dashboard/support/support_screen.dart';
import 'package:aurore_school/features/timetable_screen.dart';
import 'package:aurore_school/utils/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.logAppOpen();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const AuroreApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class AuroreApp extends StatelessWidget {
  const AuroreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final secureStorage = SecureStorage();
    final apiService = ApiService(dio, secureStorage);
    final googleSignIn = GoogleSignIn(scopes: ['email']);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider(dio, secureStorage, googleSignIn)),
        ChangeNotifierProvider(create: (_) => QrProvider()),
        ChangeNotifierProvider(create: (_) => TimetableController(dio, secureStorage)),
        ChangeNotifierProvider(create: (_) => AiDetectorProvider(apiService: apiService)),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Aurore School',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.background,
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.primary,
            selectionColor: Colors.blueAccent,
          ),
        ),
        initialRoute: '/loading',
        routes: {
          '/loading': (context) => const LoadingScreen(),
          '/login': (context) => const AuroreResponsiveLayout(
                mobile: LoginScreen(),
                tablet: LoginScreen(),
                desktop: LoginScreen(),
              ),
          '/reset-password': (context) => const AuroreResponsiveLayout(
                mobile: ResetPasswordScreen(),
                tablet: ResetPasswordScreen(),
                desktop: ResetPasswordScreen(),
              ),
          '/signup': (context) => const AuroreResponsiveLayout(
                mobile: SignUpScreen(),
                tablet: SignUpScreen(),
                desktop: SignUpScreen(),
              ),
          '/support': (context) => const AuroreResponsiveLayout(
                mobile: SupportScreen(),
                tablet: SupportScreen(),
                desktop: SupportScreen(),
              ),
          '/student': (context) => const AuroreResponsiveLayout(
                mobile: StudentDashboard(),
                tablet: StudentDashboard(),
                desktop: StudentDashboard(),
              ),
          '/teacher': (context) => const AuroreResponsiveLayout(
                mobile: TeacherDashboard(),
                tablet: TeacherDashboard(),
                desktop: TeacherDashboard(),
              ),
          '/admin': (context) => const AuroreResponsiveLayout(
                mobile: AdminDashboard(),
                tablet: AdminDashboard(),
                desktop: AdminDashboard(),
              ),
          '/timetable': (context) => const AuroreResponsiveLayout(
                mobile: TimetableScreen(),
                tablet: TimetableScreen(),
                desktop: TimetableScreen(),
              ),
        },
        debugShowCheckedModeBanner: false,
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
      ),
    );
  }
}

class AuroreResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const AuroreResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) return desktop;
        if (constraints.maxWidth >= 600) return tablet;
        return mobile;
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    try {
      await auth.checkAuthState();
      if (context.mounted) {
        final route = auth.user != null ? _roleBasedRoute(auth.role ?? 'student') : '/login';
        Navigator.pushReplacementNamed(context, route);
        await FirebaseAnalytics.instance.logEvent(
          name: 'auth_state_checked',
          parameters: {'role': auth.role ?? 'unknown'},
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _errorMessage = 'Failed to authenticate: $e';
        });
      }
    }
  }

  String _roleBasedRoute(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return '/student';
      case 'teacher':
        return '/teacher';
      case 'admin':
        return '/admin';
      default:
        return '/login';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/aurore_logo.png',
                  width: 120,
                  height: 120,
                  semanticLabel: 'Aurore School Logo',
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  semanticsLabel: 'Loading Aurore School',
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Loading Aurore School...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                  semanticsLabel: _errorMessage ?? 'Loading Aurore School',
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAuthState,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
