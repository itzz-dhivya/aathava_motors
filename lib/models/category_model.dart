import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String nameTamil;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameTamil,
    required this.icon,
    required this.color,
  });

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'engine',
      name: 'Engine Parts',
      nameTamil: 'என்ஜின் பாகங்கள்',
      icon: Icons.settings,
      color: Color(0xFF3B82F6),
    ),
    CategoryModel(
      id: 'brakes',
      name: 'Brakes & Drums',
      nameTamil: 'பிரேக் பாகங்கள்',
      icon: Icons.disc_full,
      color: Color(0xFFEF4444),
    ),
    CategoryModel(
      id: 'electrical',
      name: 'Electrical & Battery',
      nameTamil: 'மின்சாரம் மற்றும் பேட்டரி',
      icon: Icons.bolt,
      color: Color(0xFFF59E0B),
    ),
    CategoryModel(
      id: 'suspension',
      name: 'Suspension & Steering',
      nameTamil: 'சஸ்பென்ஷன் & ஸ்டீயரிங்',
      icon: Icons.tune,
      color: Color(0xFF10B981),
    ),
    CategoryModel(
      id: 'transmission',
      name: 'Transmission & Clutch',
      nameTamil: 'கிளட்ச் & கியர் பாகங்கள்',
      icon: Icons.all_inclusive,
      color: Color(0xFF8B5CF6),
    ),
    CategoryModel(
      id: 'lubricants',
      name: 'Oils & Lubricants',
      nameTamil: 'ஆயில் & லூப்ரிகண்ட்ஸ்',
      icon: Icons.water_drop,
      color: Color(0xFF06B6D4),
    ),
    CategoryModel(
      id: 'filters',
      name: 'Air & Oil Filters',
      nameTamil: 'ஏர் & ஆயில் ஃபில்டர்கள்',
      icon: Icons.filter_alt,
      color: Color(0xFFEC4899),
    ),
    CategoryModel(
      id: 'body',
      name: 'Body & Frame',
      nameTamil: 'பாடி & சேஸிஸ்',
      icon: Icons.directions_car,
      color: Color(0xFF6366F1),
    ),
    CategoryModel(
      id: 'tyres',
      name: 'Tyres & Wheels',
      nameTamil: 'டயர் & வீல் பாகங்கள்',
      icon: Icons.adjust,
      color: Color(0xFF14B8A6),
    ),
    CategoryModel(
      id: 'accessories',
      name: 'Horns & Accessories',
      nameTamil: 'ஹார்ன் & பாகங்கள்',
      icon: Icons.volume_up,
      color: Color(0xFF84CC16),
    ),
  ];
}
