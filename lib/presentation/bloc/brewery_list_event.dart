part of 'brewery_list_bloc.dart';

//Sealed limita las subclases a la misma libreria
//props determina que propiedades participan en la comparacion
sealed class BreweryListEvent extends Equatable{
  const BreweryListEvent();

  @override
  List<Object?> get props => [];
}


final class BreweryListRequested extends BreweryListEvent {

  const BreweryListRequested();

}

final class BreweryListNextRequested extends BreweryListEvent {
  const BreweryListNextRequested();
}

//
// final class BreweryListRequested extends BreweryListEvent {
//   const BreweryListRequested({this.query = ''});
//
//   final String query;
//
//   @override
//   List<Object?> get props => [query];
// }
//
// final class BreweryNextPageRequested extends BreweryListEvent{
//   const BreweryNextPageRequested();
//
// }
//
//
// final class BrewerySearchChanged extends BreweryListEvent {
//   const BrewerySearchChanged(this.query);
//
//   final String query;
//
//   @override
//   List<Object?> get props => [query];
// }

