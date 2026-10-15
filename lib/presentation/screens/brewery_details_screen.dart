import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forestchallenger/presentation/cubit/brewery_detail_cubit.dart';

class BreweryDetailScreen extends StatelessWidget {
  const BreweryDetailScreen({super.key, required this.breweryId});

  final String breweryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Cerveceria'),
      ),
      body: BlocBuilder<BreweryDetailCubit,BreweryDetailState>(
        builder: (context, state) {
          //estado inicial o cargando
          if (state is BreweryDetailInitial ||
              state is BreweryDetailLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //si el estado es fallido
          if (state is BreweryDetailFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: ()=> {
                          context.read<BreweryDetailCubit>().loadBrewery(breweryId),
                        }, 
                        child: const Text('Reintentar')
                    )
                  ],
                ),
              ),
            );
          }
          if(state is BreweryDetailLoaded){
            final brewery = state.brewery;
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  brewery.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  brewery.phone ?? 'Sin Telefono',
                  style: Theme.of(context).textTheme.headlineMedium,
                )

              ],
            );
          }
          return const SizedBox.shrink();
        },

      ),
    );
  }
}
