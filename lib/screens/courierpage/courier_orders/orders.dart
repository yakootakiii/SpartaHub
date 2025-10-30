import 'package:flutter/material.dart';
import 'courier_accepted_order_tab.dart';
import 'courier_available_order_tab.dart';

class CourierOrderScreen extends StatefulWidget {
  const CourierOrderScreen({super.key});

  @override
  State<CourierOrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<CourierOrderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs only
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
          labelColor: Color(0xFFCD0000),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(0xFFCD0000),
          tabs: const [
            Tab(text: 'Available Orders'),
            Tab(text: 'Accepted Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [OrdersTab(), AcceptedOrdersTab()],
      ),
    );
  }
}
