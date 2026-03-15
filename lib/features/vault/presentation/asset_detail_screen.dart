import 'package:flutter/material.dart';

/// Asset Detail Screen — placeholder for asset details view.
class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Details'),
      ),
      body: const Center(
        child: Text('Asset Details'),
      ),
    );
  }
}
