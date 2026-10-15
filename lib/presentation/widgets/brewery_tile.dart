import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/brewery.dart';

class BreweryTile extends StatelessWidget {
  const BreweryTile({super.key, required this.brewery, required this.onTap});

  final Brewery brewery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(brewery.name),
      subtitle: Text(
        '${brewery.breweryType} · '
            '${brewery.city ?? "Sin ciudad"}',
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: () {
        context.pushNamed(
          'brewery-detail',
          pathParameters: {
            'id': brewery.id,
          },
        );
      },
    );
  }
}
