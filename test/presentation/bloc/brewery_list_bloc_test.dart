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
      'emite Loading y Failure ante ServerException',

      build: () {
        // Crear el BLoC.
        when(
          () => repository.getBreweries(page: 1, perPage: 20),
        ).thenThrow(const ServerException());
        return BreweryListBloc(repository);
      },

      act: (bloc) {
        // Enviar eventos.
        bloc.add(const BreweryListRequested());
      },

      expect: () => [
        // Estados esperados.
        isA<BreweryListLoading>(),
        isA<BreweryListFailure>().having(
          (error) => error.message,
          'mensaje',
          'Ocurrió un problema con el servidor.',
        ),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
      },
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'Paginacion: Acumula 40 cervecerias al pedir pagina 2',

      build: () {
        // Crear el BLoC.
        when(
          () => repository.getBreweries(page: 1, perPage: 20),
        ).thenAnswer((_) async => firstListBrewery);

        when(
          () => repository.getBreweries(page: 2, perPage: 20),
        ).thenAnswer((_) async => secondListBrewery);

        return BreweryListBloc(repository);
      },

      act: (bloc) async {
        // Enviar eventos.
        bloc.add(const BreweryListRequested());
        // esperar la primera pagina antes de pedir la siguiente
        await bloc.stream.firstWhere((state) => state is BreweryListLoaded);

        bloc.add(const BreweryListNextRequested());
      },

      expect: () => [
        // Estados esperados.
        isA<BreweryListLoading>(),
        //carga primera pagina
        isA<BreweryListLoaded>()
            .having((state) => state.breweries.length, 'primera pagina', 20)
            .having((state) => state.nextPage, 'nextPage', 2),
        //cambia estado para revisar si se esta cargando otra pagina
        isA<BreweryListLoaded>()
            .having((state) => state.breweries.length, 'lista anterior', 20)
            .having((state) => state.isLoadingMore, 'cargando mas', true),
        // carga pagina 2 y actualiza lista con la anterior y nueva
        isA<BreweryListLoaded>()
            .having((state) => state.breweries.length, 'total', 40)
            .having((state) => state.nextPage, 'nextPage', 3)
            .having((state) => state.hasMore, 'hasMore', true)
            .having((state) => state.isLoadingMore, 'carga terminada', false),
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
        verify(() => repository.getBreweries(page: 2, perPage: 20)).called(1);
      },
    );
    // Verificar Error en la segunda pagina

    blocTest<BreweryListBloc, BreweryListState>(
      'Conserva las 20 cervecerias si falla la pagina 2',

      build: () {
        // Crear el BLoC.
        when(
          () => repository.getBreweries(page: 1, perPage: 20),
        ).thenAnswer((_) async => firstListBrewery);
        when(
          () => repository.getBreweries(page: 2, perPage: 20),
        ).thenThrow(const ServerException());

        return BreweryListBloc(repository);
      },

      act: (bloc) async {
        // Enviar eventos.
        bloc.add(const BreweryListRequested());
        // esperar la primera pagina antes de pedir la siguiente
        await bloc.stream.firstWhere((state) => state is BreweryListLoaded);

        bloc.add(const BreweryListNextRequested());
      },


      expect: () => [
        // Estados esperados.
        isA<BreweryListLoading>(),

        //Page 1
        isA<BreweryListLoaded>()
            .having((state) => state.breweries.length, 'primera pagina', 20),

        isA<BreweryListLoaded>()
            .having((state) => state.isLoadingMore, 'cargando mas', true),

        isA<BreweryListLoaded>()
            .having((state) => state.isLoadingMore, 'carga terminada', false)
            .having((state) => state.paginationError, 'error de paginacion',
                'Ocurrio un error al cargar mas cervecerias.')
      ],
      verify: (_) {
        verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1);
        verify(() => repository.getBreweries(page: 2, perPage: 20)).called(1);
      },
    );
  });
}

List<Brewery> _makeBreweries(int count) {
  return List.generate(count, (_) => MockBrewery());
}
