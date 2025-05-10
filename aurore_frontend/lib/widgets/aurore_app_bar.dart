import 'package:flutter/material.dart';
import 'package:aurore_school/core/constants/app_colors.dart';
import 'package:aurore_school/core/constants/app_text_styles.dart';

class AuroreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AuroreAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/aurore_logo.png',
          width: 32,
          height: 32,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
      actions: actions,
      backgroundColor: AppColors.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
