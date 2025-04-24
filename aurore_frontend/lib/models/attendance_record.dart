import 'package:aurore_school/core/constants/app_text_styles.dart';

/// Represents an attendance record for a student, including detailed metadata
/// and error handling for robust UI integration and backend synchronization.
class AttendanceRecord {
  /// Unique identifier for the attendance record.
  final String id;

  /// Identifier of the student.
  final String studentId;

  /// Date of the attendance record (ISO 8601 format).
  final DateTime date;

  /// Whether the student was present.
  final bool isPresent;

  /// Timestamp of when the attendance was recorded (e.g., via QR scan).
  final DateTime scanTimestamp;

  /// Location where the attendance was recorded (e.g., classroom ID).
  final String? location;

  /// Additional notes provided by the teacher (e.g., reason for absence).
  final String? notes;

  /// Whether the record has been verified by an admin.
  final bool isVerified;

  /// Error message if the record creation failed, null if successful.
  final String? errorMessage;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.isPresent,
    required this.scanTimestamp,
    this.location,
    this.notes,
    this.isVerified = false,
    this.errorMessage,
  });

  /// Creates an instance from JSON data, with error handling and default values.
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    try {
      final dateStr = json['date'] as String?;
      final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
      final timestampStr = json['scan_timestamp'] as String?;
      final scanTimestamp = DateTime.tryParse(timestampStr ?? '') ?? DateTime.now();

      return AttendanceRecord(
        id: json['id'] as String? ?? '',
        studentId: json['student_id'] as String? ?? '',
        date: date,
        isPresent: json['is_present'] as bool? ?? false,
        scanTimestamp: scanTimestamp,
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        errorMessage: json['error_message'] as String?,
      );
    } catch (e) {
      return AttendanceRecord(
        id: '',
        studentId: '',
        date: DateTime.now(),
        isPresent: false,
        scanTimestamp: DateTime.now(),
        errorMessage: 'Failed to parse attendance record: $e',
      );
    }
  }

  /// Converts the instance to JSON for backend syncing or local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date.toIso8601String(),
      'is_present': isPresent,
      'scan_timestamp': scanTimestamp.toIso8601String(),
      'location': location,
      'notes': notes,
      'is_verified': isVerified,
      'error_message': errorMessage,
    };
  }

  /// Returns a user-friendly string for UI display, styled with AppTextStyles.
  String get displayString {
    if (errorMessage != null) {
      return 'Error: $errorMessage';
    }
    final status = isPresent ? 'Present' : 'Absent';
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final verification = isVerified ? ' (Verified)' : '';
    return 'Student $studentId: $status on $dateStr$verification';
  }

  /// Checks if the record is valid (no error and has valid ID).
  bool get isValid => errorMessage == null && id.isNotEmpty && studentId.isNotEmpty;
}