// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessResponse _$ProcessResponseFromJson(Map<String, dynamic> json) =>
    ProcessResponse(
      jobId: json['job_id'] as String,
      schemaVersion: json['schema_version'] as String,
      generatedAt: _dateTimeFromJson(json['generated_at'] as String?),
      recipe: ApiRecipe.fromJson(json['recipe'] as Map<String, dynamic>),
      error: json['error'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProcessResponseToJson(ProcessResponse instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'schema_version': instance.schemaVersion,
      'generated_at': _dateTimeToJson(instance.generatedAt),
      'recipe': instance.recipe.toJson(),
      'error': instance.error,
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
      ingredientId: json['ingredient_id'] as String,
      name: json['name'] as String,
      foundationId: json['foundation_id'] as String?,
      foundationName: json['foundation_name'] as String?,
      originalQuantity: json['original_quantity'] == null
          ? null
          : ApiQuantity.fromJson(
              json['original_quantity'] as Map<String, dynamic>,
            ),
      normalizedQuantity: json['normalized_quantity'] == null
          ? null
          : ApiQuantity.fromJson(
              json['normalized_quantity'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ApiIngredientToJson(ApiIngredient instance) =>
    <String, dynamic>{
      'ingredient_id': instance.ingredientId,
      'name': instance.name,
      'foundation_id': instance.foundationId,
      'foundation_name': instance.foundationName,
      'original_quantity': instance.originalQuantity?.toJson(),
      'normalized_quantity': instance.normalizedQuantity?.toJson(),
    };

ApiQuantity _$ApiQuantityFromJson(Map<String, dynamic> json) => ApiQuantity(
  amount: _doubleFromJson(json['amount']),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$ApiQuantityToJson(ApiQuantity instance) =>
    <String, dynamic>{
      'amount': _doubleToJson(instance.amount),
      'unit': instance.unit,
    };
