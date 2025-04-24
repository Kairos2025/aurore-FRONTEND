enum ResolutionType {
  // Adjust the time slot of the conflicting schedule
  timeAdjustment,

  // Reassign the room for the conflicting schedule
  roomReassignment,

  // Manually resolve the conflict with custom input
  manual,

  // Use AI-suggested resolution based on timetable analysis
  aiSuggested,

  // Cancel the conflicting schedule
  cancellation;

  // Converts enum value to a JSON-compatible string for API requests
  String toJson() {
    switch (this) {
      case timeAdjustment:
        return 'time_adjustment';
      case roomReassignment:
        return 'room_reassignment';
      case manual:
        return 'manual';
      case aiSuggested:
        return 'ai_suggested';
      case cancellation:
        return 'cancellation';
    }
  }

  // Parses a JSON string from the backend into a ResolutionType
  static ResolutionType fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'time_adjustment':
        return timeAdjustment;
      case 'room_reassignment':
        return roomReassignment;
      case 'manual':
      case 'manual_override': // Backward compatibility
        return manual;
      case 'ai_suggested':
      case 'ai_automatic': // Backward compatibility
        return aiSuggested;
      case 'cancellation':
        return cancellation;
      default:
        return manual; // Fallback for unknown types
    }
  }

  // User-friendly display name for UI components (e.g., dropdowns, dialogs)
  String get displayName {
    switch (this) {
      case timeAdjustment:
        return 'Time Adjustment';
      case roomReassignment:
        return 'Room Reassignment';
      case manual:
        return 'Manual Resolution';
      case aiSuggested:
        return 'AI-Suggested Resolution';
      case cancellation:
        return 'Cancel Schedule';
    }
  }

  // Brief description for UI tooltips or helper text
  String get description {
    switch (this) {
      case timeAdjustment:
        return 'Change the time slot to resolve the conflict.';
      case roomReassignment:
        return 'Assign a different room to avoid the conflict.';
      case manual:
        return 'Manually specify a custom resolution.';
      case aiSuggested:
        return 'Use an AI-generated suggestion to resolve the conflict.';
      case cancellation:
        return 'Cancel the conflicting schedule to resolve the issue.';
    }
  }
}