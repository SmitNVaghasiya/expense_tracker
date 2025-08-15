import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/database_service.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static final List<Category> _defaultCategories = [
    // Default Expense Categories
    Category(
      id: 'expense_food',
      name: 'Food & Dining',
      type: 'expense',
      icon: 'restaurant',
      color: '#FF0000',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_transport',
      name: 'Transportation',
      type: 'expense',
      icon: 'directions_car',
      color: '#2196F3',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_shopping',
      name: 'Shopping',
      type: 'expense',
      icon: 'shopping_bag',
      color: '#9C27B0',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_entertainment',
      name: 'Entertainment',
      type: 'expense',
      icon: 'movie',
      color: '#E91E63',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_health',
      name: 'Healthcare',
      type: 'expense',
      icon: 'medical_services',
      color: '#FF9800',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_home',
      name: 'Home & Utilities',
      type: 'expense',
      icon: 'home',
      color: '#4CAF50',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_education',
      name: 'Education',
      type: 'expense',
      icon: 'school',
      color: '#3F51B5',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_business',
      name: 'Business',
      type: 'expense',
      icon: 'business',
      color: '#607D8B',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'expense_other',
      name: 'Other',
      type: 'expense',
      icon: 'category',
      color: '#9E9E9E',
      createdAt: DateTime.now(),
      isDefault: true,
    ),

    // Default Income Categories
    Category(
      id: 'income_salary',
      name: 'Salary',
      type: 'income',
      icon: 'account_balance_wallet',
      color: '#4CAF50',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'income_freelance',
      name: 'Freelance',
      type: 'income',
      icon: 'work',
      color: '#2196F3',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'income_investment',
      name: 'Investment',
      type: 'income',
      icon: 'trending_up',
      color: '#4CAF50',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'income_gift',
      name: 'Gift',
      type: 'income',
      icon: 'card_giftcard',
      color: '#E91E63',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
    Category(
      id: 'income_other',
      name: 'Other Income',
      type: 'income',
      icon: 'attach_money',
      color: '#FF9800',
      createdAt: DateTime.now(),
      isDefault: true,
    ),

    // Default Transfer Categories
    Category(
      id: 'transfer_general',
      name: 'Transfer',
      type: 'transfer',
      icon: 'swap_horiz',
      color: '#2196F3',
      createdAt: DateTime.now(),
      isDefault: true,
    ),
  ];

  // Get all categories
  static Future<List<Category>> getAllCategories() async {
    try {
      final categories = await DatabaseService.getCategories();
      if (categories.isEmpty) {
        // Initialize with default categories if none exist
        await _initializeDefaultCategories();
        return await DatabaseService.getCategories();
      }
      return categories;
    } catch (e) {
      // Error getting categories: $e
      return [];
    }
  }

  // Get categories by type
  static Future<List<Category>> getCategoriesByType(String type) async {
    try {
      return await DatabaseService.getCategoriesByType(type);
    } catch (e) {
      // Error getting categories by type: $e
      return [];
    }
  }

  // Add new category
  static Future<bool> addCategory(Category category) async {
    try {
      await DatabaseService.addCategory(category);
      return true;
    } catch (e) {
      // Error adding category: $e
      return false;
    }
  }

  // Update category
  static Future<bool> updateCategory(Category category) async {
    try {
      await DatabaseService.updateCategory(category);
      return true;
    } catch (e) {
      // Error updating category: $e
      return false;
    }
  }

  // Delete category
  static Future<bool> deleteCategory(String id) async {
    try {
      await DatabaseService.deleteCategory(id);
      return true;
    } catch (e) {
      // Error updating category: $e
      return false;
    }
  }

  // Initialize default categories
  static Future<void> _initializeDefaultCategories() async {
    try {
      for (final category in _defaultCategories) {
        await DatabaseService.addCategory(category);
      }
      print('Default categories initialized successfully');
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  // Get icon data from icon string
  static IconData getIconData(String iconString) {
    switch (iconString) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'category':
        return Icons.category;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'work':
        return Icons.work;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'fastfood':
        return Icons.fastfood;
      case 'coffee':
        return Icons.coffee;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'cake':
        return Icons.cake;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'subway':
        return Icons.subway;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'motorcycle':
        return Icons.motorcycle;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'checkroom':
        return Icons.checkroom;
      case 'diamond':
        return Icons.diamond;
      case 'face':
        return Icons.face;
      case 'book':
        return Icons.book;
      case 'devices':
        return Icons.devices;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'games':
        return Icons.games;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'terrain':
        return Icons.terrain;
      case 'flight':
        return Icons.flight;
      case 'beach_access':
        return Icons.beach_access;
      case 'medication':
        return Icons.medication;
      case 'visibility':
        return Icons.visibility;
      case 'psychology':
        return Icons.psychology;
      case 'build':
        return Icons.build;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'chair':
        return Icons.chair;
      case 'image':
        return Icons.image;
      case 'content_cut':
        return Icons.content_cut;
      case 'brush':
        return Icons.brush;
      case 'people':
        return Icons.people;
      case 'event':
        return Icons.event;
      case 'security':
        return Icons.security;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'payment':
        return Icons.payment;
      case 'favorite':
        return Icons.favorite;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'computer':
        return Icons.computer;
      case 'phone_android':
        return Icons.phone_android;
      case 'play_circle':
        return Icons.play_circle;
      case 'cloud':
        return Icons.cloud;
      case 'pets':
        return Icons.pets;
      case 'emergency':
        return Icons.emergency;
      case 'gavel':
        return Icons.gavel;
      case 'handyman':
        return Icons.handyman;
      case 'inventory':
        return Icons.inventory;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'watch':
        return Icons.watch;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'home_work':
        return Icons.home_work;
      case 'account_balance':
        return Icons.account_balance;
      case 'water_drop':
        return Icons.water_drop;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'savings':
        return Icons.savings;
      case 'credit_card':
        return Icons.credit_card;
      case 'money':
        return Icons.money;
      case 'circle':
        return Icons.circle;
      default:
        return Icons.category;
    }
  }

  // Get color from hex string
  static Color getColorFromHex(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
