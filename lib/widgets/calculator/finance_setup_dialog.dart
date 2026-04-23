import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/calculater_app_theme.dart';
import '../../models/user_finance_model.dart';
import '../../providers/finance_provider.dart';


class FinanceSetupDialog extends ConsumerStatefulWidget {
  final bool isEditing;

  const FinanceSetupDialog({super.key, this.isEditing = false});

  @override
  ConsumerState<FinanceSetupDialog> createState() => _FinanceSetupDialogState();
}

class _FinanceSetupDialogState extends ConsumerState<FinanceSetupDialog> {
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  IncomeType _selectedIncomeType = IncomeType.monthly;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final profile = ref.read(financeProfileProvider);
      if (profile != null) {
        _incomeController.text = profile.income.toStringAsFixed(0);
        _savingsController.text = profile.savings.toStringAsFixed(0);
        _selectedIncomeType = profile.incomeType;
      }
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final income = double.tryParse(_incomeController.text);
    final savings = double.tryParse(_savingsController.text);

    if (income == null || income <= 0) {
      _showError('Please enter a valid income.');
      return;
    }
    if (savings == null || savings < 0) {
      _showError('Please enter a valid savings amount.');
      return;
    }

    setState(() => _isSaving = true);
    await ref.read(financeProfileProvider.notifier).saveProfile(
      income: income,
      incomeType: _selectedIncomeType,
      savings: savings,
    );
    setState(() => _isSaving = false);

    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEditing ? 'Update Profile' : 'Your Finances',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.isEditing
                            ? 'Update your financial info'
                            : 'Set up once, decide smarter',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Income Row
            Text(
              'Income',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _incomeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _IncomeTypeDropdown(
                    value: _selectedIncomeType,
                    onChanged: (v) => setState(() => _selectedIncomeType = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Savings
            Text(
              'Current Savings',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _savingsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  widget.isEditing ? 'Update' : 'Get Started',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeTypeDropdown extends StatelessWidget {
  final IncomeType value;
  final ValueChanged<IncomeType?> onChanged;

  const _IncomeTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IncomeType>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 20),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          onChanged: onChanged,
          items: const [
            DropdownMenuItem(value: IncomeType.daily, child: Text('Daily')),
            DropdownMenuItem(value: IncomeType.weekly, child: Text('Weekly')),
            DropdownMenuItem(value: IncomeType.monthly, child: Text('Monthly')),
          ],
        ),
      ),
    );
  }
}