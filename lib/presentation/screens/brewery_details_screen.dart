
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      onTap: () => _open(
                        context,
                        Uri(scheme: 'tel', path: brewery.phone!.trim()),
                        'No se pudo abrir el teléfono.',
                      ),
                    ),
                    _DetailRows(
                      title: 'Website',
                      value: brewery.websiteUrl,
                      onTap: () => _open(
                        context,
                        _websiteUri(brewery.websiteUrl!),
                        'No se pudo abrir el sitio web.',
                      ),
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
    this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value?.trim().isNotEmpty ?? false;
    final displayValue = hasValue ? value!.trim() : 'No disponible';

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
          if (hasValue && onTap != null)
            InkWell(
              onTap: onTap,
              child: Text(
                displayValue,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            SelectableText(displayValue),
        ],
      ),
    );
  }
}

/// Abre [uri] en la app externa correspondiente; avisa con un SnackBar si falla.
Future<void> _open(BuildContext context, Uri uri, String errorMessage) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}

/// Asegura un esquema para que el sitio web se pueda abrir.
Uri _websiteUri(String raw) {
  final value = raw.trim();
  return Uri.parse(
    value.startsWith('http://') || value.startsWith('https://')
        ? value
        : 'https://$value',
  );
}
