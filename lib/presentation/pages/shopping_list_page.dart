import 'package:flutter/material.dart';

import '../navigation/tab_navigation.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/basic_scaffold.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      title: 'Boodschappen',
      bottomNavigationBar: AppBottomBar(
        currentTab: AppTab.shopping,
        onTabSelected: (tab) {
          if (tab == AppTab.shopping) return;
          navigateToTab(context, tab);
        },
      ),
      child: const Center(
        child: Text('Boodschappenlijst komt binnenkort.'),
      ),
    );
  }
}
