import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: const [
          Icon(Icons.add),
          SizedBox(width: 12),
        ],
      ),
      body: const _EmptyState(),
    );
  }
}

/* ================= EMPTY STATE ================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No categories available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
