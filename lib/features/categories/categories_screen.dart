import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: categories.map((c) {
          return Card(
            child: ListTile(
              title: Text(c.name),
              trailing: const Icon(Icons.delete_outline),
            ),
          );
        }).toList(),
      ),
    );
  }
}
