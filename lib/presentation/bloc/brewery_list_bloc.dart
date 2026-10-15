
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/domain/entities/brewery.dart';
import 'package:forestchallenger/domain/repositories/brewery_repository.dart';


part 'brewery_list_event.dart';
part 'brewery_list_state.dart';

@injectable
class BreweryListBloc
    extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repo)
      : super(const BreweryListInitial()) {
    on<BreweryListRequested>(
      _onRequested,
      transformer: restartable(),
    );

    on<BrewerySearchChanged>(
      _onSearchChanged,
      transformer: restartable(),
    );

    on<BreweryListNextRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );
  }

  static const int pageSize = 20;
  static const searchDebounce =
  Duration(milliseconds: 350);

  final BreweryRepository _repo;

  // Identifica la versión actual de los resultados.
  int _generation = 0;

  // 1. CARGA INICIAL O RECARGA GENERAL
  Future<void> _onRequested(
      BreweryListRequested event,
      Emitter<BreweryListState> emit,
      ) async {
    final generation = ++_generation;

    emit(const BreweryListLoading());

    await _loadFirstPage(
      query: '',
      generation: generation,
      emit: emit,
    );
  }

  // 2. CAMBIO DEL TEXTO DE BÚSQUEDA
  Future<void> _onSearchChanged(
      BrewerySearchChanged event,
      Emitter<BreweryListState> emit,
      ) async {
    final query = event.query.trim();
    final generation = ++_generation;

    emit(BreweryListLoading(query: query));

    // Esperar antes de consultar la API.
    await Future<void>.delayed(searchDebounce);

    // Si llegó otra búsqueda, ignorar esta.
    if (emit.isDone || generation != _generation) {
      return;
    }

    // La API exige al menos tres caracteres.
    if (query.isNotEmpty && query.length < 3) {
      emit(BreweryListEmpty(query: query));
      return;
    }

    await _loadFirstPage(
      query: query,
      generation: generation,
      emit: emit,
    );
  }

  // 3. CARGAR PRIMERA PÁGINA
  Future<void> _loadFirstPage({
    required String query,
    required int generation,
    required Emitter<BreweryListState> emit,
  }) async {
    try {
      final breweries = await _fetchPage(
        query: query,
        page: 1,
      );

      if (emit.isDone || generation != _generation) {
        return;
      }

      if (breweries.isEmpty) {
        emit(BreweryListEmpty(query: query));
        return;
      }

      emit(
        BreweryListLoaded(
          breweries: breweries,
          nextPage: 2,
          hasMore: breweries.length == pageSize,
          query: query,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || generation != _generation) {
        return;
      }

      emit(
        BreweryListFailure(
          message: error.message,
          query: query,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      if (emit.isDone || generation != _generation) {
        return;
      }

      emit(
        BreweryListFailure(
          message: 'Ocurrió un error inesperado.',
          query: query,
        ),
      );
    }
  }

  // 4. PAGINACIÓN
  Future<void> _onNextPageRequested(
      BreweryListNextRequested event,
      Emitter<BreweryListState> emit,
      ) async {
    final current = state;

    if (current is! BreweryListLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    final generation = _generation;

    final loadingMore = current.copyWith(
      isLoadingMore: true,
      clearPaginationError: true,
    );

    emit(loadingMore);

    try {
      final newBreweries = await _fetchPage(
        query: current.query,
        page: current.nextPage,
      );

      if (emit.isDone || generation != _generation) {
        return;
      }

      emit(
        loadingMore.copyWith(
          breweries: [
            ...current.breweries,
            ...newBreweries,
          ],
          nextPage: current.nextPage + 1,
          hasMore: newBreweries.length == pageSize,
          isLoadingMore: false,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || generation != _generation) {
        return;
      }

      emit(
        loadingMore.copyWith(
          isLoadingMore: false,
          paginationError: error.message,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      if (emit.isDone || generation != _generation) {
        return;
      }

      emit(
        loadingMore.copyWith(
          isLoadingMore: false,
          paginationError:
          'No pudimos cargar más cervecerías.',
        ),
      );
    }
  }

  // 5. SELECCIONAR LA OPERACIÓN DEL REPOSITORIO
  Future<List<Brewery>> _fetchPage({
    required String query,
    required int page,
  }) {
    if (query.isEmpty) {
      return _repo.getBreweries(
        page: page,
        perPage: pageSize,
      );
    }

    return _repo.searchBreweries(
      query: query,
      page: page,
      perPage: pageSize,
    );
  }
}
