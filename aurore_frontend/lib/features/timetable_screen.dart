import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/models/schedule.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';
import 'package:aurore_school/widgets/aurore_button.dart';
import 'package:aurore_school/widgets/aurore_header.dart';
import 'package:aurore_school/widgets/timetable_widget.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'Monday';

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<TimetableController>(context, listen: false);
    controller.fetchSchedules('user-id', 'student');
    controller.loadOfflineSchedules();
  }

  void _refresh() {
    final controller = Provider.of<TimetableController>(context, listen: false);
    controller.fetchSchedules('user-id', 'student');
  }

  List<Schedule> _filterSchedules(List<Schedule> schedules, String day) {
    return schedules.where((schedule) => schedule.day.toLowerCase() == day.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TimetableController>(context);
    final filteredSchedules = _filterSchedules(controller.schedules, _selectedDay);

    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Timetable',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuroreHeader(title: 'Your Timetable'),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedDay,
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                    .map((day) => DropdownMenuItem(
                  value: day,
                  child: Text(day),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TimetableWidget(schedules: filteredSchedules),
              const SizedBox(height: 24),
              const Text(
                'Schedule Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: controller.schedules.where((s) => s.day == 'Monday').length.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: controller.schedules.where((s) => s.day == 'Tuesday').length.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: controller.schedules.where((s) => s.day == 'Wednesday').length.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: controller.schedules.where((s) => s.day == 'Thursday').length.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: controller.schedules.where((s) => s.day == 'Friday').length.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                            return Text(days[value.toInt()]);
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuroreButton(
                text: 'Refresh Timetable',
                onPressed: () {
                  controller.fetchSchedules('user-id', 'student');
                },
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}