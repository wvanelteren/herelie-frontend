// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessResponse _$ProcessResponseFromJson(Map<String, dynamic> json) =>
    ProcessResponse(
      jobId: json['job_id'] as String,
      recipe: ApiRecipe.fromJson(json['recipe'] as Map<String, dynamic>),
      optimizer: Optimizer.fromJson(json['optimizer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProcessResponseToJson(ProcessResponse instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'recipe': instance.recipe.toJson(),
      'optimizer': instance.optimizer.toJson(),
    };

ApiRecipe _$ApiRecipeFromJson(Map<String, dynamic> json) => ApiRecipe(
  title: json['title'] as String,
  servings: (json['servings'] as num).toInt(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => ApiIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ApiRecipeToJson(ApiRecipe instance) => <String, dynamic>{
  'title': instance.title,
  'servings': instance.servings,
  'ingredients': instance.ingredients,
};

ApiIngredient _$ApiIngredientFromJson(Map<String, dynamic> json) =>
    ApiIngredient(
      original: json['original'] == null
          ? null
          : OriginalIngredient.fromJson(
              json['original'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ApiIngredientToJson(ApiIngredient instance) =>
    <String, dynamic>{'original': instance.original};

OriginalIngredient _$OriginalIngredientFromJson(Map<String, dynamic> json) =>
    OriginalIngredient(
      name: json['name'] as String,
      unit: json['unit'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OriginalIngredientToJson(OriginalIngredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unit': instance.unit,
      'amount': instance.amount,
    };

Optimizer _$OptimizerFromJson(Map<String, dynamic> json) => Optimizer(
  jobId: json['job_id'] as String,
  schemaVersion: json['schema_version'] as String,
  solutions: (json['solutions'] as List<dynamic>)
      .map((e) => Solution.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OptimizerToJson(Optimizer instance) => <String, dynamic>{
  'job_id': instance.jobId,
  'schema_version': instance.schemaVersion,
  'solutions': instance.solutions.map((e) => e.toJson()).toList(),
};

Solution _$SolutionFromJson(Map<String, dynamic> json) => Solution(
  profile: json['profile'] as String,
  totalCostEur: (json['total_cost_eur'] as num).toDouble(),
  lineItems: (json['line_items'] as List<dynamic>)
      .map((e) => LineItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SolutionToJson(Solution instance) => <String, dynamic>{
  'profile': instance.profile,
  'total_cost_eur': instance.totalCostEur,
  'line_items': instance.lineItems.map((e) => e.toJson()).toList(),
};

LineItemModel _$LineItemModelFromJson(Map<String, dynamic> json) =>
    LineItemModel(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      total: json['total'] == null
          ? null
          : PackOrTotal.fromJson(json['total'] as Map<String, dynamic>),
      prices: Prices.fromJson(json['prices'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LineItemModelToJson(LineItemModel instance) =>
    <String, dynamic>{
      'product': instance.product.toJson(),
      'total': instance.total?.toJson(),
      'prices': instance.prices.toJson(),
    };

Product _$ProductFromJson(Map<String, dynamic> json) =>
    Product(title: json['title'] as String);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'title': instance.title,
};

PackOrTotal _$PackOrTotalFromJson(Map<String, dynamic> json) => PackOrTotal(
  amount: (json['amount'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$PackOrTotalToJson(PackOrTotal instance) =>
    <String, dynamic>{'amount': instance.amount, 'unit': instance.unit};

Prices _$PricesFromJson(Map<String, dynamic> json) =>
    Prices(lineEur: (json['line_eur'] as num).toDouble());

Map<String, dynamic> _$PricesToJson(Prices instance) => <String, dynamic>{
  'line_eur': instance.lineEur,
};
