import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/models/schedule.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';
import 'package:aurore_school/widgets/notion_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timetableController = Provider.of<TimetableController>(context, listen: false);
      timetableController.fetchSchedulesForAdmin();
      timetableController.fetchConflicts();
    });
  }

  void _refresh() {
    final controller = Provider.of<TimetableController>(context, listen: false);
    controller.fetchSchedulesForAdmin();
    controller.fetchConflicts();
  }

  @override
  Widget build(BuildContext context) {
    final timetableController = Provider.of<TimetableController>(context);

    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timetableController.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = timetableController.schedules[index];
                  final hasConflict = timetableController.conflicts.any((c) => c.scheduleId == schedule.id);
                  return NotionCard(
                    title: schedule.subject,
                    description: '${schedule.day} - ${schedule.startTime.hour}:00',
                    timestamp: schedule.lastUpdated,
                    category: schedule.category,
                    hasConflict: hasConflict,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Conflict Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: timetableController.conflicts.length.toDouble(),
                        color: Colors.red,
                        title: 'Conflicts',
                      ),
                      PieChartSectionData(
                        value: timetableController.schedules.length.toDouble(),
                        color: Colors.green,
                        title: 'Resolved',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Manage Timetable',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: timetableController.conflicts.isEmpty
                    ? () {
                  timetableController.generateTimetable({
                    'startDate': DateTime.now().toIso8601String(),
                    'endDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                  });
                }
                    : null,
                child: const Text('Generate New Timetable'),
              ),
              const SizedBox(height: 16),
              _buildConflictResolutionSection(timetableController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConflictResolutionSection(TimetableController timetableController) {
    final conflicts = timetableController.conflicts;
    if (conflicts.isEmpty) {
      return const Text('No conflicts to resolve.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resolve Conflicts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: conflicts.length,
          itemBuilder: (context, index) {
            final conflict = conflicts[index];
            final schedule = timetableController.schedules.firstWhere(
                  (s) => s.id == conflict.scheduleId,
              orElse: () => Schedule(
                id: '',
                teacherId: '',
                roomId: '',
                subject: 'Unknown',
                startTime: DateTime.now(),
                endTime: DateTime.now(),
                day: 'Unknown',
              ),
            );

            return NotionCard(
              title: 'Conflict: ${schedule.subject}',
              description: conflict.reason,
              timestamp: schedule.lastUpdated,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Resolve Conflict: ${schedule.subject}'),
                    content: Text(conflict.reason),
                    actions: [
                      TextButton(
                        onPressed: () {
                          timetableController.resolveConflict(conflict, 'manual');
                          Navigator.pop(context);
                        },
                        child: const Text('Resolve Manually'),
                      ),
                      TextButton(
                        onPressed: () {
                          timetableController.resolveConflict(conflict, 'auto');
                          Navigator.pop(context);
                        },
                        child: const Text('Auto Resolve'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}