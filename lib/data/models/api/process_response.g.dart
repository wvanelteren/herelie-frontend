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
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
};

ApiIngredient _$ApiIngredientFromJson(Map<String, dynamic> json) =>
    ApiIngredient(
      ingredientId: json['ingredient_id'] as String?,
      parsedIngredient: json['parsed_ingredient'] == null
          ? null
          : IngredientDetails.fromJson(
              json['parsed_ingredient'] as Map<String, dynamic>,
            ),
      original: json['original'] == null
          ? null
          : IngredientDetails.fromJson(
              json['original'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ApiIngredientToJson(ApiIngredient instance) =>
    <String, dynamic>{
      'ingredient_id': instance.ingredientId,
      'parsed_ingredient': instance.parsedIngredient,
      'original': instance.original,
    };

IngredientDetails _$IngredientDetailsFromJson(Map<String, dynamic> json) =>
    IngredientDetails(
      name: json['name'] as String,
      unit: json['unit'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$IngredientDetailsToJson(IngredientDetails instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unit': instance.unit,
      'amount': instance.amount,
    };

Optimizer _$OptimizerFromJson(Map<String, dynamic> json) => Optimizer(
  jobId: json['job_id'] as String,
  schemaVersion: json['schema_version'] as String,
  result: json['result'] == null
      ? null
      : OptimizerResult.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OptimizerToJson(Optimizer instance) => <String, dynamic>{
  'job_id': instance.jobId,
  'schema_version': instance.schemaVersion,
  'result': instance.result?.toJson(),
};

OptimizerResult _$OptimizerResultFromJson(Map<String, dynamic> json) =>
    OptimizerResult(
      solutions: (json['solutions'] as List<dynamic>)
          .map((e) => Solution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OptimizerResultToJson(OptimizerResult instance) =>
    <String, dynamic>{
      'solutions': instance.solutions.map((e) => e.toJson()).toList(),
    };

Solution _$SolutionFromJson(Map<String, dynamic> json) => Solution(
  profile: json['profile'] as String,
  totalCostEur: (json['total_cost_eur'] as num).toDouble(),
  purchasePlan: (json['purchase_plan'] as List<dynamic>)
      .map((e) => IngredientPurchasePlan.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SolutionToJson(Solution instance) => <String, dynamic>{
  'profile': instance.profile,
  'total_cost_eur': instance.totalCostEur,
  'purchase_plan': instance.purchasePlan.map((e) => e.toJson()).toList(),
};

IngredientPurchasePlan _$IngredientPurchasePlanFromJson(
  Map<String, dynamic> json,
) => IngredientPurchasePlan(
  ingredientIds: (json['ingredient_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requested: json['requested'] == null
      ? null
      : Quantity.fromJson(json['requested'] as Map<String, dynamic>),
  fulfilled: json['fulfilled'] == null
      ? null
      : Quantity.fromJson(json['fulfilled'] as Map<String, dynamic>),
  packs:
      (json['packs'] as List<dynamic>?)
          ?.map((e) => Pack.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$IngredientPurchasePlanToJson(
  IngredientPurchasePlan instance,
) => <String, dynamic>{
  'ingredient_ids': instance.ingredientIds,
  'requested': instance.requested?.toJson(),
  'fulfilled': instance.fulfilled?.toJson(),
  'packs': instance.packs.map((e) => e.toJson()).toList(),
};

Quantity _$QuantityFromJson(Map<String, dynamic> json) => Quantity(
  amount: (json['amount'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$QuantityToJson(Quantity instance) => <String, dynamic>{
  'amount': instance.amount,
  'unit': instance.unit,
};

Pack _$PackFromJson(Map<String, dynamic> json) => Pack(
  ingredientCostEur: (json['ingredient_cost_eur'] as num?)?.toDouble(),
  metadata: json['metadata'] == null
      ? null
      : PackMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  count: (json['packs'] as num?)?.toInt(),
);

Map<String, dynamic> _$PackToJson(Pack instance) => <String, dynamic>{
  'ingredient_cost_eur': instance.ingredientCostEur,
  'metadata': instance.metadata,
  'packs': instance.count,
};

PackMetadata _$PackMetadataFromJson(Map<String, dynamic> json) =>
    PackMetadata(title: json['title'] as String?);

Map<String, dynamic> _$PackMetadataToJson(PackMetadata instance) =>
    <String, dynamic>{'title': instance.title};
