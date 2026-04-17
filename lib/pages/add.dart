import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

import '../../controllers/add_transaction_controller.dart';
import '../../models/transaction.dart';
import '../../widgets/type_toggle.dart';
import '../../widgets/amount_card.dart';
import '../../widgets/date_picker_card.dart';
import '../../widgets/notes_field.dart';
import '../../widgets/save_button.dart';
import '../widgets/category_gird.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _controller  = AddTransactionController();
  final _amountCtrl  = TextEditingController();
  final _noteCtrl    = TextEditingController();
  final _amountFocus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────
// Inside _AddState class
  void _onSave() async {
    // 1. Sync Note from TextField to Controller
    _controller.setNote(_noteCtrl.text);

    // 2. Perform Save
    final success = await _controller.saveTransaction();

    if (success) {
      _showSnack('Transaction saved!', isError: false);
      if (mounted) Navigator.of(context).maybePop();
    } else {
      final error = _controller.validate() ?? 'Unexpected Error';
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.expense : AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Type Toggle ──────────────
                        TypeToggle(
                          selected: _controller.type,
                          onChanged: _controller.setType,
                        ),
                        const SizedBox(height: 24),

                        // ── Amount ───────────────────
                        AmountCard(
                          type:       _controller.type,
                          controller: _amountCtrl,
                          focusNode:  _amountFocus,
                          onChanged:  _controller.setAmount,
                        ),
                        const SizedBox(height: 20),

                        // ── Category ─────────────────
                        const Text('Category', style: AppTextStyles.sectionLabel),
                        const SizedBox(height: 12),
                        CategoryGrid(
                          categories:    _controller.categories,
                          selectedIndex: _controller.selectedCategory,
                          onSelected:    _controller.setCategory,
                        ),
                        const SizedBox(height: 20),

                        // ── Details ───────────────────
                        const Text('Details', style: AppTextStyles.sectionLabel),
                        const SizedBox(height: 12),
                        DatePickerCard(
                          selectedDate:  _controller.date,
                          type:          _controller.type,
                          onDateChanged: _controller.setDate,
                        ),
                        const SizedBox(height: 12),
                        NotesField(controller: _noteCtrl),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ── Save Button ───────────────────
                SaveButton(
                  type:      _controller.type,
                  enabled:   _controller.hasAmount,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: const Text('Add Transaction', style: AppTextStyles.appBarTitle),
    );
  }
}
