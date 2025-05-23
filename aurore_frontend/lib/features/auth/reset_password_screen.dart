import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/auth_provider.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: const AuroreAppBar(title: 'Reset Password'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: AppTextStyles.label,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  await authProvider.resetPassword(_emailController.text);
                  if (authProvider.error == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Send Reset Link',
                  style: AppTextStyles.button,
                ),
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
    );
  }
}
