
part of 'brewery_detail_cubit.dart';



sealed class BreweryDetailState extends Equatable {
  const BreweryDetailState();

  @override
  List<Object?> get props => [];
}

final class BreweryDetailInitial
    extends BreweryDetailState {
  const BreweryDetailInitial();
}

final class BreweryDetailLoading
    extends BreweryDetailState {
  const BreweryDetailLoading();
}

final class BreweryDetailLoaded
    extends BreweryDetailState {
  const BreweryDetailLoaded({
    required this.brewery,
  });

  final Brewery brewery;

  @override
  List<Object?> get props => [brewery];
}

final class BreweryDetailFailure
    extends BreweryDetailState {
  const BreweryDetailFailure({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
