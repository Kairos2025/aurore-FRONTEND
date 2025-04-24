import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:aurore_school/models/schedule_conflict.dart';
import 'package:aurore_school/utils/secure_storage.dart';
import 'package:aurore_school/utils/app_text_styles.dart';
import 'package:vibration/vibration.dart';

class NotionCard extends StatefulWidget {
  final String title;
  final String description;
  final DateTime? timestamp;
  final String? category;
  final int? priority;
  final bool isNew;
  final bool hasConflict;
  final VoidCallback? onTap;
  final ScheduleConflict? conflict;

  const NotionCard({
    super.key,
    required this.title,
    required this.description,
    this.timestamp,
    this.category,
    this.priority,
    this.isNew = false,
    this.hasConflict = false,
    this.onTap,
    this.conflict,
  });

  @override
  State<NotionCard> createState() => _NotionCardState();
}

class _NotionCardState extends State<NotionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    if (widget.isNew) {
      Vibration.vibrate(duration: 100);
      _logCardInteraction('new_card_displayed');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logCardInteraction(String eventName) async {
    await _secureStorage.logEvent(eventName, {
      'title': widget.title,
      'timestamp': widget.timestamp?.toIso8601String() ?? 'N/A',
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 2,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedColor: Colors.white,
      openColor: Colors.white,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
              _logCardInteraction('card_tapped');
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.hasConflict) ...[
                    const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: AppTextStyles.bodyBold,
                            ),
                            if (widget.isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        if (widget.timestamp != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_jm().format(widget.timestamp!),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (widget.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${widget.category}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (widget.priority != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Priority: ${widget.priority}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (widget.conflict != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Conflict: ${widget.conflict!.reason}',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Text(widget.description),
          ),
        );
      },
    );
  }
}