import 'package:flutter/material.dart';

import '../../domain/entities/brewery.dart';
import '../brewery_type_label.dart';

class BreweryTile extends StatelessWidget {
  const BreweryTile({super.key, required this.brewery, required this.onTap});

  final Brewery brewery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final city = brewery.city ?? 'City not available';
    return ListTile(
      title: Text(brewery.name),
      subtitle: Text('${brewery.breweryType.label} · $city'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
