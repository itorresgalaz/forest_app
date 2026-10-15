
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:forestchallenger/presentation/bloc/brewery_list_bloc.dart';
import 'package:forestchallenger/presentation/cubit/brewery_detail_cubit.dart';
import 'package:forestchallenger/presentation/screens/brewery_list_screen.dart';

import '../../presentation/screens/brewery_details_screen.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create({
    required BreweryListBloc Function() createListBloc,
    required BreweryDetailCubit Function() createDetailCubit,
  }) {
    return GoRouter(
      initialLocation: '/breweries',
      routes: [
        GoRoute(
          path: '/breweries',
          name: 'brewery-list',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => createListBloc()
                ..add(const BreweryListRequested()),
              child: const BreweryListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/breweries/:id',
          name: 'brewery-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;

            return BlocProvider(
              create: (_) => createDetailCubit()
                ..loadBrewery(id),
              child: BreweryDetailScreen(
                breweryId: id,
              ),
            );
          },
        ),
      ],
    );
  }
}
