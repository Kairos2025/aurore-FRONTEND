import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/providers/timetable_controller.dart';
import '../models/schedule_conflict.dart';
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
        style: AppTextStyles.header,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reason: ${widget.conflict.reason}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Text(
              'Severity: ${widget.conflict.severity}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _manualResolutionInput = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Manual Resolution',
                labelStyle: AppTextStyles.label,
                hintText: 'Enter resolution details',
                hintStyle: AppTextStyles.label,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (_error != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: AppTextStyles.error,
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
            style: AppTextStyles.button.copyWith(color: AppColors.neutral),
          ),
        ),
        OutlinedButton(
          onPressed: _isLoading ? null : () => _submitResolution('auto', ''),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
          ),
          child: Text(
            'Auto Resolve',
            style: AppTextStyles.button,
          ),
        ),
        OutlinedButton(
          onPressed: _isLoading
              ? null
              : () => _submitResolution('manual', _manualResolutionInput),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
          ),
          child: Text(
            'Resolve Manually',
            style: AppTextStyles.button,
          ),
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
          SnackBar(
            content: Text(
              'Conflict resolved successfully!',
              style: AppTextStyles.body,
            ),
          ),
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
