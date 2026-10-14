import 'package:equatable/equatable.dart';

class Brewery extends Equatable {
  final String id;
  final String name;
  final BreweryType breweryType;
  final String? address1;
  final String? city;
  final String? phone;
  final String? websiteUrl;

  const Brewery({
    required this.id,
    required this.name,
    required this.breweryType,
    this.address1,
    this.city,
    this.phone,
    this.websiteUrl,
  });

  @override
  List<Object?> get props => [id, name, breweryType,address1,city, phone, websiteUrl];
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
