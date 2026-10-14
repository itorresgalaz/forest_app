import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/domain/entities/brewery.dart';
import 'package:forestchallenger/domain/repositories/brewery_repository.dart';
import 'package:forestchallenger/presentation/bloc/brewery_list_bloc.dart';

class MockBreweryRepository extends Mock implements BreweryRepository {
  //
}

class MockBrewery extends Mock implements Brewery {}

void main() {
  late MockBreweryRepository repository;
  late List<Brewery> firstListBrewery;
  late List<Brewery> secondListBrewery;

  setUp(() {
    repository = MockBreweryRepository();
    firstListBrewery = _makeBreweries(20);
    secondListBrewery = _makeBreweries(20);
  });

  /*  blocTest<BreweryListBloc, BreweryListState>(
    'descripción del comportamiento',

    build: () {
      // Crear el BLoC.
    },

    act: (bloc) {
      // Enviar eventos.
    },

    expect: () => [
      // Estados esperados.
    ],
    verify: (_) {
        verify(
          () => repository.getBreweries(
            page: 1,
            perPage: 20,
          ),
        ).called(1);
      }
  );*/

  group('BreweryListBloc', () {
    //agrupa pruebas
    //Bloc Test
    blocTest<BreweryListBloc, BreweryListState>(
      'Descripción del comportamiento Loading (Cargando datos del repositorio) y Loaded (Lista con Breweries)',

      build: () {
        // Crear el BLoC.
        when(
          () => repository.getBreweries(
            page: 1,
            perPage: 20,
          ), // que devuelve el repositorio
        ).thenAnswer((_) async => firstListBrewery);
        return BreweryListBloc(repository); //Se crea el Bloc con el repositorio
      },

      act: (bloc) {
        // Enviar eventos.
        bloc.add(const BreweryListRequested());
      },

      expect: () => [
        // Estados esperados.
        isA<BreweryListLoading>(),
        isA<BreweryListLoaded>()
            .having(
              (state) => state.breweries.length,
              'Cantidad de cervecerias',
              20,
            )
            .having((state) => state.nextPage, 'siguiente pagina', 2)
            .having((state) => state.hasMore, 'existen mas paginas', true),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
      },
    );
    //Failure
    blocTest<BreweryListBloc, BreweryListState>(
      ' emite Loading y Empty ',

      build: () {
        // Crear el BLoC.
        when(
          () => repository.getBreweries(page: 1, perPage: 20),
        ).thenAnswer((_) async => <Brewery>[]);
        return BreweryListBloc(repository);
      },

      act: (bloc) {
        // Enviar eventos.
        bloc.add(const BreweryListRequested());
      },

      expect: () => [
        // Estados esperados.
        isA<BreweryListLoading>(),
        isA<BreweryListEmpty>(),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
      },
    );

    //emite Loading y Failura
    blocTest<BreweryListBloc, BreweryListState>(
        'emite Loading y Failure ante NetworkException',

        build: () {
          // Crear el BLoC.
        },

        act: (bloc) {
          // Enviar eventos.
        },

        expect: () => [
          // Estados esperados.
        ],
        verify: (_) {
          verify(
                () => repository.getBreweries(
              page: 1,
              perPage: 20,
            ),
          ).called(1);
        }
    );


  });
}

List<Brewery> _makeBreweries(int count) {
  return List.generate(count, (_) => MockBrewery());
}
