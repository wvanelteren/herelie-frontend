import 'package:equatable/equatable.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/purchase_plan.dart';
import '../../../domain/entities/recipe.dart';

class RecipeDetailState extends Equatable {
  final Recipe recipe;
  final int servings;
  final List<Ingredient> scaledIngredients;
  final PurchasePlan? purchasePlan;
  final bool isLoadingPlan;
  final bool planLoadFailed;
  final bool needsPlanRefresh;

  const RecipeDetailState({
    required this.recipe,
    required this.servings,
    required this.scaledIngredients,
    this.purchasePlan,
    this.isLoadingPlan = false,
    this.planLoadFailed = false,
    this.needsPlanRefresh = false,
  });

  double get multiplier {
    final baseServings = recipe.servings;
    if (baseServings <= 0) return 1;
    return servings / baseServings;
  }

  bool get canDecrease => servings > 1;

  RecipeDetailState copyWith({
    int? servings,
    List<Ingredient>? scaledIngredients,
    PurchasePlan? purchasePlan,
    bool clearPurchasePlan = false,
    bool? isLoadingPlan,
    bool? planLoadFailed,
    bool? needsPlanRefresh,
  }) => RecipeDetailState(
    recipe: recipe,
    servings: servings ?? this.servings,
    scaledIngredients: scaledIngredients ?? this.scaledIngredients,
    purchasePlan: clearPurchasePlan
        ? null
        : (purchasePlan ?? this.purchasePlan),
    isLoadingPlan: isLoadingPlan ?? this.isLoadingPlan,
    planLoadFailed: planLoadFailed ?? this.planLoadFailed,
    needsPlanRefresh: needsPlanRefresh ?? this.needsPlanRefresh,
  );

  @override
  List<Object?> get props => [
    recipe,
    servings,
    scaledIngredients,
    purchasePlan,
    isLoadingPlan,
    planLoadFailed,
    needsPlanRefresh,
  ];
}
