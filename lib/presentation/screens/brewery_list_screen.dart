
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:forestchallenger/presentation/bloc/brewery_list_bloc.dart';

import '../widgets/brewery_tile.dart';

class BreweryListScreen extends StatefulWidget {
  const BreweryListScreen({super.key});

  @override
  State<BreweryListScreen> createState() =>
      _BreweryListScreenState();
}

class _BreweryListScreenState
    extends State<BreweryListScreen> {
  final ScrollController _scrollController =
  ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter >= 200) {
      return;
    }

    final bloc = context.read<BreweryListBloc>();
    final current = bloc.state;

    if (current is! BreweryListLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.paginationError != null) {
      return;
    }

    bloc.add( BreweryListNextRequested());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forest Breweries'),
      ),
      body: Column(
        children: [
          // CAMPO DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar cervecerías',
                hintText: 'Escribe al menos 3 caracteres',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }

                context.read<BreweryListBloc>().add(
                  BrewerySearchChanged(value),
                );
              },
            ),
          ),

          // RESULTADOS
          Expanded(
            child: BlocBuilder<
                BreweryListBloc,
                BreweryListState>(
              builder: (context, state) {
                if (state is BreweryListInitial ||
                    state is BreweryListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is BreweryListEmpty) {
                  final message =
                  state.query.isNotEmpty &&
                      state.query.length < 3
                      ? 'Escribe al menos 3 caracteres.'
                      : 'No encontramos cervecerías.';

                  return Center(
                    child: Text(message),
                  );
                }

                if (state is BreweryListFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            final bloc = context.read<
                                BreweryListBloc>();

                            if (state.query.isEmpty) {
                              bloc.add(
                                const BreweryListRequested(),
                              );
                            } else {
                              bloc.add(
                                BrewerySearchChanged(
                                  state.query,
                                ),
                              );
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BreweryListLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.breweries.length + 1,
                    itemBuilder: (context, index) {
                      if (index ==
                          state.breweries.length) {
                        return _PaginationFooter(
                          state: state,
                        );
                      }

                      final brewery =
                      state.breweries[index];

                      return BreweryTile(brewery: brewery, onTap: () => {  },);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.state,
  });

  final BreweryListLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.paginationError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(state.paginationError!),
            TextButton(
              onPressed: () {
                context.read<BreweryListBloc>().add(
                   BreweryListNextRequested(),
                );
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No hay más cervecerías'),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
