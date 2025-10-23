import 'package:json_annotation/json_annotation.dart';

part 'optimizer_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ApiOptimizerResponse {
  @JsonKey(name: 'job_id')
  final String jobId;
  @JsonKey(name: 'schema_version')
  final String schemaVersion;
  @JsonKey(
    name: 'completed_at',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime completedAt;
  final ApiOptimizerResult? result;
  final Map<String, dynamic>? error;

  const ApiOptimizerResponse({
    required this.jobId,
    required this.schemaVersion,
    required this.completedAt,
    this.result,
    this.error,
  });

  factory ApiOptimizerResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerResponseToJson(this);

  List<ApiOptimizerSolution> get solutions => result?.solutions ?? const [];
}

@JsonSerializable(explicitToJson: true)
class ApiOptimizerResult {
  final List<ApiOptimizerSolution> solutions;

  const ApiOptimizerResult({required this.solutions});

  factory ApiOptimizerResult.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerResultFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ApiOptimizerSolution {
  final String profile;
  @JsonKey(name: 'total_cost_eur')
  final double totalCostEur;
  @JsonKey(name: 'purchase_plan')
  final List<ApiOptimizerPurchasePlan> purchasePlan;

  const ApiOptimizerSolution({
    required this.profile,
    required this.totalCostEur,
    required this.purchasePlan,
  });

  factory ApiOptimizerSolution.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerSolutionFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerSolutionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ApiOptimizerPurchasePlan {
  @JsonKey(name: 'ingredient_ids')
  final List<String> ingredientIds;
  final ApiOptimizerQuantity? requested;
  final ApiOptimizerQuantity? fulfilled;
  final String? status;
  final ApiOptimizerQuantity? leftover;
  @JsonKey(defaultValue: [])
  final List<ApiOptimizerPack> packs;

  const ApiOptimizerPurchasePlan({
    required this.ingredientIds,
    this.requested,
    this.fulfilled,
    this.status,
    this.leftover,
    required this.packs,
  });

  factory ApiOptimizerPurchasePlan.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerPurchasePlanFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerPurchasePlanToJson(this);

  double get totalCostEur =>
      packs.fold(0, (sum, pack) => sum + (pack.ingredientCostEur ?? 0));

  int get totalPackCount =>
      packs.fold(0, (sum, pack) => sum + (pack.packCount ?? 0));
}

@JsonSerializable()
class ApiOptimizerQuantity {
  @JsonKey(fromJson: _nullableDoubleFromJson, toJson: _nullableDoubleToJson)
  final double? amount;
  final String? unit;

  const ApiOptimizerQuantity({this.amount, this.unit});

  factory ApiOptimizerQuantity.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerQuantityFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerQuantityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ApiOptimizerPack {
  @JsonKey(name: 'sku_id')
  final String? skuId;
  @JsonKey(name: 'pack_count')
  final int? packCount;
  @JsonKey(name: 'pack_size')
  final ApiOptimizerQuantity? packSize;
  @JsonKey(name: 'ingredient_cost_eur')
  final double? ingredientCostEur;

  const ApiOptimizerPack({
    this.skuId,
    this.packCount,
    this.packSize,
    this.ingredientCostEur,
  });

  factory ApiOptimizerPack.fromJson(Map<String, dynamic> json) =>
      _$ApiOptimizerPackFromJson(json);

  Map<String, dynamic> toJson() => _$ApiOptimizerPackToJson(this);
}

DateTime _dateTimeFromJson(String? value) =>
    value == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse(value);

String? _dateTimeToJson(DateTime? value) => value?.toUtc().toIso8601String();

double? _nullableDoubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Object? _nullableDoubleToJson(double? value) => value;
