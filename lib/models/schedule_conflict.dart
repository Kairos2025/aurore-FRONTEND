import 'package:flutter/material.dart';

class TimetableSchedule {
  final String id;
  final String teacherId;
  final String roomId;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final String day;

  TimetableSchedule({
    required this.id,
    required this.teacherId,
    required this.roomId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  factory TimetableSchedule.fromJson(Map<String, dynamic> json) {
    return TimetableSchedule(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      roomId: json['roomId'] as String,
      subject: json['subject'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      day: json['day'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'roomId': roomId,
      'subject': subject,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'day': day,
    };
  }
}

class ScheduleConflict {
  final String scheduleId;
  final String reason;
  final String severity;

  const ScheduleConflict({
    required this.scheduleId,
    required this.reason,
    required this.severity,
  });

  bool get hasConflict => severity != 'none';

  Color get uiColor {
    if (hasConflict) return Colors.red;
    return Colors.grey;
  }

  factory ScheduleConflict.fromJson(Map<String, dynamic> json) {
    return ScheduleConflict(
      scheduleId: json['scheduleId'] as String,
      reason: json['reason'] as String,
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'reason': reason,
      'severity': severity,
    };
  }
}