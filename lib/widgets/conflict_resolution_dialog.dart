import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/utils/app_text_styles.dart';
import 'package:vibration/vibration.dart';

class ConflictResolutionDialog extends StatefulWidget {
  final ScheduleConflict conflict;

  const ConflictResolutionDialog({super.key, required this.conflict});

  @override
  State<ConflictResolutionDialog> createState() => _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  String? _error;
  String _manualResolutionInput = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Resolve Conflict',
        style: AppTextStyles.title,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reason: ${widget.conflict.reason}'),
            const SizedBox(height: 16),
            Text('Severity: ${widget.conflict.severity}'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _manualResolutionInput = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Manual Resolution',
                border: OutlineInputBorder(),
                hintText: 'Enter resolution details',
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyBold.copyWith(color: Colors.grey),
          ),
        ),
        OutlinedButton(
          onPressed: _isLoading ? null : () => _submitResolution('auto', ''),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text('Auto Resolve'),
        ),
        OutlinedButton(
          onPressed: _isLoading
              ? null
              : () => _submitResolution('manual', _manualResolutionInput),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text('Resolve Manually'),
        ),
      ],
    );
  }

  Future<void> _submitResolution(String resolutionType, String manualResolution) async {
    if (resolutionType == 'manual' && manualResolution.trim().isEmpty) {
      setState(() {
        _error = 'Please provide a resolution description.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resolution = resolutionType == 'manual' ? manualResolution : 'auto';
      await Provider.of<TimetableController>(context, listen: false)
          .resolveConflict(widget.conflict, resolution);

      await Vibration.vibrate(duration: 50);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conflict resolved successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to resolve conflict: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}