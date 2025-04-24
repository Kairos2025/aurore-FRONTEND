import 'package:aurore_school/core/constants/app_text_styles.dart';

/// Represents the response from an AI detection analysis, including detailed metrics
/// and error handling for robust UI integration and backend synchronization.
class AiAnalysisResponse {
  /// Whether the content is AI-generated.
  final bool isAiGenerated;

  /// Confidence score of the AI detection (0.0 to 1.0).
  final double confidence;

  /// Timestamp of when the analysis was performed.
  final DateTime timestamp;

  /// Type of content analyzed (e.g., text, image).
  final String detectionType;

  /// Error message if the analysis failed, null if successful.
  final String? errorMessage;

  /// Breakdown of probabilities for different detection categories (e.g., AI vs. human).
  final Map<String, double> probabilityBreakdown;

  AiAnalysisResponse({
    required this.isAiGenerated,
    required this.confidence,
    required this.timestamp,
    this.detectionType = 'text', // Default to text
    this.errorMessage,
    this.probabilityBreakdown = const {},
  }) {
    // Validate confidence
    if (confidence < 0.0 || confidence > 1.0) {
      throw ArgumentError('Confidence must be between 0.0 and 1.0');
    }
  }

  /// Creates an instance from JSON data, with error handling and default values.
  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    try {
      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
      if (confidence < 0.0 || confidence > 1.0) {
        throw FormatException('Invalid confidence value: $confidence');
      }

      final probabilityBreakdown = (json['probability_breakdown'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      ) ??
          {};

      return AiAnalysisResponse(
        isAiGenerated: json['is_ai_generated'] as bool? ?? false,
        confidence: confidence,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        detectionType: json['detection_type'] as String? ?? 'text',
        errorMessage: json['error_message'] as String?,
        probabilityBreakdown: probabilityBreakdown,
      );
    } catch (e) {
      return AiAnalysisResponse(
        isAiGenerated: false,
        confidence: 0.0,
        timestamp: DateTime.now(),
        errorMessage: 'Failed to parse AI analysis: $e',
      );
    }
  }

  /// Converts the instance to JSON for backend syncing or local storage.
  Map<String, dynamic> toJson() {
    return {
      'is_ai_generated': isAiGenerated,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'detection_type': detectionType,
      'error_message': errorMessage,
      'probability_breakdown': probabilityBreakdown,
    };
  }

  /// Returns a user-friendly string for UI display, styled with AppTextStyles.
  String get displayString {
    if (errorMessage != null) {
      return 'Error: $errorMessage';
    }
    final result = isAiGenerated ? 'AI-Generated' : 'Human-Written';
    final confidencePercent = (confidence * 100).toStringAsFixed(2);
    return '$result (Confidence: $confidencePercent%)';
  }

  /// Checks if the analysis is valid (no error and confidence is reasonable).
  bool get isValid => errorMessage == null && confidence > 0.0;
}
