import 'package:equatable/equatable.dart';

class Brewery extends Equatable {
  const Brewery({
    required this.id,
    required this.name,
    required this.breweryType,
    this.street,
    this.street2,
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
  final BreweryType breweryType;
  final String? street;
  final String? street2;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;

  /// Nullable on purpose: the API does not guarantee coordinates.
  final double? latitude;
  final double? longitude;

  /// Address built only from the parts that exist, so the UI never shows
  /// "null" or dangling separators. `null` when there is nothing to show.
  String? get formattedAddress {
    final parts = [street, street2, city, stateProvince, postalCode, country]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    breweryType,
    street,
    street2,
    city,
    stateProvince,
    postalCode,
    country,
    phone,
    websiteUrl,
    latitude,
    longitude,
  ];
}

enum BreweryType {
  micro,
  nano,
  regional,
  brewpub,
  large,
  planning,
  bar,
  contract,
  proprietor,
  closed,
  unknown,
}
