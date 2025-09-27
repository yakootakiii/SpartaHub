import 'package:flutter/material.dart';
import 'cart_page/cart_tab.dart';
import 'cart_page/favorites_tab.dart';
import 'cart_page/saved_tab.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFFCD0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFCD0000),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(0xFFCD0000),
          tabs: [
            Tab(text: 'Cart'),
            Tab(text: 'Favorites'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [CartTab(), FavoritesTab(), SavedTab()],
      ),
    );
  }
}
