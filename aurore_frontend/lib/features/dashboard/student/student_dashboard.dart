import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/auth_provider.dart';
import 'package:aurore_school/core/providers/qr_provider.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';
import 'package:aurore_school/widgets/notion_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final qrProvider = Provider.of<QrProvider>(context);

    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Student Dashboard',
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppColors.iconPrimary,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${authProvider.user?.displayName ?? 'Student'}!',
                style: AppTextStyles.header,
              ),
              const SizedBox(height: 16),
              Text(
                'Your QR Code',
                style: AppTextStyles.subheader,
              ),
              const SizedBox(height: 16),
              Center(
                child: IconButton(
                  icon: Icon(
                    Icons.qr_code,
                    size: 48,
                    color: AppColors.iconPrimary,
                  ),
                  onPressed: () {
                    qrProvider.scanQrCode(Barcode(
                      rawValue: 'student-id-123',
                      format: BarcodeFormat.qrCode,
                      rawBytes: null,
                    ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (qrProvider.qrData != null)
                Center(
                  child: QrImageView(
                    data: qrProvider.qrData!,
                    size: 200,
                  ),
                ),
              const SizedBox(height: 16),
              if (qrProvider.qrData != null) ...[
                const Divider(),
                Text(
                  'Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
                  style: AppTextStyles.caption,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: AppTextStyles.subheader,
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const NotionCard(
                    title: 'Class Attended',
                    description: 'Mathematics - Room 101',
                    timestamp: null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
