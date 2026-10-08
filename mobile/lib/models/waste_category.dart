import 'package:flutter/material.dart';

class WasteCategory {
  final String id;
  final String name;
  final String binColorName;
  final Color binColor;
  final IconData icon;
  final String description;
  final bool isRecyclable;
  final List<String> commonItems;
  final List<String> preparationSteps;
  final List<String> dos;
  final List<String> donts;

  const WasteCategory({
    required this.id,
    required this.name,
    required this.binColorName,
    required this.binColor,
    required this.icon,
    required this.description,
    required this.isRecyclable,
    required this.commonItems,
    required this.preparationSteps,
    required this.dos,
    required this.donts,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    // Parse color
    Color parseColor(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) return Colors.grey;
      try {
        return Color(int.parse(colorStr));
      } catch (e) {
        return Colors.grey;
      }
    }

    // Parse Icon
    IconData parseIcon(String? iconStr) {
      switch (iconStr) {
        case 'local_drink_rounded': return Icons.local_drink_rounded;
        case 'article_rounded': return Icons.article_rounded;
        case 'wine_bar_rounded': return Icons.wine_bar_rounded;
        case 'takeout_dining_rounded': return Icons.takeout_dining_rounded;
        case 'eco_rounded': return Icons.eco_rounded;
        case 'devices_other_rounded': return Icons.devices_other_rounded;
        case 'warning_rounded': return Icons.warning_rounded;
        default: return Icons.category_rounded;
      }
    }

    return WasteCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      binColorName: json['binColorName'] as String? ?? 'Bin',
      binColor: parseColor(json['binColor'] as String?),
      icon: parseIcon(json['icon'] as String?),
      description: json['description'] as String? ?? '',
      isRecyclable: json['isRecyclable'] as bool? ?? json['recyclable'] as bool? ?? json['is_recyclable'] as bool? ?? false,
      commonItems: (json['commonItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      preparationSteps: (json['preparationSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      donts: (json['donts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

