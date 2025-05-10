import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (context.mounted) {
          final route = authProvider.user != null
              ? _roleBasedRoute(authProvider.role ?? 'student')
              : '/login';
          Navigator.pushReplacementNamed(context, route);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _googleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.googleSignIn();
      if (context.mounted) {
        final route = authProvider.user != null
            ? _roleBasedRoute(authProvider.role ?? 'student')
            : '/login';
        Navigator.pushReplacementNamed(context, route);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
        );
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/aurore_logo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'Login',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.header,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTextStyles.label,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTextStyles.label,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.iconPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reset-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.label,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _login(context),
                        child: Text(
                          'Login',
                          style: AppTextStyles.button,
                        ),
                      ),
                const SizedBox(height: 16),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : OutlinedButton(
                        onPressed: () => _googleSignIn(context),
                        child: Text(
                          'Sign in with Google',
                          style: AppTextStyles.button,
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyles.body,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.label,
                      ),
                    ),
                  ],
                ),
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.error!,
                      style: AppTextStyles.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
