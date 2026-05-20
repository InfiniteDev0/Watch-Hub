class AddressModel {
  final String id;
  final String userId;
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fullName: json['full_name'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
        postalCode: json['postal_code'] as String,
        country: json['country'] as String,
        isDefault: json['is_default'] as bool? ?? false,
      );

  // Used for POST (create) — server sets id and user_id
  Map<String, dynamic> toJsonForCreate() => {
        'full_name': fullName,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      };

  // Used for PATCH (update) — omit read-only fields
  Map<String, dynamic> toJsonForUpdate() => toJsonForCreate();

  AddressModel copyWith({
    String? fullName,
    String? street,
    String? city,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) =>
      AddressModel(
        id: id,
        userId: userId,
        fullName: fullName ?? this.fullName,
        street: street ?? this.street,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        isDefault: isDefault ?? this.isDefault,
      );

  String get displayLine1 => fullName;
  String get displayLine2 => '$street, $city';
  String get displayLine3 => '$postalCode, $country';
}
