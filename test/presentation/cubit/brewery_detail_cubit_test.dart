
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/domain/entities/brewery.dart';
import 'package:forestchallenger/domain/repositories/brewery_repository.dart';
import 'package:forestchallenger/presentation/cubit/brewery_detail_cubit.dart';

class MockBreweryRepository extends Mock
    implements BreweryRepository {}

class MockBrewery extends Mock implements Brewery {}

void main() {
  late MockBreweryRepository repository;
  late Brewery brewery;

  const breweryId = 'brewery-123';

  setUp(() {
    repository = MockBreweryRepository();
    brewery = MockBrewery();
  });

  group('BreweryDetailCubit', () {
    blocTest<BreweryDetailCubit, BreweryDetailState>(
      'emite Loading y Loaded cuando obtiene una cervecería',
      build: () {
        when(
              () => repository.getBrewery(breweryId),
        ).thenAnswer((_) async => brewery);

        return BreweryDetailCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadBrewery(breweryId);
      },
      expect: () => [
        isA<BreweryDetailLoading>(),
        isA<BreweryDetailLoaded>().having(
              (state) => state.brewery,
          'cervecería obtenida',
          same(brewery),
        ),
      ],
      verify: (_) {
        verify(
              () => repository.getBrewery(breweryId),
        ).called(1);
      },
    );

    blocTest<BreweryDetailCubit, BreweryDetailState>(
      'emite Loading y Failure cuando falla la conexión',
      build: () {
        when(
              () => repository.getBrewery(breweryId),
        ).thenThrow(const NetworkException());

        return BreweryDetailCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadBrewery(breweryId);
      },
      expect: () => [
        isA<BreweryDetailLoading>(),
        isA<BreweryDetailFailure>().having(
              (state) => state.message,
          'mensaje de error',
          'Could not reach the server.',
        ),
      ],
    );
  });
}
