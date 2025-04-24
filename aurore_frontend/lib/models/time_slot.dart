import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';

/// Represents a time slot in a weekly timetable, enriched with metadata for
/// advanced scheduling, conflict management, and UI/backend integration.
class TimeSlot {
  /// Start time of the time slot.
  final DateTime startDateTime;

  /// End time of the time slot.
  final DateTime endDateTime;

  /// Details for each day (0 = Monday, 4 = Friday), mapping to subject, teacher, and room.
  final Map<int, Map<String, String>> slotDetails;

  /// Details of conflicts per day (e.g., overlapping schedule IDs).
  final Map<int, String> conflictDetails;

  /// Priority level for conflict resolution (e.g., "High", "Medium", "Low").
  final String priority;

  /// Timestamp of the last update for sync tracking.
  final DateTime lastUpdated;

  /// Error message if the time slot creation failed, null if successful.
  final String? errorMessage;

  /// Numeric error code for specific error types (e.g., 100 for parsing error).
  final int? errorCode;

  TimeSlot({
    required this.startDateTime,
    required this.endDateTime,
    required this.slotDetails,
    this.conflictDetails = const {},
    this.priority = 'Medium',
    required this.lastUpdated,
    this.errorMessage,
    this.errorCode,
  }) {
    // Validate inputs
    if (startDateTime.isAfter(endDateTime)) {
      throw ArgumentError('startDateTime must be before endDateTime');
    }
    if (!['High', 'Medium', 'Low'].contains(priority)) {
      throw ArgumentError('Invalid priority: $priority');
    }
    for (final day in slotDetails.keys) {
      if (day < 0 || day > 4) {
        throw ArgumentError('Invalid day index: $day (must be 0-4)');
      }
    }
  }

  /// Creates an instance from JSON data, with robust error handling and defaults.
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    try {
      final startTimeStr = json['start_time'] as String?;
      final endTimeStr = json['end_time'] as String?;
      final lastUpdatedStr = json['last_updated'] as String?;
      final startDateTime = DateTime.tryParse(startTimeStr ?? '') ?? DateTime.now();
      final endDateTime = DateTime.tryParse(endTimeStr ?? '') ?? DateTime.now().add(const Duration(hours: 1));
      final lastUpdated = DateTime.tryParse(lastUpdatedStr ?? '') ?? DateTime.now();

      final slotDetailsJson = json['slot_details'] as Map<String, dynamic>? ?? {};
      final slotDetails = slotDetailsJson.map(
            (key, value) => MapEntry(
          int.parse(key),
          Map<String, String>.from(value as Map),
        ),
      );

      final conflictDetailsJson = json['conflict_details'] as Map<String, dynamic>? ?? {};
      final conflictDetails = conflictDetailsJson.map(
            (key, value) => MapEntry(int.parse(key), value as String),
      );

      final priority = json['priority'] as String? ?? 'Medium';
      if (!['High', 'Medium', 'Low'].contains(priority)) {
        throw FormatException('Invalid priority: $priority');
      }

      return TimeSlot(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        slotDetails: slotDetails,
        conflictDetails: conflictDetails,
        priority: priority,
        lastUpdated: lastUpdated,
        errorMessage: json['error_message'] as String?,
        errorCode: json['error_code'] as int?,
      );
    } catch (e) {
      return TimeSlot(
        startDateTime: DateTime.now(),
        endDateTime: DateTime.now().add(const Duration(hours: 1)),
        slotDetails: {},
        lastUpdated: DateTime.now(),
        errorMessage: 'Failed to parse time slot: $e',
        errorCode: 100, // Parsing error
      );
    }
  }

  /// Converts the instance to JSON for backend syncing or local storage.
  Map<String, dynamic> toJson() {
    return {
      'start_time': startDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
      'slot_details': slotDetails.map(
            (key, value) => MapEntry(key.toString(), value),
      ),
      'conflict_details': conflictDetails.map(
            (key, value) => MapEntry(key.toString(), value),
      ),
      'priority': priority,
      'last_updated': lastUpdated.toIso8601String(),
      'error_message': errorMessage,
      'error_code': errorCode,
    };
  }

  /// Returns a user-friendly string for UI display, styled with AppTextStyles.
  String get displayString {
    if (errorMessage != null) {
      return 'Error: $errorMessage (Code: $errorCode)';
    }
    final timeStr = '${_formatTime(startDateTime)} - ${_formatTime(endDateTime)}';
    final subjectsStr = slotDetails.entries
        .map((e) => '${_dayName(e.key)}: ${e.value['subject'] ?? 'None'}')
        .join(', ');
    final conflictStr = conflictDetails.isNotEmpty ? ' (Conflicts: ${conflictDetails.length})' : '';
    return '$timeStr | $subjectsStr$conflictStr';
  }

  /// Returns a color for UI display based on conflict status and priority.
  Color get uiColor {
    if (conflictDetails.isNotEmpty) return AppColors.error;
    switch (priority) {
      case 'High':
        return AppColors.primary;
      case 'Medium':
        return AppColors.secondary;
      case 'Low':
        return AppColors.neutral;
      default:
        return AppColors.neutral;
    }
  }

  /// Returns the duration of the time slot in minutes.
  int get duration => endDateTime.difference(startDateTime).inMinutes;

  /// Checks if the time slot is valid (no error and has valid times).
  bool get isValid => errorMessage == null && startDateTime.isBefore(endDateTime);

  /// Helper method to format DateTime as HH:mm.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Helper method to get day name from index (0 = Monday, 4 = Friday).
  String _dayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return days[dayIndex];
  }
}