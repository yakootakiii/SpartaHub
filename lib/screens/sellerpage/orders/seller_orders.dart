import 'package:flutter/material.dart';
import 'package:spartahubdev/screens/sellerpage/orders/seller_accepted_tab.dart';
import 'seller_orders_tab.dart';
import 'spartahelp_tab.dart';
// import 'seller_accepted_tab.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFCD0000),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFFCD0000),
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Accepted'),
            Tab(text: 'SpartaHelp'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [OrdersTab(), SellerAcceptedTab(), SpartaHelpTab()],
      ),
    );
  }
}
