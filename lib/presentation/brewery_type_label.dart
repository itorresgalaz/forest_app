
import '../domain/entities/brewery.dart';

/// User-facing text for each brewery type.
extension BreweryTypeLabel on BreweryType {
  String get label => switch (this) {
    BreweryType.unknown => 'Unknown type',
    _ => '${name[0].toUpperCase()}${name.substring(1)}',
  };
}
