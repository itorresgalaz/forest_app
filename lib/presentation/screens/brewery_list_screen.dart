
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/brewery_list_bloc.dart';

class BreweryListScreen extends StatefulWidget {
  const BreweryListScreen({super.key});

  @override
  State<BreweryListScreen> createState() => _BreweryListScreenState();
}

class _BreweryListScreenState extends State<BreweryListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_scroll);
  }

  void _scroll(){
    if(!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter >= 50){
      return;
    }

    final bloc = context.read<BreweryListBloc>(); // Leo el state del bloc
    final current = bloc.state;

    if(current is! BreweryListLoaded || !current.hasMore || current.isLoadingMore || current.paginationError != null){
      return;
    }
    bloc.add(const BreweryListNextRequested());

  }

  @override
  void dispose() {
    _scrollController.removeListener(_scroll);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breweries'),
      ),
      body: BlocBuilder<BreweryListBloc, BreweryListState>(
        builder: (context, state) {
          if (state is BreweryListInitial ||
              state is BreweryListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BreweryListEmpty) {
            return const Center(
              child: Text('No hay cervecerías disponibles'),
            );
          }

          if (state is BreweryListFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BreweryListBloc>().add(
                        const BreweryListRequested(),
                      );
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
                if(index == state.breweries.length){
                  return _Footer(state: state);
                }
                final brewery = state.breweries[index];

                return ListTile(
                  title: Text('${brewery.name}'),
                  subtitle: Text(
                    'Kind: ${brewery.breweryType.name} · '
                        'City: ${brewery.city ?? "Unknow"}',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    // context.pushNamed(
                    //   'brewery-detail',
                    //   pathParameters: {
                    //     'id': brewery.id,
                    //   },
                    // );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
  });
  final BreweryListLoaded state;

  @override
  Widget build(BuildContext context) {
    if(state.isLoadingMore){
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if(state.paginationError != null){
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(state.paginationError!),
              TextButton(
                  onPressed: () {
                    context.read<BreweryListBloc>().add(
                        const BreweryListNextRequested()
                    );
                  },
                  child: const Text('Reintentar')
              )
            ],
          ),
      );
    }
    if (!state.hasMore) {
      return  const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No hay mas cervecerias'),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

}
