
import '../../domain/entities/brewery.dart';

class BreweryDto {
  const BreweryDto({
    required this.id,
    required this.name,
    required this.breweryType,
    this.address1,
    this.city,
    this.phone,
    this.websiteUrl,
  });

  final String id;
  final String name;
  final String? breweryType;
  final String? address1;
  final String? city;
  final String? phone;
  final String? websiteUrl;


  factory BreweryDto.fromJson(Map<String, dynamic> json) {
    return BreweryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      breweryType: json['brewery_type'] as String?,
      address1: json['address_1'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      websiteUrl: json['website_url'] as String?,
    );
  }
  Map<String, dynamic>toJson(){
    return {
      'id':id,
      'name': name,
      'brewery_type': breweryType,
      'address1' : address1,
      'city': city,
      'phone' : phone,
      'websiteUrl': websiteUrl
    };
  }

  Brewery toEntity() {
    return Brewery(
      id: id,
      name: name,
      breweryType: BreweryType.values.asNameMap()[breweryType]
          ?? BreweryType.unknown,
      address1: address1,
      city: city,
      phone: phone,
      websiteUrl: websiteUrl,

    );
  }

}
