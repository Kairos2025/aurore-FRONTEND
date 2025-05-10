import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/qr_provider.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';
import 'package:aurore_school/widgets/aurore_button.dart';
import 'package:aurore_school/widgets/aurore_header.dart';
import 'package:aurore_school/widgets/notion_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _refresh() {
    // Implement refresh logic here
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context);

    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Teacher Dashboard',
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.iconPrimary,
            ),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuroreHeader(title: 'Welcome, Teacher!'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const NotionCard(
                    title: 'Scan Student QR Code',
                    description: 'Scan a student QR code to mark attendance.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (barcodeCapture) {
                        final barcode = barcodeCapture.barcodes.first;
                        qrProvider.scanQrCode(barcode).then((success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'QR Code Scanned: ${barcode.rawValue}',
                                  style: AppTextStyles.body,
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuroreButton(
                    text: qrProvider.isScanning ? 'Stop Scanning' : 'Scan QR Code',
                    onPressed: qrProvider.isScanning
                        ? qrProvider.stopScanning
                        : qrProvider.startScanning,
                    icon: qrProvider.isScanning ? Icons.stop : Icons.qr_code_scanner,
                    iconColor: AppColors.iconPrimary,
                  ),
                  if (qrProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Error: ${qrProvider.error}',
                        style: AppTextStyles.error,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Attendance Overview',
                    style: AppTextStyles.subheader,
                  ),
                  const SizedBox(height: 16),
                  if (qrProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 5,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 8,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                                  return Text(
                                    days[value.toInt()],
                                    style: AppTextStyles.caption,
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Scans',
                    style: AppTextStyles.subheader,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return NotionCard(
                        title: 'Student ${index + 1}',
                        description: 'Scanned at ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
                        timestamp: DateTime.now(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AuroreButton(
                    text: 'View All Scans',
                    onPressed: () {},
                    icon: Icons.history,
                    iconColor: AppColors.iconPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
