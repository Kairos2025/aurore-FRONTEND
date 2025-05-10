import 'package:flutter/material.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class SupportScreenState extends State<SupportScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuroreAppBar(title: 'Support'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Support',
                style: AppTextStyles.subheader,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: AppTextStyles.label,
                  border: const OutlineInputBorder(),
                ),
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
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: AppTextStyles.label,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Message sent to support!',
                        style: AppTextStyles.body,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Submit',
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
