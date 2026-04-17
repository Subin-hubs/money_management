import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A generic rounded white card used as a wrapper for
/// tappable detail rows (date, notes, etc.)
class DetailCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const DetailCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        child: child,
      ),
    );
  }
}
