
import 'package:flutter/material.dart';
import 'package:forestchallenger/presentation/bloc/brewery_list_bloc.dart';
import 'package:forestchallenger/presentation/cubit/brewery_detail_cubit.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  final router = AppRouter.create(
    createListBloc: () => getIt<BreweryListBloc>(),
    createDetailCubit: () => getIt<BreweryDetailCubit>(),
  );

  runApp(ForestBreweriesApp(router: router));
}

class ForestBreweriesApp extends StatelessWidget {
  const ForestBreweriesApp({
    required this.router,
    super.key,
  });

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Forest Breweries',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
