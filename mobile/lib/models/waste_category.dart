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
}

