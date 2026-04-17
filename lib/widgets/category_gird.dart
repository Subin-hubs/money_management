import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import 'category_tile.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final int                 selectedIndex;
  final ValueChanged<int>   onSelected;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: categories.length,
      itemBuilder: (_, index) => CategoryTile(
        category: categories[index],
        isSelected: selectedIndex == index,
        onTap: () => onSelected(index),
      ),
    );
  }
}
