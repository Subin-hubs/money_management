import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';
import 'transaction_type.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int iconCode; // We store the int for Hive

  @HiveField(2)
  final int colorValue; // We store the int for Hive

  const CategoryModel({
    required this.label,
    required this.iconCode,
    required this.colorValue,
  });

  // Helper getters so your UI code doesn't have to change
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

class AppCategories {
  AppCategories._();

  // Changed from 'static const' to 'static final'
  // and removed 'const' from the CategoryModel objects
  static final List<CategoryModel> expense = [
    CategoryModel(label: 'Food',          iconCode: Icons.restaurant_rounded.codePoint,       colorValue: AppColors.catFood.value),
    CategoryModel(label: 'Transport',     iconCode: Icons.directions_bus_rounded.codePoint,   colorValue: AppColors.catTransport.value),
    CategoryModel(label: 'Tuition',       iconCode: Icons.school_rounded.codePoint,           colorValue: AppColors.catTuition.value),
    CategoryModel(label: 'Shopping',      iconCode: Icons.shopping_bag_rounded.codePoint,     colorValue: AppColors.catShopping.value),
    CategoryModel(label: 'Entertainment', iconCode: Icons.movie_rounded.codePoint,            colorValue: AppColors.catEntertainment.value),
    CategoryModel(label: 'Others',        iconCode: Icons.more_horiz_rounded.codePoint,       colorValue: AppColors.catOthers.value),
  ];

  static final List<CategoryModel> income = [
    CategoryModel(label: 'Salary',        iconCode: Icons.account_balance_wallet_rounded.codePoint, colorValue: AppColors.catSalary.value),
    CategoryModel(label: 'Freelance',     iconCode: Icons.laptop_mac_rounded.codePoint,            colorValue: AppColors.catFreelance.value),
    CategoryModel(label: 'Investment',    iconCode: Icons.trending_up_rounded.codePoint,           colorValue: AppColors.catInvestment.value),
    CategoryModel(label: 'Gift',          iconCode: Icons.card_giftcard_rounded.codePoint,         colorValue: AppColors.catGift.value),
    CategoryModel(label: 'Others',        iconCode: Icons.more_horiz_rounded.codePoint,            colorValue: AppColors.catOthers.value),
  ];

  static List<CategoryModel> forType(TransactionType type) =>
      type == TransactionType.expense ? expense : income;
}