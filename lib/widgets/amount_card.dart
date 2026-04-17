import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_text_styles.dart';
import '../../models/transaction_type.dart';

class AmountCard extends StatelessWidget {
  final TransactionType         type;
  final TextEditingController   controller;
  final FocusNode               focusNode;
  final ValueChanged<String>    onChanged;

  const AmountCard({
    super.key,
    required this.type,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = type.accentColor;
    final light  = type.lightColor;

    return GestureDetector(
      onTap: focusNode.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              type.amountLabel,
              style: AppTextStyles.amountLabel.copyWith(
                color: accent.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '₹',
                    style: AppTextStyles.currencySymbol.copyWith(color: accent),
                  ),
                ),
                const SizedBox(width: 6),
                IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.amountInput,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTextStyles.amountHint,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
