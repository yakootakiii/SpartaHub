import 'package:flutter/material.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String restaurant;
  final double price;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.restaurant,
    required this.price,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  // String _selectedSize = 'Regular';
  final List<String> _selectedAddOns = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.fastfood, size: 100, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.foodName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.restaurant,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Price
                  Text(
                    '₱${widget.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Delicious and authentic Filipino dish made with tender chicken cooked in soy sauce, vinegar, and aromatic spices. Served with steamed rice.',
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),

                  SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                            icon: Icon(Icons.remove_circle_outline),
                            color: Color(0xFFCD0000),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _quantity.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: Icon(Icons.add_circle_outline),
                            color: Color(0xFFCD0000),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // SizedBox(height: 24),

                  // // Size Options
                  // Text(
                  //   'Size',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     _buildSizeOption(
                  //       'Small',
                  //       '₱${(widget.price * 0.8).toStringAsFixed(0)}',
                  //     ),
                  //     _buildSizeOption(
                  //       'Regular',
                  //       '₱${widget.price.toStringAsFixed(0)}',
                  //     ),
                  //     _buildSizeOption(
                  //       'Large',
                  //       '₱${(widget.price * 1.2).toStringAsFixed(0)}',
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 24),

                  // Add-ons
                  Text(
                    'Add-ons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildAddOnOption('Extra Rice', 15),
                  _buildAddOnOption('Iced Tea', 25),
                  _buildAddOnOption('Extra Sauce', 10),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Added to cart!')));
                },
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                label: Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Color(0xFFCD0000)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Order placed!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCD0000),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Order Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSizeOption(String size, String price) {
  //   bool isSelected = _selectedSize == size;
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           _selectedSize = size;
  //         });
  //       },
  //       child: Container(
  //         margin: EdgeInsets.only(right: size != 'Large' ? 8 : 0),
  //         padding: EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: isSelected
  //               ? Color(0xFFCD0000).withValues(alpha: 0.1)
  //               : Colors.grey[100],
  //           border: Border.all(
  //             color: isSelected ? Color(0xFFCD0000) : Colors.grey[300]!,
  //           ),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Column(
  //           children: [
  //             Text(
  //               size,
  //               style: TextStyle(
  //                 fontWeight: FontWeight.w600,
  //                 color: isSelected ? Color(0xFFCD0000) : Colors.black,
  //               ),
  //             ),
  //             Text(
  //               price,
  //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAddOnOption(String name, double price) {
    bool isSelected = _selectedAddOns.contains(name);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedAddOns.add(name);
            } else {
              _selectedAddOns.remove(name);
            }
          });
        },
        title: Text(name),
        subtitle: Text('+ ₱${price.toStringAsFixed(0)}'),
        activeColor: Color(0xFFCD0000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.grey[50],
      ),
    );
  }
}
