// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimizer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiOptimizerResponse _$ApiOptimizerResponseFromJson(
  Map<String, dynamic> json,
) => ApiOptimizerResponse(
  jobId: json['job_id'] as String,
  schemaVersion: json['schema_version'] as String,
  completedAt: _dateTimeFromJson(json['completed_at'] as String?),
  result: json['result'] == null
      ? null
      : ApiOptimizerResult.fromJson(json['result'] as Map<String, dynamic>),
  error: json['error'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiOptimizerResponseToJson(
  ApiOptimizerResponse instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'schema_version': instance.schemaVersion,
  'completed_at': _dateTimeToJson(instance.completedAt),
  'result': instance.result?.toJson(),
  'error': instance.error,
};

ApiOptimizerResult _$ApiOptimizerResultFromJson(Map<String, dynamic> json) =>
    ApiOptimizerResult(
      solutions: (json['solutions'] as List<dynamic>)
          .map((e) => ApiOptimizerSolution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiOptimizerResultToJson(ApiOptimizerResult instance) =>
    <String, dynamic>{
      'solutions': instance.solutions.map((e) => e.toJson()).toList(),
    };

ApiOptimizerSolution _$ApiOptimizerSolutionFromJson(
  Map<String, dynamic> json,
) => ApiOptimizerSolution(
  profile: json['profile'] as String,
  totalCostEur: (json['total_cost_eur'] as num).toDouble(),
  purchasePlan: (json['purchase_plan'] as List<dynamic>)
      .map((e) => ApiOptimizerPurchasePlan.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ApiOptimizerSolutionToJson(
  ApiOptimizerSolution instance,
) => <String, dynamic>{
  'profile': instance.profile,
  'total_cost_eur': instance.totalCostEur,
  'purchase_plan': instance.purchasePlan.map((e) => e.toJson()).toList(),
};

ApiOptimizerPurchasePlan _$ApiOptimizerPurchasePlanFromJson(
  Map<String, dynamic> json,
) => ApiOptimizerPurchasePlan(
  ingredientIds: (json['ingredient_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requested: json['requested'] == null
      ? null
      : ApiOptimizerQuantity.fromJson(
          json['requested'] as Map<String, dynamic>,
        ),
  fulfilled: json['fulfilled'] == null
      ? null
      : ApiOptimizerQuantity.fromJson(
          json['fulfilled'] as Map<String, dynamic>,
        ),
  status: json['status'] as String?,
  leftover: json['leftover'] == null
      ? null
      : ApiOptimizerQuantity.fromJson(json['leftover'] as Map<String, dynamic>),
  packs:
      (json['packs'] as List<dynamic>?)
          ?.map((e) => ApiOptimizerPack.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ApiOptimizerPurchasePlanToJson(
  ApiOptimizerPurchasePlan instance,
) => <String, dynamic>{
  'ingredient_ids': instance.ingredientIds,
  'requested': instance.requested?.toJson(),
  'fulfilled': instance.fulfilled?.toJson(),
  'status': instance.status,
  'leftover': instance.leftover?.toJson(),
  'packs': instance.packs.map((e) => e.toJson()).toList(),
};

ApiOptimizerQuantity _$ApiOptimizerQuantityFromJson(
  Map<String, dynamic> json,
) => ApiOptimizerQuantity(
  amount: _nullableDoubleFromJson(json['amount']),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$ApiOptimizerQuantityToJson(
  ApiOptimizerQuantity instance,
) => <String, dynamic>{
  'amount': _nullableDoubleToJson(instance.amount),
  'unit': instance.unit,
};

ApiOptimizerPack _$ApiOptimizerPackFromJson(Map<String, dynamic> json) =>
    ApiOptimizerPack(
      skuId: json['sku_id'] as String?,
      packCount: (json['pack_count'] as num?)?.toInt(),
      packSize: json['pack_size'] == null
          ? null
          : ApiOptimizerQuantity.fromJson(
              json['pack_size'] as Map<String, dynamic>,
            ),
      ingredientCostEur: (json['ingredient_cost_eur'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ApiOptimizerPackToJson(ApiOptimizerPack instance) =>
    <String, dynamic>{
      'sku_id': instance.skuId,
      'pack_count': instance.packCount,
      'pack_size': instance.packSize?.toJson(),
      'ingredient_cost_eur': instance.ingredientCostEur,
    };
