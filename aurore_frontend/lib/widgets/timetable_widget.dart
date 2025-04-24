import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/models/schedule.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/utils/app_text_styles.dart';
import 'package:aurore_school/utils/secure_storage.dart';
import 'package:aurore_school/widgets/conflict_resolution_dialog.dart';
import 'package:aurore_school/widgets/notion_card.dart';
import 'package:vibration/vibration.dart';

class TimetableWidget extends StatefulWidget {
  final List<Schedule> schedules;

  const TimetableWidget({
    super.key,
    required this.schedules,
  });

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _storeSchedules();
  }

  Future<void> _storeSchedules() async {
    await _secureStorage.write(
      key: 'timetable_schedules',
      value: widget.schedules.map((s) => s.toJson().toString()).join(';'),
    );
  }

  void _showConflictDialog(BuildContext context, Schedule schedule) {
    final timetableController = Provider.of<TimetableController>(context, listen: false);
    final conflict = timetableController.conflicts.firstWhere(
          (c) => c.scheduleId == schedule.id,
      orElse: () => const ScheduleConflict(
        scheduleId: '',
        reason: 'Unknown conflict',
        severity: 'low',
      ),
    );

    showDialog(
      context: context,
      builder: (context) => ConflictResolutionDialog(conflict: conflict),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetableController = Provider.of<TimetableController>(context);

    if (widget.schedules.isEmpty) {
      return const Center(
        child: Text(
          'No schedules available for this day.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.schedules.length,
      itemBuilder: (context, index) {
        final schedule = widget.schedules[index];
        final hasConflict = timetableController.conflicts.any((c) => c.scheduleId == schedule.id);

        return NotionCard(
          title: schedule.subject,
          description: '${schedule.roomId} | ${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')}',
          timestamp: schedule.lastUpdated,
          category: schedule.category,
          priority: schedule.priority,
          hasConflict: hasConflict,
          onTap: hasConflict
              ? () {
            Vibration.vibrate(duration: 50);
            _showConflictDialog(context, schedule);
          }
              : null,
        );
      },
    );
  }
}