part of 'brewery_list_bloc.dart';

sealed class BreweryListState extends Equatable {
  const BreweryListState({
    this.query = '',
});

  final String query;

  @override
  List<Object?> get props => [query];
}

final class BreweryListInitial extends BreweryListState {
  const BreweryListInitial();
}

final class BreweryListLoading extends BreweryListState {
  const BreweryListLoading({super.query});
}

final class BreweryListEmpty extends BreweryListState {
  const BreweryListEmpty({super.query});
}

final class BreweryListFailure extends BreweryListState {

  const BreweryListFailure({required this.message, super.query});
  final String message;

  @override
  List<Object?> get props => [query,message];
}

final class BreweryListLoaded extends BreweryListState {
  //estado de listas cargadas
  const BreweryListLoaded({
    required this.breweries,
    required this.nextPage,
    required this.hasMore,
    this.paginationError,
    this.isLoadingMore = false,
    super.query
  });

  final List<Brewery> breweries;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? paginationError;

  BreweryListLoaded copyWith({
    List<Brewery>? breweries,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? paginationError,
    bool clearPaginationError = false,
  }) {
    return BreweryListLoaded(
      breweries: breweries ?? this.breweries,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: clearPaginationError
          ? null
          : paginationError ?? this.paginationError,
      query: query,
    );
  }
  @override
  List<Object?> get props => [
    query,
    breweries,
    nextPage,
    hasMore,
    isLoadingMore,
    paginationError,
  ];
}

//
// sealed class BreweryListState extends Equatable{
//   const BreweryListState({this.query = ''});
//
//   final String query;
//
//   @override
//   List<Object?> get props => [query];
// }
//
// final class BreweryListInitial extends BreweryListState {
//   const BreweryListInitial();
// }
//
// final class BreweryListLoading extends BreweryListState{
//   const BreweryListLoading({super.query});
// }
//
// final class BreweryListEmpty extends  BreweryListState{
//   const BreweryListEmpty({super.query});
// }
//
// final class BreweryListFail extends BreweryListState{
//   const BreweryListFail({required this.message, super.query});
//
//   final String message;
//
//   @override
//   List<Object?> get props => [query, message];
// }
//
//
// final class BreweryListLoaded extends BreweryListState{
//   const BreweryListLoaded({
//     required this.breweries,
//     required this.nextPage,
//     required this.hasMore,
//     this.isLoadingMore = false,
//     this.paginationError,
//     super.query
//   });
//
//   final List<Brewery> breweries;
//   final int nextPage;
//   final bool hasMore;
//   final bool isLoadingMore;
//   final String? paginationError;
//
//   BreweryListLoaded copyWith({
//     List<Brewery>? breweries,
//     int? nextPage,
//     bool? hasMore,
//     bool? isLoadingMore,
//     String? paginationError,
//     bool clearPaginationError = false,
//   }) {
//     return BreweryListLoaded(
//       breweries: breweries ?? this.breweries,
//       nextPage: nextPage ?? this.nextPage,
//       hasMore:hasMore ?? this.hasMore,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore ,
//       paginationError: clearPaginationError ? null : (paginationError ?? this.paginationError),
//       query: query
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     query,
//     breweries,
//     nextPage,
//     hasMore,
//     isLoadingMore,
//     paginationError,
//   ];
// }
