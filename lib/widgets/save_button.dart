import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/transaction_type.dart';

class SaveButton extends StatelessWidget {
  final TransactionType type;
  final bool            enabled;
  final VoidCallback    onPressed;

  const SaveButton({
    super.key,
    required this.type,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = type.accentColor;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: enabled ? accent : accent.withOpacity(0.4),
          boxShadow: enabled ? AppColors.accentShadow(accent) : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: const Center(
              child: Text('Save Transaction', style: AppTextStyles.saveButton),
            ),
          ),
        ),
      ),
    );
  }
}
