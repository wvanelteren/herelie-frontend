import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/line_item.dart';
import '../../../domain/entities/recipe.dart';

part 'process_response.g.dart';

// ======= Top-level =======

@JsonSerializable(explicitToJson: true)
class ProcessResponse {
  @JsonKey(name: 'job_id')
  final String jobId;
  final ApiRecipe recipe;
  final Optimizer optimizer;

  ProcessResponse({required this.jobId, required this.recipe, required this.optimizer});

  factory ProcessResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessResponseToJson(this);

  Recipe toEntity() {
    final solution = optimizer.solutions.isNotEmpty ? optimizer.solutions.first : null;
    final total = solution?.totalCostEur ?? 0.0;

    final ingredients = recipe.ingredients
        .map((e) => e.original != null
            ? Ingredient(
                name: e.original!.name,
                amount: e.original!.amount,
                unit: e.original!.unit,
              )
            : null)
        .whereType<Ingredient>()
        .toList();

    final lineItems = (solution?.lineItems ?? [])
        .map((li) => LineItem(
              title: li.product.title,
              amount: li.total?.amount,
              unit: li.total?.unit,
              lineCostEur: li.prices.lineEur,
            ))
        .toList();

    return Recipe(
      id: jobId,
      title: recipe.title,
      servings: recipe.servings,
      totalCostEur: total,
      ingredients: ingredients,
      lineItems: lineItems,
      createdAt: DateTime.now(),
    );
  }
}

// ======= Nested: recipe =======

@JsonSerializable()
class ApiRecipe {
  final String title;
  final int servings;
  final List<ApiIngredient> ingredients;

  ApiRecipe({required this.title, required this.servings, required this.ingredients});

  factory ApiRecipe.fromJson(Map<String, dynamic> json) => _$ApiRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$ApiRecipeToJson(this);
}

@JsonSerializable()
class ApiIngredient {
  final OriginalIngredient? original;

  ApiIngredient({required this.original});

  factory ApiIngredient.fromJson(Map<String, dynamic> json) =>
      _$ApiIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$ApiIngredientToJson(this);
}

@JsonSerializable()
class OriginalIngredient {
  final String name;
  final String? unit;
  final double? amount;

  OriginalIngredient({required this.name, this.unit, this.amount});

  factory OriginalIngredient.fromJson(Map<String, dynamic> json) =>
      _$OriginalIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$OriginalIngredientToJson(this);
}

// ======= Nested: optimizer / solutions =======

@JsonSerializable(explicitToJson: true)
class Optimizer {
  @JsonKey(name: 'job_id')
  final String jobId;
  @JsonKey(name: 'schema_version')
  final String schemaVersion;
  @JsonKey(name: 'solutions')
  final List<Solution> solutions;

  Optimizer({
    required this.jobId,
    required this.schemaVersion,
    required this.solutions,
  });

  factory Optimizer.fromJson(Map<String, dynamic> json) => _$OptimizerFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Solution {
  @JsonKey(name: 'profile')
  final String profile;
  @JsonKey(name: 'total_cost_eur')
  final double totalCostEur;
  @JsonKey(name: 'line_items')
  final List<LineItemModel> lineItems;

  Solution({
    required this.profile,
    required this.totalCostEur,
    required this.lineItems,
  });

  factory Solution.fromJson(Map<String, dynamic> json) => _$SolutionFromJson(json);
  Map<String, dynamic> toJson() => _$SolutionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LineItemModel {
  final Product product;
  final PackOrTotal? total;
  final Prices prices;

  // (we negeren 'packs' en 'pack_size' voor nu)
  LineItemModel({required this.product, required this.total, required this.prices});

  factory LineItemModel.fromJson(Map<String, dynamic> json) =>
      _$LineItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$LineItemModelToJson(this);
}

@JsonSerializable()
class Product {
  final String title;
  Product({required this.title});

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class PackOrTotal {
  final double? amount;
  final String? unit;

  PackOrTotal({this.amount, this.unit});

  factory PackOrTotal.fromJson(Map<String, dynamic> json) =>
      _$PackOrTotalFromJson(json);
  Map<String, dynamic> toJson() => _$PackOrTotalToJson(this);
}

@JsonSerializable()
class Prices {
  @JsonKey(name: 'line_eur')
  final double lineEur;

  Prices({required this.lineEur});

  factory Prices.fromJson(Map<String, dynamic> json) => _$PricesFromJson(json);
  Map<String, dynamic> toJson() => _$PricesToJson(this);
}