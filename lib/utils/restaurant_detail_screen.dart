import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/food_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String sellerId; // Firestore seller ID
  final String name; // Restaurant name

  const RestaurantDetailScreen({
    super.key,
    required this.sellerId,
    required this.name,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String _searchQuery = '';

  Stream<QuerySnapshot> _getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: widget.sellerId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  setState(() => _searchQuery = val.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search on ${widget.name}',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // 🏷️ Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'Popular Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🎉 Promo + horizontal products
            SizedBox(
              height: 210,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (context, index) => const ShimmerCard(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No products available"));
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return _searchQuery.isEmpty || name.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length + 1, // +1 for promo card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          width: 300,
                          height: 160,
                          margin: const EdgeInsets.only(right: 12, bottom: 30),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFCD0000,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Promos for this week!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Discount 25% off',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final data =
                            products[index - 1].data() as Map<String, dynamic>;
                        final priceRaw = data['price'];
                        final price = priceRaw is num
                            ? priceRaw.toDouble()
                            : 0.0;

                        return FoodCard(
                          key: ValueKey(products[index - 1].id),
                          name: data['name'] ?? 'Unnamed',
                          restaurant: widget.name,
                          price: price,
                          sellerId: widget.sellerId,
                        );
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🗂️ All products list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'All Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 220,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (context, index) => const ShimmerCard(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No products available"));
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return _searchQuery.isEmpty || name.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data =
                          products[index].data() as Map<String, dynamic>;
                      final priceRaw = data['price'];
                      final price = priceRaw is num ? priceRaw.toDouble() : 0.0;

                      return FoodCard(
                        key: ValueKey(products[index].id),
                        name: data['name'] ?? 'Unnamed',
                        restaurant:
                            data['sellerName'] ??
                            'Unknown', // use sellerName field
                        price: price,
                        sellerId: data['sellerId'], // already in product
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
