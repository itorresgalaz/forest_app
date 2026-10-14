import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:forest_breweries/app/app_routes.dart';
import 'package:forest_breweries/presentation/bloc/brewery_list_bloc.dart';
import 'package:forest_breweries/presentation/widgets/brewery_tile.dart';
import 'package:forest_breweries/presentation/widgets/message_view.dart';

class BreweryListScreen extends StatefulWidget {
  const BreweryListScreen({super.key});

  @override
  State<BreweryListScreen> createState() => _BreweryListScreenState();
}

class _BreweryListScreenState extends State<BreweryListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 300) return;

    final bloc = context.read<BreweryListBloc>();
    final state = bloc.state;
    // Do not auto-retry a failed page on every scroll tick: the user retries
    // explicitly with the button in the list footer.
    if (state is BreweryListLoaded && state.paginationError == null) {
      bloc.add(const BreweryNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breweries')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search breweries',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) => context
                  .read<BreweryListBloc>()
                  .add(BrewerySearchChanged(value)),
            ),
          ),
          Expanded(
            child: BlocBuilder<BreweryListBloc, BreweryListState>(
              builder: (context, state) => switch (state) {
                BreweryListInitial() || BreweryListLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                BreweryListEmpty(:final query) => MessageView(
                  icon: Icons.search_off,
                  message: query.isEmpty
                      ? 'No breweries found.'
                      : 'No breweries match "$query".',
                ),
                BreweryListFailure(:final message, :final query) => MessageView(
                  icon: Icons.error_outline,
                  message: message,
                  onRetry: () => context
                      .read<BreweryListBloc>()
                      .add(BreweryListRequested(query: query)),
                ),
                BreweryListLoaded() => _BreweryList(
                  state: state,
                  controller: _scrollController,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BreweryList extends StatelessWidget {
  const _BreweryList({required this.state, required this.controller});

  final BreweryListLoaded state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final hasFooter = state.isLoadingMore || state.paginationError != null;
    final count = state.breweries.length;

    return ListView.builder(
      controller: controller,
      itemCount: count + (hasFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < count) {
          final brewery = state.breweries[index];
          return BreweryTile(
            brewery: brewery,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.detail,
              arguments: brewery.id,
            ),
          );
        }
        return _ListFooter(state: state);
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final BreweryListLoaded state;

  @override
  Widget build(BuildContext context) {
    final error = state.paginationError;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context
                  .read<BreweryListBloc>()
                  .add(const BreweryNextPageRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
