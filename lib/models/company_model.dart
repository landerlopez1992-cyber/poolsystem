class CompanyModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String subscriptionType; // 'monthly' o 'lifetime'
  final double subscriptionPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int? totalWorkers;
  final int? totalClients;

  CompanyModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.subscriptionType = 'monthly',
    this.subscriptionPrice = 250.0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.totalWorkers,
    this.totalClients,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logo_url'] as String?,
      subscriptionType: json['subscription_type'] as String? ?? 'monthly',
      subscriptionPrice: (json['subscription_price'] as num?)?.toDouble() ?? 250.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      totalWorkers: json['total_workers'] as int?,
      totalClients: json['total_clients'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'logo_url': logoUrl,
      'subscription_type': subscriptionType,
      'subscription_price': subscriptionPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // Helpers para suscripción
  String get subscriptionTypeLabel {
    switch (subscriptionType) {
      case 'monthly':
        return 'Mensual';
      case 'lifetime':
        return 'Por Vida';
      default:
        return 'Mensual';
    }
  }

  String get subscriptionPriceFormatted {
    return '\$${subscriptionPrice.toStringAsFixed(0)}';
  }
}

