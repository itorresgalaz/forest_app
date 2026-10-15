
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:forestchallenger/presentation/cubit/brewery_detail_cubit.dart';

class BreweryDetailScreen extends StatelessWidget {
  const BreweryDetailScreen({
    super.key,
    required this.breweryId,
  });

  final String breweryId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreweryDetailCubit, BreweryDetailState>(
      builder: (context, state) {
        final title = state is BreweryDetailLoaded
            ? state.brewery.name
            : 'Detalle de cervecería';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: switch (state) {
            BreweryDetailInitial() ||
            BreweryDetailLoading() =>
            const Center(
              child: CircularProgressIndicator(),
            ),

            BreweryDetailFailure(:final message) =>
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<BreweryDetailCubit>()
                                .loadBrewery(breweryId);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),

            BreweryDetailLoaded(:final brewery) =>
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DetailRows(
                      title: 'Dirección',
                      value: brewery.address1,
                    ),
                    _DetailRows(
                      title: 'Teléfono',
                      value: brewery.phone,
                    ),
                    _DetailRows(
                      title: 'Website',
                      value: brewery.websiteUrl,
                    ),
                  ],
                ),
          },
        );
      },
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({
    required this.title,
    required this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue =
    (value?.trim().isNotEmpty ?? false)
        ? value!
        : 'No disponible';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          SelectableText(displayValue),
        ],
      ),
    );
  }
}
