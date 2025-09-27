import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_card.dart';
import 'shimmer_card.dart';

class CategorySelector extends StatefulWidget {
  final bool useCollectionGroup;
  const CategorySelector({super.key, this.useCollectionGroup = false});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> _categories = ['Meals', 'Snacks', 'Drinks'];
  int _selected = 0;

  Stream<QuerySnapshot<Map<String, dynamic>>> _productStream(String category) {
    // Use collectionGroup for subcollections; collection for top-level collection
    if (widget.useCollectionGroup) {
      return FirebaseFirestore.instance
          .collectionGroup('products')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String selectedCategory = _categories[_selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Category Pills ===
        Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final bool active = _selected == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = index),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: active
                          ? Colors.red.withValues(alpha: 0.06)
                          : Colors.transparent,
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        //Product List for selected category
        SizedBox(
          height: 210,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _productStream(selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // helpful debug message in UI + console
                debugPrint('CategorySelector stream error: ${snapshot.error}');
                return Center(
                  child: Text('Error loading products:\n${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => ShimmerCard(),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              debugPrint(
                'Fetched ${docs.length} products for category $selectedCategory',
              );

              if (docs.isEmpty) {
                return const Center(child: Text("No products available"));
              }

              // Map to lightweight objects
              final products = docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'name': (data['name'] ?? 'Unnamed').toString(),
                  'price': (data['price'] is num)
                      ? (data['price'] as num).toDouble()
                      : 0.0,
                  'sellerName': (data['sellerName'] ?? 'Unknown Seller')
                      .toString(),
                  'sellerId': (data['sellerId'] ?? '').toString(),
                };
              }).toList();

              // Optional: shuffle or limit if you want
              // products.shuffle();
              // final visible = products.take(5).toList();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];

                  return SizedBox(
                    width: 160,
                    child: FoodCard(
                      key: ValueKey(item['id'] as String),
                      name: item['name']?.toString() ?? '',
                      restaurant: item['sellerName']?.toString() ?? '',
                      price: (item['price'] is num)
                          ? (item['price'] as num).toDouble()
                          : 0.0,
                      sellerId: item['sellerId']?.toString() ?? '',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
