class Schedule {
  final String id;
  final String teacherId;
  final String roomId;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final String day; // Added
  final String category; // Added
  final Map<String, String> conflictDetails; // Added
  final String conflictSeverity; // Added
  final DateTime lastUpdated; // Added
  final int priority; // Added

  Schedule({
    required this.id,
    required this.teacherId,
    required this.roomId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.day,
    this.category = 'Unknown',
    this.conflictDetails = const {},
    this.conflictSeverity = 'none',
    DateTime? lastUpdated,
    this.priority = 0,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      roomId: json['roomId'] as String,
      subject: json['subject'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      day: json['day'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Unknown',
      conflictDetails: (json['conflictDetails'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
      conflictSeverity: json['conflictSeverity'] as String? ?? 'none',
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
      priority: json['priority'] as int? ?? 0,
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
      'category': category,
      'conflictDetails': conflictDetails,
      'conflictSeverity': conflictSeverity,
      'lastUpdated': lastUpdated.toIso8601String(),
      'priority': priority,
    };
  }
}