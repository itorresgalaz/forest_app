import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forestchallenger/core/router/routes.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/brewery.dart';
import '../di/injection.dart';


abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/breweries',
    routes: [
      GoRoute(
        path: '/breweries',
        name: RouteNames.breweries,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<BreweriesBloc>(),
            child: const BreweriesPage(),
          );
        },
      ),
      GoRoute(
        path: '/breweries/:id',
        name: RouteNames.breweryDetail,
        builder: (context, state) {
          final brewery = state.extra;

          if (brewery is! Brewery ||
              brewery.id != state.pathParameters['id']) {
            return const Scaffold(
              body: Center(
                child: Text('Brewery details unavailable'),
              ),
            );
          }

          return BreweryDetailPage(brewery: brewery);
        },
      ),
    ],
  );
}