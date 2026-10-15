
import 'package:forestchallenger/domain/entities/brewery.dart';

abstract interface class BreweryRepository {
  Future<List<Brewery>>  getBreweries({
    required int page,
    required int perPage,
  });

  Future<List<Brewery>> searchBreweries({ //Busqueda
    required String query,
    required int page,
    required int perPage,
  });

  Future<Brewery> getBrewery(String id);


}