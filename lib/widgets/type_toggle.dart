import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/transaction_type.dart';

class TypeToggle extends StatefulWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  const TypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<TypeToggle> createState() => _TypeToggleState();
}

class _TypeToggleState extends State<TypeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _slide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.selected == TransactionType.income) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(TypeToggle old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      widget.selected == TransactionType.income
          ? _ctrl.forward()
          : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.selected.accentColor;
    return LayoutBuilder(
      builder: (_, constraints) {
        final pillW = (constraints.maxWidth - 8) / 2;
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: Stack(
            children: [
              // Animated pill
              AnimatedBuilder(
                animation: _slide,
                builder: (_, __) => Positioned(
                  left: 4 + _slide.value * pillW,
                  top: 4,
                  bottom: 4,
                  width: pillW,
                  child: Container(
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.accentShadow(accent),
                    ),
                  ),
                ),
              ),
              // Labels
              Row(
                children: TransactionType.values
                    .map((t) => Expanded(child: _ToggleOption(
                  type: t,
                  isSelected: widget.selected == t,
                  onTap: () => widget.onChanged(t),
                )))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final TransactionType type;
  final bool            isSelected;
  final VoidCallback    onTap;

  const _ToggleOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: AppTextStyles.toggleLabel.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        child: Center(child: Text(type.label)),
      ),
    );
  }
}
