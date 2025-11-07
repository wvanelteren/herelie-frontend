import 'package:flutter/material.dart';

import '../pages/input_recipe_page.dart';
import '../pages/recipe_list_page.dart';
import '../pages/shopping_list_page.dart';
import '../widgets/app_bottom_bar.dart';

void navigateToTab(BuildContext context, AppTab tab) {
  Widget destination;
  switch (tab) {
    case AppTab.recipes:
      destination = const RecipeListPage();
      break;
    case AppTab.input:
      destination = const InputRecipePage();
      break;
    case AppTab.shopping:
      destination = const ShoppingListPage();
      break;
  }

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => destination),
  );
}
