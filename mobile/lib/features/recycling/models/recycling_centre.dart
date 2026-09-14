class RecyclingCentre {
  final String id;
  final String? officerEmail;
  final int? officerId;
  final String name;
  final String address;
  final String city;
  final double distanceKm;
  final String contactNumber;
  final String email;
  final String operatingHours;
  final bool isOpen;
  final List<String> acceptedMaterials;
  final List<String> unsupportedMaterials;
  final String notes;

  const RecyclingCentre({
    required this.id,
    this.officerEmail,
    this.officerId,
    required this.name,
    required this.address,
    required this.city,
    required this.distanceKm,
    required this.contactNumber,
    required this.email,
    required this.operatingHours,
    required this.isOpen,
    required this.acceptedMaterials,
    required this.unsupportedMaterials,
    required this.notes,
  });

  RecyclingCentre copyWith({
    String? id,
    String? officerEmail,
    int? officerId,
    String? name,
    String? address,
    String? city,
    double? distanceKm,
    String? contactNumber,
    String? email,
    String? operatingHours,
    bool? isOpen,
    List<String>? acceptedMaterials,
    List<String>? unsupportedMaterials,
    String? notes,
  }) {
    return RecyclingCentre(
      id: id ?? this.id,
      officerEmail: officerEmail ?? this.officerEmail,
      officerId: officerId ?? this.officerId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      distanceKm: distanceKm ?? this.distanceKm,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      operatingHours: operatingHours ?? this.operatingHours,
      isOpen: isOpen ?? this.isOpen,
      acceptedMaterials: acceptedMaterials ?? this.acceptedMaterials,
      unsupportedMaterials: unsupportedMaterials ?? this.unsupportedMaterials,
      notes: notes ?? this.notes,
    );
  }

  factory RecyclingCentre.fromJson(Map<String, dynamic> json) {
    return RecyclingCentre(
      id: json['id']?.toString() ?? '',
      officerEmail: json['officerEmail'] as String?,
      officerId: json['officerId'] is int ? json['officerId'] as int : null,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      distanceKm: (json['distanceKm'] is num) ? (json['distanceKm'] as num).toDouble() : 1.2,
      contactNumber: json['contactNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      operatingHours: json['operatingHours'] as String? ?? 'Mon - Sat: 8:00 AM - 5:30 PM',
      isOpen: json['isOpen'] as bool? ?? true,
      acceptedMaterials: (json['acceptedMaterials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      unsupportedMaterials: (json['unsupportedMaterials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'contactNumber': contactNumber,
      'email': email,
      'operatingHours': operatingHours,
      'isOpen': isOpen,
      'acceptedMaterials': acceptedMaterials,
      'unsupportedMaterials': unsupportedMaterials,
      'notes': notes,
    };
  }
}

