import 'package:json_annotation/json_annotation.dart';

part 'process_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ProcessResponse {
  @JsonKey(name: 'job_id')
  final String jobId;
  @JsonKey(name: 'schema_version')
  final String schemaVersion;
  @JsonKey(
    name: 'generated_at',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime generatedAt;
  final ApiRecipe recipe;
  final Map<String, dynamic>? error;

  const ProcessResponse({
    required this.jobId,
    required this.schemaVersion,
    required this.generatedAt,
    required this.recipe,
    this.error,
  });

  factory ProcessResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ApiRecipe {
  final String title;
  final int servings;
  final List<ApiIngredient> ingredients;

  const ApiRecipe({
    required this.title,
    required this.servings,
    required this.ingredients,
  });

  factory ApiRecipe.fromJson(Map<String, dynamic> json) =>
      _$ApiRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRecipeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ApiIngredient {
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  final String name;
  @JsonKey(name: 'foundation_id')
  final String? foundationId;
  @JsonKey(name: 'foundation_name')
  final String? foundationName;
  @JsonKey(name: 'original_quantity')
  final ApiQuantity? originalQuantity;
  @JsonKey(name: 'normalized_quantity')
  final ApiQuantity? normalizedQuantity;

  const ApiIngredient({
    required this.ingredientId,
    required this.name,
    this.foundationId,
    this.foundationName,
    this.originalQuantity,
    this.normalizedQuantity,
  });

  factory ApiIngredient.fromJson(Map<String, dynamic> json) =>
      _$ApiIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$ApiIngredientToJson(this);
}

@JsonSerializable()
class ApiQuantity {
  @JsonKey(fromJson: _doubleFromJson, toJson: _doubleToJson)
  final double? amount;
  final String? unit;

  const ApiQuantity({
    this.amount,
    this.unit,
  });

  factory ApiQuantity.fromJson(Map<String, dynamic> json) =>
      _$ApiQuantityFromJson(json);

  Map<String, dynamic> toJson() => _$ApiQuantityToJson(this);
}

DateTime _dateTimeFromJson(String? value) => value == null
    ? DateTime.fromMillisecondsSinceEpoch(0)
    : DateTime.parse(value);

String? _dateTimeToJson(DateTime? value) => value?.toIso8601String();

double? _doubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Object? _doubleToJson(double? value) => value;
