import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/currency_format.dart';
import '../../domain/entities/purchase_plan.dart';
import '../blocs/shopping_list/shopping_list_cubit.dart';
import '../blocs/shopping_list/shopping_list_state.dart';
import '../navigation/tab_navigation.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/basic_scaffold.dart';
import '../widgets/product_tile.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingListCubit, ShoppingListState>(
      builder: (context, state) {
        final actions = state.plans.isEmpty
            ? null
            : [
                TextButton(
                  onPressed: () => context.read<ShoppingListCubit>().clear(),
                  child: const Text('Lijst leegmaken'),
                ),
              ];
        return BasicScaffold(
          actions: actions,
          bottomNavigationBar: AppBottomBar(
            currentTab: AppTab.shopping,
            onTabSelected: (tab) {
              if (tab == AppTab.shopping) return;
              navigateToTab(context, tab);
            },
          ),
          child: _ShoppingListBody(state: state),
        );
      },
    );
  }
}

class _ShoppingListBody extends StatelessWidget {
  final ShoppingListState state;
  const _ShoppingListBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.plans.isEmpty) {
      return const _EmptyListMessage();
    }

    return Column(
      children: [
        if (state.error != null) ...[
          _InlineError(message: state.error!),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: ListView.separated(
            itemCount: state.plans.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final plan = state.plans[index];
              final title = state.recipeTitle(plan.recipeId);
              return _ShoppingPlanSection(plan: plan, recipeTitle: title);
            },
          ),
        ),
      ],
    );
  }
}

class _ShoppingPlanSection extends StatelessWidget {
  final PurchasePlan plan;
  final String recipeTitle;

  const _ShoppingPlanSection({
    required this.plan,
    required this.recipeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ShoppingListCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                recipeTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Verwijder recept uit boodschappenlijst',
              onPressed: () => cubit.removeRecipe(plan.recipeId),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...plan.items.map(
          (item) => ProductTile(item: item),
        ),
        const SizedBox(height: 8),
        Text(
          'Totaal: ${formatEuro(plan.totalCostEur)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        message,
        style: TextStyle(color: color),
      ),
    );
  }
}

class _EmptyListMessage extends StatelessWidget {
  const _EmptyListMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nog niets op je lijst',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg producten toe vanuit je recepten.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
