import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'detail_card.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 20,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              style: AppTextStyles.noteInput,
              decoration: const InputDecoration(
                hintText: 'Add note (optional)',
                hintStyle: AppTextStyles.noteHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(top: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
