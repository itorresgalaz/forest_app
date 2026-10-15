import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/domain/entities/brewery.dart';
import 'package:forestchallenger/domain/repositories/brewery_repository.dart';


part 'brewery_detail_state.dart';

@injectable
class BreweryDetailCubit extends Cubit<BreweryDetailState> {
  BreweryDetailCubit(this._repo) : super(const BreweryDetailInitial());

  final BreweryRepository _repo;

  Future<void> loadBrewery(String id) async {
    if (id.trim().isEmpty) {
      //si viene vacio emito un state Failure
      emit(
        BreweryDetailFailure(
          message: 'El identificador de cerveceria invalido',
        ),
      );
      return;
    }
    emit(BreweryDetailLoading());

    try {
      final brewery = await _repo.getBrewery(id);
      if (isClosed) return;
      emit(BreweryDetailLoaded(brewery: brewery));
    } on AppException catch (error) {
      if (isClosed) return;
      emit(BreweryDetailFailure(message: error.message));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (isClosed) return;
      emit(BreweryDetailFailure(message: 'Ocurrio un error inesperado'));
    }
  }
}
