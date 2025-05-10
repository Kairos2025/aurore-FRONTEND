import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';
import 'package:aurore_school/core/providers/timetable_controller.dart';
import 'package:aurore_school/enums/resolution_type.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/widgets/conflict_resolution_dialog.dart';
import 'package:aurore_school/aurore_responsive_layout.dart';
import 'package:aurore_school/widgets/aurore_app_bar.dart';
import 'package:aurore_school/widgets/aurore_button.dart';
import 'package:aurore_school/widgets/aurore_header.dart';
import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';

class ManualScheduleScreen extends StatefulWidget {
  const ManualScheduleScreen({super.key});

  @override
  State<ManualScheduleScreen> createState() => _ManualScheduleScreenState();
}

class _ManualScheduleScreenState extends State<ManualScheduleScreen> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TimetableController>();
      controller.fetchConflicts();
      controller.loadOfflineConflicts();
    });
  }

  List<ScheduleConflict> _filterConflicts(List<ScheduleConflict> conflicts, String filter) {
    if (filter == 'All') return conflicts;
    return conflicts.where((conflict) => conflict.reason.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  void _showResolutionConfirmation(BuildContext context, ScheduleConflict conflict, ResolutionType resolution) async {
    await Vibration.vibrate(duration: 200);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conflict Resolved', style: AppTextStyles.bodyBold),
        content: Text(
          'Conflict for schedule ${conflict.scheduleId} resolved with: ${resolution.toString().split('.').last}',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuroreAppBar(
        title: 'Resolve Conflicts',
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.iconPrimary,
            ),
            onPressed: () => context.read<TimetableController>().fetchConflicts(),
          ),
        ],
      ),
      body: AuroreResponsiveLayout(
        mobile: _buildMobileView(context),
        tablet: _buildTabletView(context),
        desktop: _buildDesktopView(context),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return _buildContent(context, crossAxisCount: 1);
  }

  Widget _buildTabletView(BuildContext context) {
    return _buildContent(context, crossAxisCount: 2);
  }

  Widget _buildDesktopView(BuildContext context) {
    return _buildContent(context, crossAxisCount: 3);
  }

  Widget _buildContent(BuildContext context, {required int crossAxisCount}) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16.0),
            child: const AuroreHeader(title: 'Timetable Conflict Resolution'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              isExpanded: true,
              items: ['All', 'Time slot', 'Room', 'Teacher']
                  .map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter, style: AppTextStyles.body),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                Vibration.vibrate(duration: 100);
              },
              underline: Container(
                height: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer<TimetableController>(
            builder: (context, controller, _) {
              if (controller.conflicts.isEmpty) return Container();
              final conflictCounts = {
                'Time': controller.conflicts.where((c) => c.reason.contains('Time')).length,
                'Room': controller.conflicts.where((c) => c.reason.contains('Room')).length,
                'Teacher': controller.conflicts.where((c) => c.reason.contains('Teacher')).length,
              };
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: const Duration(milliseconds: 500),
                  openBuilder: (context, _) => const SizedBox(),
                  closedBuilder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conflict Overview', style: AppTextStyles.header),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        height: 150,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    const types = ['Time', 'Room', 'Teacher'];
                                    return Text(
                                      types[value.toInt()],
                                      style: AppTextStyles.caption,
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: conflictCounts.entries
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.value.toDouble(),
                                        color: AppColors.primary,
                                        width: 12,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer<TimetableController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (controller.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.error!,
                    style: AppTextStyles.error,
                  ),
                );
              }
              final filteredConflicts = _filterConflicts(controller.conflicts, selectedFilter);
              if (filteredConflicts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    selectedFilter == 'All' ? 'No conflicts found' : 'No $selectedFilter conflicts',
                    style: AppTextStyles.body,
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredConflicts.length,
                itemBuilder: (context, index) {
                  final conflict = filteredConflicts[index];
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: const Duration(milliseconds: 300),
                    openBuilder: (context, _) => const SizedBox(),
                    closedBuilder: (context, _) => Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          Vibration.vibrate(duration: 100);
                          showDialog(
                            context: context,
                            builder: (context) => ConflictResolutionDialog(
                              conflict: conflict,
                              onResolve: (resolution) async {
                                await controller.resolveConflict(conflict, resolution);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  _showResolutionConfirmation(context, conflict, resolution);
                                }
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Schedule ${conflict.scheduleId}',
                                style: AppTextStyles.bodyBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                conflict.reason,
                                style: AppTextStyles.body,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Solutions: ${conflict.proposedSolutions.join(', ')}',
                                style: AppTextStyles.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: AuroreButton(
              text: 'Back to Timetable',
              onPressed: () {
                Vibration.vibrate(duration: 100);
                Navigator.pushNamed(context, '/timetable');
              },
              icon: Icons.schedule,
              iconColor: AppColors.iconPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
