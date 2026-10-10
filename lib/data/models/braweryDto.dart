
import '../../domain/entities/brewery.dart';

class BreweryDto {
  const BreweryDto({
    required this.id,
    required this.name,
    required this.breweryType,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String? breweryType;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  factory BreweryDto.fromJson(Map<String, dynamic> json) {
    return BreweryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      breweryType: json['brewery_type'] as String?,
      address1: json['address_1'] as String?,
      address2: json['address_2'] as String?,
      address3: json['address_3'] as String?,
      city: json['city'] as String?,
      stateProvince: json['state_province'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      websiteUrl: json['website_url'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  Brewery toEntity() {
    return Brewery(
      id: id,
      name: name,
      breweryType: BreweryType.values.asNameMap()[breweryType]
          ?? BreweryType.unknown,
      street: address1,
      street2: [
        address2,
        address3,
      ].whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(', ').nullIfEmpty,
      city: city,
      stateProvince: stateProvince,
      postalCode: postalCode,
      country: country,
      phone: phone,
      websiteUrl: websiteUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

extension _NullableString on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
