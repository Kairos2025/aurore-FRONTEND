// Dart core imports
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// Flutter framework imports
import 'package:flutter/material.dart';

// Third-party packages
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Project-specific imports
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/enums/resolution_type.dart';
import 'package:aurore_school/models/schedule.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/services/secure_storage.dart';
import 'package:aurore_school/core/providers/ai_detector_provider.dart';
import 'package:aurore_school/widgets/notion_card.dart';
import 'app_colors.dart';
import 'package:aurore_school/enums/resolution_type.dart';
import 'package:aurore_school/models/schedule.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QrProvider()),
        ChangeNotifierProvider(create: (_) => TimetableController()),
        ChangeNotifierProvider(create: (_) => AiDetectorProvider()),
      ],
      child: const AuroreApp(),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class AuroreApp extends StatelessWidget {
  const AuroreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Aurore School',
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/support': (context) => const SupportScreen(),
        '/student': (context) => const StudentDashboard(),
        '/teacher': (context) => const TeacherDashboard(),
        '/admin': (context) => const AdminDashboard(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (auth.user == null) return const LoginScreen();
          return _roleBasedHome(auth.role);
        },
      ),
    );
  }

  Widget _roleBasedHome(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return const StudentDashboard();
      case 'teacher':
        return const TeacherDashboard();
      case 'admin':
        return const AdminDashboard();
      default:
        return const LoginScreen();
    }
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]!
                  : Colors.grey[50]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _AppLogoWithTitle(),
                const SizedBox(height: 40),
                const _LoginForm(),
                const SizedBox(height: 24),
                const _AlternativeLoginOptions(),
                const SizedBox(height: 32),
                const _FooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogoWithTitle extends StatelessWidget {
  const _AppLogoWithTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/aurore_logo.png',
          width: 100,
          height: 100,
          errorBuilder: (_, __, ___) => const Placeholder(
            fallbackHeight: 100,
            fallbackWidth: 100,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Aurore School',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/login_logo.png',
      width: size,
      height: size,
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[500],
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            obscureText: _obscurePassword,
          ),
          const SizedBox(height: 24),
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                auth.errorMessage!,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final auth = context.read<AuthProvider>();
                auth.login(_emailController.text, _passwordController.text);
              },
              child:
              const Text('Sign In', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativeLoginOptions extends StatelessWidget {
  const _AlternativeLoginOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('OR', style: TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Divider()),
        ]),
        const SizedBox(height: 24),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => context.read<AuthProvider>().signInWithGoogle(),
          child: const Text('Continue with Google'),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/reset-password'),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text('Create account'),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, size: 18, color: Colors.grey[600]),
          onPressed: () => Navigator.pushNamed(context, '/support'),
        ),
      ],
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: _emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  await credential.user!.updateDisplayName(_nameController.text);
                  await credential.user!.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Account created. Please verify email.')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: const Center(
        child: Text('Contact support at support@auroreschool.com'),
      ),
    );
  }
}


// theme

//2nd phase
// lib/core/constants/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF2A2D32);
  static const Color secondary = Color(0xFF00CA8D);
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF4A4D52);
  static const Color lightGrey = Color(0xFFEDEDED);
  static const Color errorRed = Color(0xFFE57373);
}


//secure storage
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeTokens(
      {required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }
}

//3 phase
//auth_provider

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = 'student';
  String _role = 'student';
  String _userId = '';
  User? _user;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;
  String get userId => _userId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final ApiService _apiService = ApiService();

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _handleBackendAuth(userCredential);
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Login failed: ${e.message}';
      _handleError(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _handleError('Google Sign-In cancelled');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      await _handleBackendAuth(userCredential);
    } catch (e) {
      _handleError('Google sign-in failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleBackendAuth(UserCredential credential) async {
    if (!credential.user!.emailVerified) {
      _handleError('Please verify your email address');
      await _auth.signOut();
      _isLoading = false;
      notifyListeners();
      return;
    }
    final idToken = await credential.user!.getIdToken();
    try {
      final response = await _apiService.post('/auth/firebase/login/', {
        'id_token': idToken,
      });
      await SecureStorage.storeTokens(
        access: response.data['access'],
        refresh: response.data['refresh'],
      );
      _role = response.data['user']?['role']?.toLowerCase() ?? 'student';
      _userName = response.data['user']?['name'];
      _userEmail = response.data['user']?['email'];
      _user = credential.user;
      _userId = credential.user!.uid;
      _isAuthenticated = true;
    } catch (e) {
      await _auth.signOut();
      _errorMessage = 'Backend authentication failed: $e';
      _handleError(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await SecureStorage.clearTokens();
    _role = 'student';
    _isAuthenticated = false;
    _user = null;
    _userId = '';
    notifyListeners();
  }

  void _handleError(String? error) {
    _errorMessage = error ?? 'An error occurred';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    });
    notifyListeners();
  }
}

//4 phase

// lib/core/providers/qr_provider.dart

class QrProvider with ChangeNotifier {
  String? _currentQrData;
  String? _errorMessage;
  int _remainingGenerations = 3;
  List<AttendanceRecord> _attendanceRecords = [];
  String? _qrExpiryTime;

  String? get currentQrData => _currentQrData;
  String? get errorMessage => _errorMessage;
  int get remainingGenerations => _remainingGenerations;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  String? get qrExpiryTime => _qrExpiryTime;

  Future<void> generateQrCode(String studentId, String classId) async {
    if (_remainingGenerations <= 0) {
      _errorMessage = 'QR generation limit reached';
      notifyListeners();
      return;
    }
    try {
      final response = await ApiService().post('/attendance/generate-qr/', {
        'student_id': studentId,
        'class_id': classId,
      });
      _currentQrData = response.data['qr_data'];
      _qrExpiryTime = response.data['expiry_time'];
      _remainingGenerations--;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to generate QR: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> verifyQrCode(String scannedData) async {
    try {
      final response = await ApiService().post('/attendance/verify-qr/', {
        'qr_data': scannedData,
      });
      final record = AttendanceRecord.fromJson(response.data['record']);
      _attendanceRecords.add(record);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Invalid QR Code: ${e.toString()}';
      notifyListeners();
    }
  }
}

class AttendanceRecord {
  final String id;
  final String status;
  final String studentName;
  final DateTime timestamp;
  final DateTime expiryTime;
  final bool verified;

  AttendanceRecord({
    required this.id,
    required this.status,
    required this.studentName,
    required this.timestamp,
    required this.expiryTime,
    this.verified = false,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      status: json['status'],
      studentName: json['student_name'],
      timestamp: DateTime.parse(json['timestamp']),
      expiryTime: DateTime.parse(json['expiry_time']),
      verified: json['verified'],
    );
  }
}

// 5 phase
// lib/features/dashboard/student/student_dashboard.dart

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AuroreAppBar(title: 'Student Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGenerationCard(context, qrProvider, auth),
            const SizedBox(height: 20),
            if (qrProvider.currentQrData != null) _buildQrDisplay(qrProvider),
          ],
        ),
      ),
    );
  }
  Future<String?> _getCurrentClassId(BuildContext context, String userId) async {
    try {
      final response = await ApiService().get('/students/$userId/classes/current/');
      return response.data['class_id'];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch class: $e')),
      );
      return null;
    }
  }
  Widget _buildGenerationCard(
      BuildContext context, QrProvider qrProvider, AuthProvider auth) {
    return NotionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance QR Generator',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining: ${qrProvider.remainingGenerations}',
                  style: const TextStyle(color: AppColors.darkGrey),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate QR'),
                  onPressed: () async {
                    final classId = await _getCurrentClassId(context, auth.userId);
                    if (classId != null) {
                      qrProvider.generateQrCode(auth.userId, classId);
                    }
                  },
                ),
              ],
            ),
            if (qrProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  qrProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDisplay(QrProvider qrProvider) {
    final expiryTime = DateTime.tryParse(qrProvider.qrExpiryTime ?? '');
    final isExpired = expiryTime != null && DateTime.now().isAfter(expiryTime);
    return NotionCard(
      child: Column(
        children: [
          Text(
            isExpired ? 'Expired QR Code' : 'Current QR Code',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (!isExpired)
            QrImageView(
              data: qrProvider.currentQrData!,
              version: QrVersions.auto,
              size: 200,
              embeddedImage: const AssetImage('assets/aurore_logo.png'),
            )
          else
            const Text(
              'QR code has expired. Generate a new one.',
              style: TextStyle(color: AppColors.errorRed),
            ),
          const SizedBox(height: 16),
          Text(
            'Valid until: ${qrProvider.qrExpiryTime}',
            style: const TextStyle(color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}

//lana ai class
class AiAnalysisResponse {
  final String status;
  final String? taskId;
  final double? probability;
  final String? result;

  AiAnalysisResponse({
    required this.status,
    this.taskId,
    this.probability,
    this.result,
  });

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResponse(
      status: json['status'],
      taskId: json['task_id'],
      probability: json['probability']?.toDouble(),
      result: json['result'],
    );
  }
}

class AiDetectorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _aiProbability = 0.0;
  String _analysisResult = '';
  bool _isAnalyzing = false;
  bool _isLoading = false;
  String? _error;

  double get aiProbability => _aiProbability;
  String get analysisResult => _analysisResult;
 // String get updateResults=> _updateResults;
  bool get isAnalyzing => _isAnalyzing;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> analyzeText(String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.post('/ai/analyze/', {
        'text': text,
        'model_version': 'lana_v2',
      });
      final result = AiAnalysisResponse.fromJson(response.data);
      if (result.status == 'processing') {
        _pollForResult(result.taskId!);
      } else {
        _aiProbability = result.probability ?? 0.0;
        _analysisResult = result.result ?? '';
        _isLoading = false;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _pollForResult(String taskId) async {
    const maxAttempts = 5;
    const delay = Duration(seconds: 2);

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      try {
        final response = await _apiService.get('/ai/results/$taskId/');
        final result = AiAnalysisResponse.fromJson(response.data);
        if (result.status == 'completed') {
          _aiProbability = result.probability ?? 0.0;
          _analysisResult = result.result ?? '';
          _isLoading = false;
          notifyListeners();
          return;
        }
      } on ApiException catch (e) {
        _error = e.message;
        break;
      }
    }

    _error = 'Analysis timed out';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> captureAndAnalyzeImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageBytes = await image.readAsBytes();
      _capturedImage = imageBytes;
      _isProcessingImage = true;
      _isAnalyzing = true;
      notifyListeners();

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      _extractedText = recognizedText.text;

      await analyzeText(_extractedText);

      await textRecognizer.close();
    } catch (e) {
      _error = 'Image processing failed: ${e.toString()}';
    } finally {
      _isProcessingImage = false;
      _isAnalyzing = false;
      notifyListeners();
    }
  }


  Uint8List? _capturedImage;
  String _extractedText = '';
  bool _isProcessingImage = false;

  Uint8List? get capturedImage => _capturedImage;
  String get extractedText => _extractedText;
  bool get isProcessingImage => _isProcessingImage;

  Future<Uint8List?> _showCameraDialog(BuildContext context) async {
    return await showDialog<Uint8List>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Student Work'),
        content: const Text('Take a photo of handwritten or printed work'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

}
//5 phase
// teacher dashboard

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _textController = TextEditingController();
  int _selectedTab = 0; // 0 = QR Scanner, 1 = AI Detector
  bool _isTorchOn = false; // Track torch state manually

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Tools'),
        actions: [
          IconButton(
            icon: Icon(
              _selectedTab == 0
                  ? (_isTorchOn ? Icons.flash_on : Icons.flash_off)
                  : Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: _selectedTab == 0
                ? () {
              _controller.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            }
                : () => _showDetectorHelp(context),
          ),
        ],
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Attendance'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Lana AI Detector'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildScannerView(context),
          _buildAiDetectorView(context),
        ],
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                qrProvider.verifyQrCode(barcodes.first.rawValue ?? '');
              }
            },
          ),
        ),
        Expanded(
          child: _buildAttendanceList(qrProvider),
        ),
      ],
    );
  }

  Widget _buildAttendanceList(QrProvider qrProvider) {
    return NotionCard(
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: qrProvider.attendanceRecords.length,
        itemBuilder: (context, index) {
          final record = qrProvider.attendanceRecords[index];
          return ListTile(
            leading: Icon(
              record.verified ? Icons.verified : Icons.warning,
              color: record.verified ? AppColors.secondary : AppColors.errorRed,
            ),
            title: Text(record.studentName),
            subtitle:
                Text(DateFormat('MMM dd, HH:mm').format(record.timestamp)),
          );
        },
      ),
    );
  }

  Widget _buildAiDetectorView(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.text_fields), text: "Text Input"),
              Tab(icon: Icon(Icons.camera_alt), text: "Camera"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTextInputTab(context),
                _buildCameraTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputTab(BuildContext context) {
    final detector = Provider.of<AiDetectorProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: NotionCard(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Paste student work here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyzeButton(detector),
          _buildAnalysisResults(detector),
        ],
      ),
    );
  }

  Widget _buildCameraTab(BuildContext context) {
    final detector = Provider.of<AiDetectorProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (detector.capturedImage != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.memory(detector.capturedImage!),
              ),
            )
          else
            Expanded(
              child: NotionCard(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Capture student work',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ElevatedButton.icon(
            icon: detector.isProcessingImage
                ? const CircularProgressIndicator()
                : const Icon(Icons.camera_alt),
            label: Text(
                detector.capturedImage == null ? 'Take Photo' : 'Retake Photo'),
            onPressed: detector.isProcessingImage
                ? null
                : () => detector.captureAndAnalyzeImage(context),
          ),
          if (detector.extractedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Extracted Text:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(detector.extractedText),
              ),
            ),
          ],
          _buildAnalysisResults(detector),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(AiDetectorProvider detector) {
    return ElevatedButton.icon(
      icon: detector.isAnalyzing
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.auto_awesome_motion),
      label:
          Text(detector.isAnalyzing ? 'Analyzing...' : 'Analyze with Lana AI'),
      onPressed: detector.isAnalyzing || _textController.text.isEmpty
          ? null
          : () => detector.analyzeText(_textController.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildAnalysisResults(AiDetectorProvider detector) {
    return Column(
      children: [
        if (detector.analysisResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          NotionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lana AI Analysis',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: detector.aiProbability / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getProbabilityColor(detector.aiProbability),
                ),
                const SizedBox(height: 8),
                Text(
                  '${detector.aiProbability.toStringAsFixed(1)}% AI probability',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getProbabilityColor(detector.aiProbability),
                  ),
                ),
                const SizedBox(height: 8),
                Text(detector.analysisResult),
              ],
            ),
          ),
        ],
        if (detector.error != null) ...[
          const SizedBox(height: 16),
          NotionCard(
            color: AppColors.errorRed.withOpacity(0.2),
            child: Text(
              detector.error!,
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ],
    );
  }

  Color _getProbabilityColor(double probability) {
    if (probability > 70) return Colors.red;
    if (probability > 40) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}

void _showDetectorHelp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('About Lana AI Detector'),
      content: const Text(
        'Lana AI Detector analyzes student submissions for signs of AI-generated content.\n\n'
        'Paste any text into the input field and click "Analyze" to get a probability score '
        'and detailed analysis of the writing style.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// 6 phase
// lib/widgets/notion_card.dart
class NotionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const NotionCard({
    super.key,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

// 7 phase

// lib/widgets/aurore_app_bar.dart

class AuroreAppBar extends AppBar {
  AuroreAppBar({required String title, List<Widget>? actions})
      : super(
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: actions,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
        );
}

//8 phase time table

class TimeSlot {
  final String startTime;
  final String endTime;
  final Map<int, String> subjects; // 0 = Monday, 4 = Friday
  final List<String> conflicts;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.subjects,
    this.conflicts = const [],
  });
}

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Consumer<TimetableController>(
        builder: (context, controller, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTimetableControls(context, controller),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.error != null
                      ? Text(controller.error!, style: const TextStyle(color: AppColors.errorRed))
                      : _buildTimetable(controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetableControls(BuildContext context, TimetableController controller) {
    final classController = TextEditingController();
    return NotionCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class ID'),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (classController.text.isNotEmpty) {
                  controller.generateTimetable({
                    'class_id': classController.text,
                    'constraints': {
                      'working_hours': {'start': '08:00', 'end': '18:00'},
                    },
                  });
                }
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetable(TimetableController controller) {
    if (controller.schedules.isEmpty) {
      return const Center(child: Text('No timetable available'));
    }

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return NotionCard(
      child: Table(
        border: TableBorder.all(color: AppColors.lightGrey),
        columnWidths: const {
          0: FixedColumnWidth(100),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              const SizedBox(),
              ...days.map((day) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ],
          ),
          ..._buildTimeSlotRows(controller.schedules),
        ],
      ),
    );
  }

  List<TableRow> _buildTimeSlotRows(List<Schedule> schedules) {
    final timeSlots = <String, Map<String, String>>{};
    for (var schedule in schedules) {
      final timeKey =
          '${DateFormat('HH:mm').format(schedule.startTime)}-${DateFormat('HH:mm').format(schedule.endTime)}';
      final dayIndex = schedule.startTime.weekday - 1;
      if (dayIndex >= 0 && dayIndex <= 4) {
        timeSlots.putIfAbsent(timeKey, () => {});
        timeSlots[timeKey]!['day$dayIndex'] = schedule.courseId;
      }
    }

    return timeSlots.entries.map((entry) {
      final time = entry.key;
      final subjects = entry.value;
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(time),
          ),
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(subjects['day$i'] ?? ''),
            ),
        ],
      );
    }).toList();
  }
}

//app style
class AppTextStyles {
  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle subheader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGrey,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.darkGrey,
  );
}

class TimetableWidget extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final bool showConflicts;

  const TimetableWidget({
    super.key,
    required this.timeSlots,
    this.showConflicts = false,
  });

  Map<int, TableColumnWidth> _buildColumnWidths() {
    return const {
      0: FixedColumnWidth(100), // Time column
      1: FlexColumnWidth(), // Monday
      2: FlexColumnWidth(), // Tuesday
      3: FlexColumnWidth(), // Wednesday
      4: FlexColumnWidth(), // Thursday
      5: FlexColumnWidth(), // Friday
    };
  }

  TableRow _buildTableHeader() {
    return TableRow(
      // Remove 'const' here
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lightGrey)),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Time', style: AppTextStyles.subheader),
        ),
        _HeaderCell('Monday'),
        _HeaderCell('Tuesday'),
        _HeaderCell('Wednesday'),
        _HeaderCell('Thursday'),
        _HeaderCell('Friday'),
      ],
    );
  }

  Widget _buildSubjectCell(TimeSlot slot, int dayIndex) {
    final subject = slot.subjects[dayIndex] ?? '';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        subject,
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTimeSlotRow(TimeSlot slot) {
    return TableRow(
      decoration: BoxDecoration(
        color: showConflicts && slot.conflicts.isNotEmpty
            ? Colors.red.withOpacity(0.1)
            : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${slot.startTime} - ${slot.endTime}'),
        ),
        _buildSubjectCell(slot, 0),
        _buildSubjectCell(slot, 1),
        _buildSubjectCell(slot, 2),
        _buildSubjectCell(slot, 3),
        _buildSubjectCell(slot, 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotionCard(
      padding: EdgeInsets.zero,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: AppColors.lightGrey),
        ),
        columnWidths: _buildColumnWidths(),
        children: [
          _buildTableHeader(),
          ...timeSlots.map(_buildTimeSlotRow),
        ],
      ),
    );
  }
}

// Add this helper widget for header cells
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: AppTextStyles.subheader,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// API Service
class ApiService {
  static const String _baseUrl = 'https://aurore-backend.onrender.com/api';
  final Dio _dio = Dio();
  final _storage = SecureStorage();

  ApiService() {
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final newToken = await _refreshToken();
          if (newToken != null) {
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          } else {
            await SecureStorage.clearTokens();
            navigatorKey.currentState?.pushReplacementNamed('/login');
          }
        }
        return handler.next(error);
      },


    ));
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final newAccessToken = response.data['access'];
      await SecureStorage.storeTokens(
        access: newAccessToken,
        refresh: refreshToken,
      );
      return newAccessToken;
    } catch (e) {
      return null;
    }
  }


  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(
        '$_baseUrl$path',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get('$_baseUrl$path');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleError(DioException error) {
    String errorMessage = 'An error occurred';
    if (error.response != null) {
      errorMessage = error.response?.data['detail'] ??
          error.response?.data['message'] ??
          'Server error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timed out. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Server took too long to respond.';
    }
    throw ApiException(
      message: errorMessage,
      statusCode: error.response?.statusCode ?? 500,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});
}


// Add this controller class
class TimetableController with ChangeNotifier {
  List<Schedule> _schedules = [];
  List<ScheduleConflict> _conflicts = [];
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  List<ScheduleConflict> get conflicts => _conflicts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> generateTimetable(Map<String, dynamic> constraints) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().post('/timetable/generate/', constraints);
      _schedules = (response.data['schedules'] as List)
          .map((json) => Schedule.fromJson(json))
          .toList();
      _conflicts = (response.data['conflicts'] as List)
          .map((json) => ScheduleConflict.fromJson(json))
          .toList();

      if (_conflicts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('${_conflicts.length} conflicts detected'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () => _showConflictDialog(context),
              ),
            ),
          );
        });
      }
    } catch (e) {
      // Add error notification
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Generation failed: ${e.toString()}')),
      );
    }
  }

  void _showConflictDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConflictResolutionDialog(
        conflict: _conflicts.first,
      ),
    );
  }

  Future<void> resolveConflict(ScheduleConflict conflict, ResolutionType type) async {
    try {
      await ApiService().post('/timetable/resolve-conflict/', {
        'conflict': conflict.toJson(),
        'resolution_type': type.toString().split('.').last,
      });
      _conflicts.remove(conflict);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to resolve conflict: ${e.toString()}';
      notifyListeners();
    }
  }
}

// In your existing dialog code
class ConflictResolutionDialog extends StatelessWidget {
  final ScheduleConflict conflict;

  const ConflictResolutionDialog({super.key, required this.conflict});

  Widget _buildConflictItem(String title, List<dynamic> conflicts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title Conflicts:', style: AppTextStyles.subheader),
          if (conflicts.isEmpty)
            Text('No conflicts', style: AppTextStyles.body)
          else
            Column(
              children: conflicts.map((c) => Text('- $c')).toList(),
            ),
        ],
      ),
    );
  }

  void _handleAIResolution(BuildContext context) {
    context.read<TimetableController>().resolveConflict(
          conflict,
          ResolutionType.aiAutomatic,
        );
    Navigator.pop(context);
  }

  void _navigateToManualFix(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualScheduleScreen(conflict: conflict),
      ),
    ).then((resolution) {
      if (resolution != null) {
        context.read<TimetableController>().resolveConflict(
              conflict,
              resolution as ResolutionType,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Conflict Detected'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConflictItem('Teacher', conflict.teacherConflicts),
          _buildConflictItem('Classroom', conflict.roomConflicts),
          _buildConflictItem('Time Slot', conflict.timeConflicts),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _handleAIResolution(context),
          child: const Text('AI Resolution'),
        ),
        TextButton(
          onPressed: () => _navigateToManualFix(context),
          child: const Text('Manual Fix'),
        ),
      ],
    );
  }
}
//phase 10

// lib/features/dashboard/admin/admin_dashboard.dart
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _timetableController = TimetableController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Admin Dashboard',
        actions: [_buildGenerationButton()],
      ),
      body: Column(
        children: [
          _buildSubjectInput(),
          Expanded(child: _buildTimetablePreview()),
        ],
      ),
    );
  }

  Widget _buildSubjectInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _subjectController,
        decoration: const InputDecoration(
          labelText: 'Subjects (comma-separated)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenerationButton() {
    return IconButton(
      icon: const Icon(Icons.auto_awesome_mosaic),
      onPressed: _generateTimetable,
      tooltip: 'Generate with AI',
    );
  }

  void _generateTimetable() {
    if (_subjectController.text.isNotEmpty) {
      _timetableController.generateTimetable({
        'subjects': _subjectController.text.split(',').map((s) => s.trim()).toList(),
        'constraints': {
          'working_hours': {'start': '08:00', 'end': '18:00'},
        },
      });
    }
  }
}


Widget _buildTimetablePreview() {
  return Consumer<TimetableController>(
    builder: (context, controller, child) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return ErrorWidget(controller.error!);
      }

      // Show conflict resolution dialog if conflicts exist
      if (controller.conflicts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => ConflictResolutionDialog(
              conflict: controller.conflicts.first,
            ),
          );
        });
      }

      return ListView.builder(
        itemCount: controller.schedules.length,
        itemBuilder: (context, index) {
          final schedule = controller.schedules[index];
          return ListTile(
            title: Text(schedule.courseId),
            subtitle: Text(
              '${DateFormat('HH:mm').format(schedule.startTime)} - '
              '${DateFormat('HH:mm').format(schedule.endTime)}',
            ),
            trailing: Text(schedule.room ?? 'N/A'),
          );
        },
      );
    },
  );
}

// phase11
// lib/core/mod
//schedule class
class Schedule {
  final String id;
  final String courseId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? room; // Optional, adjust based on your backend
  final String? teacher; // Optional

  Schedule({
    required this.id,
    required this.courseId,
    required this.startTime,
    required this.endTime,
    this.room,
    this.teacher,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String? ?? '',
      courseId: json['course_id'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      room: json['room'] as String?,
      teacher: json['teacher'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'room': room,
      'teacher': teacher,
    };
  }
}

// lib/core/enums/resolution_type.dart
enum ResolutionType {
  aiAutomatic,
  manualOverride,
  timeAdjustment,
  roomReassignment
}

//lib/models/schedule_conflict.dart

class ScheduleConflict {
  final List<String> teacherConflicts;
  final List<String> roomConflicts;
  final List<DateTimeRange> timeConflicts;

  const ScheduleConflict({
    this.teacherConflicts = const [],
    this.roomConflicts = const [],
    this.timeConflicts = const [],
  });

  factory ScheduleConflict.fromJson(Map<String, dynamic> json) {
    return ScheduleConflict(
      teacherConflicts: List<String>.from(json['teacher_conflicts']),
      roomConflicts: List<String>.from(json['room_conflicts']),
      timeConflicts: (json['time_conflicts'] as List)
          .map((t) => DateTimeRange(
        start: DateTime.parse(t['start']),
        end: DateTime.parse(t['end']),
      ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_conflicts': teacherConflicts,
      'room_conflicts': roomConflicts,
      'time_conflicts': timeConflicts
          .map((t) => {
        'start': t.start.toIso8601String(),
        'end': t.end.toIso8601String(),
      })
          .toList(),
    };
  }
}

// lib/core/services/ai_timetable_generator.dart
class AITimetableGenerator {
  static Future<List<Schedule>> generate(Map<String, dynamic> constraints) async {
    final apiService = ApiService();
    final response = await apiService.post('/timetable/generate/', constraints);
    return (response.data['schedules'] as List)
        .map((json) => Schedule.fromJson(json))
        .toList();
  }
}

// lib/features/scheduling/manual_schedule_screen.dart
class ManualScheduleScreen extends StatelessWidget {
  final ScheduleConflict conflict;

  const ManualScheduleScreen({super.key, required this.conflict});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Schedule Adjustment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolving Conflicts',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildConflictDetails(context),
            const SizedBox(height: 30),
            _buildResolutionOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conflict.teacherConflicts.isNotEmpty) ...[
              const Text('Teacher Conflicts:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...conflict.teacherConflicts.map((t) => Text('- $t')),
              const SizedBox(height: 10),
            ],
            if (conflict.roomConflicts.isNotEmpty) ...[
              const Text('Room Conflicts:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...conflict.roomConflicts.map((r) => Text('- $r')),
              const SizedBox(height: 10),
            ],
            if (conflict.timeConflicts.isNotEmpty) ...[
              const Text('Time Conflicts:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...conflict.timeConflicts.map((t) => Text(
                  '- ${DateFormat('HH:mm').format(t.start)} to ${DateFormat('HH:mm').format(t.end)}')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _resolveWithTimeAdjustment(context),
          child: const Text('Adjust Time Slots'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _resolveWithRoomChange(context),
          child: const Text('Change Room Assignment'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _resolveWithTeacherReassignment(context),
          child: const Text('Reassign Teacher'),
        ),
      ],
    );
  }

  void _resolveWithTimeAdjustment(BuildContext context) {
    // Implement time adjustment logic
    Navigator.pop(context, ResolutionType.timeAdjustment);
  }

  void _resolveWithRoomChange(BuildContext context) {
    // Implement room change logic
    Navigator.pop(context, ResolutionType.roomReassignment);
  }

  void _resolveWithTeacherReassignment(BuildContext context) {
    // Implement teacher reassignment logic
    Navigator.pop(context, ResolutionType.manualOverride);
  }
}

//phase 13

// lib/widgets/aurore_header.dart
class AuroreHeader extends StatelessWidget {
  final String title;

  const AuroreHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00CA8D), Color(0xFF2A2D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}
// phase 14

// lib/core/utils/responsive_layout.dart
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
//ManualScheduleScreen
void _resolveWithTimeAdjustment(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Adjust Time Slot'),
content: TextField(
decoration: const InputDecoration(labelText: 'New Start Time (HH:mm)'),
onSubmitted: (value) {
// Send to backend
Navigator.pop(context);
Navigator.pop(context, ResolutionType.timeAdjustment);
},
),
),
);
}

void _resolveWithRoomChange(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Change Room'),
content: TextField(
decoration: const InputDecoration(labelText: 'New Room ID'),
onSubmitted: (value) {
// Send to backend
Navigator.pop(context);
Navigator.pop(context, ResolutionType.roomReassignment);
},
),
),
);
}

void _resolveWithTeacherReassignment(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Reassign Teacher'),
content: TextField(
decoration: const InputDecoration(labelText: 'New Teacher ID'),
onSubmitted: (value) {
// Send to backend
Navigator.pop(context);
Navigator.pop(context, ResolutionType.manualOverride);
},
),
),
);
}
