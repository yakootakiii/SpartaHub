import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:spartahubdev/widgets/category_slider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:spartahubdev/widgets/food_card.dart';
import 'package:spartahubdev/widgets/restaurant_card.dart';
import 'package:spartahubdev/widgets/shimmer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _foodItems = [];
  final List<Map<String, dynamic>> _restaurants = [];
  final bool _isLoading = false;
  final bool _hasMoreData = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isDisposed &&
        mounted &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      // 👇 optional: load more restaurants in future
    }
  }

  void _refreshData() {
    if (_isDisposed) return;
    setState(() {});
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', height: 50),
            const SizedBox(width: 8),
            Text(
              'SpartaHub',
              style: TextStyle(
                color: hexToColor('CD0000'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (!_isDisposed && mounted) {
              _refreshData();
              // Wait for the refresh to complete
              while (_isLoading && !_isDisposed && mounted) {
                await Future.delayed(Duration(milliseconds: 100));
              }
            }
          },
          color: Color(0xFFCD0000),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'What would you like today?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Special Feature Banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: hexToColor('CD0000'),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buy a Meal for Someone',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help fellow students in need',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 14),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFCD0000).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Promos for this week!',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Discount 25% off',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),

                              // --- spacing before the button ---
                              SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Handle order action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFCD0000),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'Order Now',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Popular Items
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Restaurants Near You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(onPressed: () {}, child: Text('See All')),
                    ],
                  ),
                ),

                // Lazy loaded food items
                if (_restaurants.isEmpty && _isLoading)
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ShimmerCard();
                      },
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('sellers')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return ShimmerCard();
                              },
                            ),
                          );
                        }

                        final sellers = snapshot.data!.docs;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: sellers.length,
                          itemBuilder: (context, index) {
                            final seller = sellers[index];
                            final sellerId = seller.id;

                            return RestaurantCard(
                              sellerId: sellerId,
                              name: seller['fullName'] ?? 'Unknown Seller',
                            );
                          },
                        );
                      },
                    ),
                  ),

                SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Quick Picks for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(onPressed: () {}, child: Text('See All')),
                    ],
                  ),
                ),

                SizedBox(
                  height: 210,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collectionGroup('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 3,
                          itemBuilder: (context, index) => ShimmerCard(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No products available"),
                        );
                      }

                      // Map products and include sellerName and sellerId from product doc
                      final products = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          'id': doc.id,
                          'name': data['name'] ?? 'Unnamed',
                          'price': (data['price'] is num)
                              ? (data['price'] as num).toDouble()
                              : 0.0,
                          'sellerName': data['sellerName'] ?? 'Unknown Seller',
                          'sellerId': data['sellerId'],
                        };
                      }).toList();

                      products.shuffle();
                      final limited = products.take(5).toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: limited.length,
                        itemBuilder: (context, index) {
                          final item = limited[index];
                          return FoodCard(
                            key: ValueKey(item['id']),
                            name: item['name'],
                            restaurant: item['sellerName'],
                            price: item['price'],
                            sellerId: item['sellerId'],
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  height: 210,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collectionGroup('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 3,
                          itemBuilder: (context, index) => ShimmerCard(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No products available"),
                        );
                      }

                      // Map products and include sellerName and sellerId from product doc
                      final products = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          'id': doc.id,
                          'name': data['name'] ?? 'Unnamed',
                          'price': (data['price'] is num)
                              ? (data['price'] as num).toDouble()
                              : 0.0,
                          'sellerName': data['sellerName'] ?? 'Unknown Seller',
                          'sellerId': data['sellerId'],
                        };
                      }).toList();

                      products.shuffle();
                      final limited = products.take(5).toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: limited.length,
                        itemBuilder: (context, index) {
                          final item = limited[index];
                          return FoodCard(
                            key: ValueKey(item['id']),
                            name: item['name'],
                            restaurant: item['sellerName'],
                            price: item['price'],
                            sellerId: item['sellerId'],
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                CategorySelector(),

                SizedBox(height: 20),

                // Loading indicator for more items
                if (_isLoading && _foodItems.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFCD0000),
                        ),
                      ),
                    ),
                  ),

                // End of data indicator
                if (!_hasMoreData && _foodItems.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No more items to load',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
