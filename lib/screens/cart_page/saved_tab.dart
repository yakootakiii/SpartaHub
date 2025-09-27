import 'package:flutter/material.dart';
import 'saved_item.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SavedItem(
          title: 'Weekly Grocery List',
          description: 'Saved for later ordering',
        ),
        SavedItem(
          title: 'School Supplies Bundle',
          description: 'For next semester',
        ),
        SavedItem(
          title: 'Birthday Party Package',
          description: 'Celebration essentials',
        ),
      ],
    );
  }
}
