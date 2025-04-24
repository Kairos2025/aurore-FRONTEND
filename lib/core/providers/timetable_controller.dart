import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/models/schedule.dart' show Schedule;
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/utils/secure_storage.dart';
import 'dart:convert'; // Added for jsonDecode

class TimetableController extends ChangeNotifier {
  final Dio _dio;
  final SecureStorage _storage;
  List<Schedule> _schedules = [];
  List<ScheduleConflict> _conflicts = [];

  TimetableController(this._dio, this._storage);

  List<Schedule> get schedules => _schedules;
  List<ScheduleConflict> get conflicts => _conflicts;

  Future<void> fetchSchedules(String userId, String role) async {
    try {
      final response = await _dio.get(
        'https://aurore-backend.onrender.com/schedules',
        queryParameters: {'userId': userId, 'role': role},
      );
      _schedules = (response.data['schedules'] as List)
          .map((json) => Schedule.fromJson(json))
          .toList();
      // Store schedules in SecureStorage
      await _storage.write(
        key: 'schedules',
        value: jsonEncode(_schedules.map((s) => s.toJson()).toList()),
      );
      notifyListeners();
    } catch (e) {
      final cachedSchedules = await _storage.read(key: 'schedules');
      if (cachedSchedules != null) {
        _schedules = (jsonDecode(cachedSchedules) as List)
            .map((json) => Schedule.fromJson(json))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> fetchSchedulesForAdmin() async {
    try {
      final response = await _dio.get(
        'https://aurore-backend.onrender.com/admin/schedules',
      );
      _schedules = (response.data['schedules'] as List)
          .map((json) => Schedule.fromJson(json))
          .toList();
      await _storage.write(
        key: 'admin_schedules',
        value: jsonEncode(_schedules.map((s) => s.toJson()).toList()),
      );
      notifyListeners();
    } catch (e) {
      final cachedSchedules = await _storage.read(key: 'admin_schedules');
      if (cachedSchedules != null) {
        _schedules = (jsonDecode(cachedSchedules) as List)
            .map((json) => Schedule.fromJson(json))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> fetchConflicts() async {
    try {
      final response = await _dio.get(
        'https://aurore-backend.onrender.com/conflicts',
      );
      _conflicts = (response.data['conflicts'] as List)
          .map((json) => ScheduleConflict.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resolveConflict(ScheduleConflict conflict, String resolution) async {
    try {
      final response = await _dio.post(
        'https://aurore-backend.onrender.com/conflicts/resolve',
        data: {
          'conflictId': conflict.scheduleId,
          'resolution': resolution,
        },
      );
      final updatedSchedule = Schedule.fromJson(response.data['schedule']);
      _schedules = _schedules.map((s) => s.id == updatedSchedule.id ? updatedSchedule : s).toList();
      _conflicts.removeWhere((c) => c.scheduleId == conflict.scheduleId);
      await _storage.logEvent('conflict_resolved', {
        'scheduleId': conflict.scheduleId,
        'resolution': resolution,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateTimetable(Map<String, dynamic> params) async {
    try {
      final response = await _dio.post(
        'https://aurore-backend.onrender.com/admin/generate-timetable',
        data: params,
      );
      final updatedSchedule = Schedule.fromJson(response.data['schedule']);
      _schedules = _schedules.map((s) => s.id == updatedSchedule.id ? updatedSchedule : s).toList();
      await fetchConflicts();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadOfflineSchedules() async {
    final cachedSchedules = await _storage.read(key: 'schedules');
    if (cachedSchedules != null) {
      _schedules = (jsonDecode(cachedSchedules) as List)
          .map((json) => Schedule.fromJson(json))
          .toList();
      notifyListeners();
    }
  }
}