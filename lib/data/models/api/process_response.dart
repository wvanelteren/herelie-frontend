import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/pp_ingredient.dart';
import '../../../domain/entities/recipe.dart';

part 'process_response.g.dart';

// ======= Top-level =======

@JsonSerializable(explicitToJson: true)
class ProcessResponse {
  @JsonKey(name: 'job_id')
  final String jobId;
  final ApiRecipe recipe;
  final Optimizer optimizer;

  ProcessResponse({
    required this.jobId,
    required this.recipe,
    required this.optimizer,
  });

  factory ProcessResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessResponseToJson(this);

  Recipe toEntity() {
    final solution = optimizer.solutions.isNotEmpty
        ? optimizer.solutions.first
        : null;
    final total = solution?.totalCostEur ?? 0.0;

    final ingredients = recipe.ingredients
        .map((e) => e.toEntity())
        .whereType<Ingredient>()
        .toList();

    final purchases = (solution?.purchasePlan ?? [])
        .map(
          (plan) => PurchasePlanIngredient(
            title: plan.productTitle ?? 'Onbekend product',
            amount: (plan.fulfilled ?? plan.requested)?.amount,
            unit: (plan.fulfilled ?? plan.requested)?.unit,
            ppIngredientCostEur: plan.totalCostEur,
            ingredientIds: plan.ingredientIds,
            packCount: plan.totalPackCount,
          ),
        )
        .toList();

    return Recipe(
      id: jobId,
      title: recipe.title,
      servings: recipe.servings,
      totalCostEur: total,
      ingredients: ingredients,
      purchasePlanIngredients: purchases,
      createdAt: DateTime.now(),
    );
  }
}

// ======= Nested: recipe =======

@JsonSerializable(explicitToJson: true)
class ApiRecipe {
  final String title;
  final int servings;
  final List<ApiIngredient> ingredients;

  ApiRecipe({
    required this.title,
    required this.servings,
    required this.ingredients,
  });

  factory ApiRecipe.fromJson(Map<String, dynamic> json) =>
      _$ApiRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$ApiRecipeToJson(this);
}

@JsonSerializable()
class ApiIngredient {
  @JsonKey(name: 'ingredient_id')
  final String? ingredientId;
  @JsonKey(name: 'parsed_ingredient')
  final IngredientDetails? parsedIngredient;
  final IngredientDetails? original;

  ApiIngredient({this.ingredientId, this.parsedIngredient, this.original});

  factory ApiIngredient.fromJson(Map<String, dynamic> json) =>
      _$ApiIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$ApiIngredientToJson(this);

  Ingredient? toEntity() {
    final source = parsedIngredient ?? original;
    if (source == null) return null;

    return Ingredient(
      id: ingredientId,
      name: source.name,
      amount: source.amount,
      unit: source.unit,
    );
  }
}

@JsonSerializable()
class IngredientDetails {
  final String name;
  final String? unit;
  final double? amount;

  IngredientDetails({required this.name, this.unit, this.amount});

  factory IngredientDetails.fromJson(Map<String, dynamic> json) =>
      _$IngredientDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientDetailsToJson(this);
}

// ======= Nested: optimizer / solutions =======

@JsonSerializable(explicitToJson: true)
class Optimizer {
  @JsonKey(name: 'job_id')
  final String jobId;
  @JsonKey(name: 'schema_version')
  final String schemaVersion;
  final OptimizerResult? result;

  Optimizer({required this.jobId, required this.schemaVersion, this.result});

  List<Solution> get solutions => result?.solutions ?? const [];

  factory Optimizer.fromJson(Map<String, dynamic> json) =>
      _$OptimizerFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OptimizerResult {
  final List<Solution> solutions;

  OptimizerResult({required this.solutions});

  factory OptimizerResult.fromJson(Map<String, dynamic> json) =>
      _$OptimizerResultFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizerResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Solution {
  final String profile;
  @JsonKey(name: 'total_cost_eur')
  final double totalCostEur;
  @JsonKey(name: 'purchase_plan')
  final List<IngredientPurchasePlan> purchasePlan;

  Solution({
    required this.profile,
    required this.totalCostEur,
    required this.purchasePlan,
  });

  factory Solution.fromJson(Map<String, dynamic> json) =>
      _$SolutionFromJson(json);
  Map<String, dynamic> toJson() => _$SolutionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class IngredientPurchasePlan {
  @JsonKey(name: 'ingredient_ids')
  final List<String> ingredientIds;
  final Quantity? requested;
  final Quantity? fulfilled;
  @JsonKey(name: 'packs', defaultValue: [])
  final List<Pack> packs;

  IngredientPurchasePlan({
    required this.ingredientIds,
    this.requested,
    this.fulfilled,
    required this.packs,
  });

  factory IngredientPurchasePlan.fromJson(Map<String, dynamic> json) =>
      _$IngredientPurchasePlanFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientPurchasePlanToJson(this);

  double get totalCostEur =>
      packs.fold(0, (sum, pack) => sum + (pack.ingredientCostEur ?? 0));

  String? get productTitle =>
      packs.isNotEmpty ? packs.first.metadata?.title : null;

  int get totalPackCount =>
      packs.fold(0, (sum, pack) => sum + (pack.count ?? 0));
}

@JsonSerializable()
class Quantity {
  final double? amount;
  final String? unit;

  Quantity({this.amount, this.unit});

  factory Quantity.fromJson(Map<String, dynamic> json) =>
      _$QuantityFromJson(json);
  Map<String, dynamic> toJson() => _$QuantityToJson(this);
}

@JsonSerializable()
class Pack {
  @JsonKey(name: 'ingredient_cost_eur')
  final double? ingredientCostEur;
  final PackMetadata? metadata;
  @JsonKey(name: 'packs')
  final int? count;

  Pack({this.ingredientCostEur, this.metadata, this.count});

  factory Pack.fromJson(Map<String, dynamic> json) => _$PackFromJson(json);
  Map<String, dynamic> toJson() => _$PackToJson(this);
}

@JsonSerializable()
class PackMetadata {
  final String? title;

  PackMetadata({this.title});

  factory PackMetadata.fromJson(Map<String, dynamic> json) =>
      _$PackMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$PackMetadataToJson(this);
}
