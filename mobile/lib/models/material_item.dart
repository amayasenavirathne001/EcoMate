class MaterialItem {
  final int id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final String binColor;
  final bool isRecyclable;
  final String preparationTips;
  final bool isActive;

  const MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.imageUrl = '',
    this.binColor = '#2E7D32',
    this.isRecyclable = true,
    this.preparationTips = '',
    this.isActive = true,
  });

  MaterialItem copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    String? binColor,
    bool? isRecyclable,
    String? preparationTips,
    bool? isActive,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      binColor: binColor ?? this.binColor,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      preparationTips: preparationTips ?? this.preparationTips,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      binColor: json['binColor'] as String? ?? '#2E7D32',
      isRecyclable: json['isRecyclable'] as bool? ?? true,
      preparationTips: json['preparationTips'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? (json['active'] == 1 || json['active'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'binColor': binColor,
      'isRecyclable': isRecyclable,
      'preparationTips': preparationTips,
      'isActive': isActive,
    };
  }
}