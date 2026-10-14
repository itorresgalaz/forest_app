
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
    on<BreweryListRequested>(_onRequested);
    on<BreweryListNextRequested>(_nextPageRequested, transformer: droppable()); //Droppable hace que si se genera nuevamente la misma solucitud las descarte
  }

  static const int pageSize = 20;

  final BreweryRepository _repo;

  Future<void> _onRequested(
      BreweryListRequested event,
      Emitter<BreweryListState> emit,
      ) async {
    emit(const BreweryListLoading());

    try {
      final breweries = await _repo.getBreweries(
        page: 1,
        perPage: pageSize,
      );

      if (emit.isDone) return;

      if (breweries.isEmpty) {
        emit(const BreweryListEmpty());
        return;
      }

      emit(
        BreweryListLoaded(
          breweries: breweries,
          nextPage: 2,
          hasMore: breweries.length == pageSize
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone) return;
      emit(
        BreweryListFailure(
          message: switch (error) {
            NetworkException() =>
            'Revisa tu conexión a internet.',

            ServerException() =>
            'Ocurrió un problema con el servidor.',

            NotFoundException() =>
            'No encontramos la información solicitada.',

            InvalidDataException() =>
            'No pudimos procesar la información recibida.',
          },
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (emit.isDone) return;
      emit(
        const BreweryListFailure(
          message: 'Ocurrió un error inesperado.',
        ),
      );
    }
  }

  Future<void> _nextPageRequested(
      BreweryListNextRequested event,
      Emitter<BreweryListState> emit,
      ) async {
      final now = state;

      if (now is! BreweryListLoaded || !now.hasMore || now.isLoadingMore){
        return;
      }

      final loadingMore = now.copyWith(
        isLoadingMore: true,
        clearPaginationError: true,
      );

      emit(loadingMore); // emite el cambio para que el evento cambie isLoadingMore a true

    try {
      final nextQuery = await _repo.getBreweries(
          page: now.nextPage,
          perPage: pageSize,
      );
      if(emit.isDone) return;

      emit(
        loadingMore.copyWith(
          breweries: [
            ...now.breweries,
            ...nextQuery,
          ],
          nextPage: now.nextPage+1,
          hasMore: nextQuery.length == pageSize,
          isLoadingMore: false,
        ),
      );
    } on AppException catch (error){
      if (emit.isDone) return;

      //si hay error no perdemos la lista actual
      emit(
        loadingMore.copyWith(
          isLoadingMore: false,
          paginationError: 'Ocurrio un error al cargar mas cervecerias.',
        )
      );

    }
  }


}
