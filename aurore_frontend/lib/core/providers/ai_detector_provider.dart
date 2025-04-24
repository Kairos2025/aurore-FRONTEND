import 'package:flutter/material.dart';
import 'package:aurore_school/core/providers/api_service.dart';

class AiDetectorProvider extends ChangeNotifier {
  final ApiService _apiService;
  String _inputText = '';
  double? _aiProbability;
  bool _isLoading = false;
  String? _error;

  AiDetectorProvider({required ApiService apiService}) : _apiService = apiService;

  String get inputText => _inputText;
  double? get aiProbability => _aiProbability;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateInputText(String text) {
    _inputText = text;
    _aiProbability = null;
    _error = null;
    notifyListeners();
  }

  Future<void> detectAiContent() async {
    if (_inputText.isEmpty) {
      _error = 'Please enter some text to analyze.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        '/ai/detect/',
        data: {'text': _inputText},
      );

      _aiProbability = (response.data['probability'] as num).toDouble();
    } catch (e) {
      try {
        final response = await _apiService.dio.post(
          '/ai/detect/',
          data: {'text': _inputText},
        );
        _aiProbability = (response.data['probability'] as num).toDouble();
      } catch (e) {
        _error = 'Failed to analyze text: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _inputText = '';
    _aiProbability = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}