import 'package:flutter/material.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';

class AuroreHeader extends StatelessWidget {
  final String title;

  const AuroreHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: AppTextStyles.header,
      ),
    );
  }
}
