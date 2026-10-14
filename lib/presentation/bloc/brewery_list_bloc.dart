import 'dart:async';
import 'dart:collection';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forestchallenger/core/errors/app_exception.dart';
import 'package:forestchallenger/domain/entities/brewery.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/brewery_repository.dart';

part 'brewery_list_event.dart';

part 'brewery_list_state.dart';

@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repo) : super (const BreweryListInitial()) {

    on<BreweryListRequested>(
        _onRequested,
        transformer: restartable()
    );

    // on<BrewerySearchChanged>(
    //     _onSearchChanged,
    //     transformer: _debounceRestartable(searchDebounce)
    // );
    //
    // on<BreweryNextPageRequested>(
    //     _onNextPage,
    //     transformer: droppable()
    // );
  }

  static const pageSize = 20;
  static const searchDebounce = Duration(milliseconds: 300);
  final BreweryRepository _repo;

  int _generation = 0;

  Future<void> _onRequested(
      BreweryListRequested event,
      Emitter<BreweryListState> emit,
      ) async {
      try {

      }

  }




  FutureOr<void> _onSearchChanged(BrewerySearchChanged event,
      Emitter<BreweryListState> emit) {}

  FutureOr<void> _onNextPage(BreweryNextPageRequested event,
      Emitter<BreweryListState> emit) {}
}

