// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimizer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptimizerRequest _$OptimizerRequestFromJson(Map<String, dynamic> json) =>
    OptimizerRequest(
      jobId: json['job_id'] as String,
      initiatedAt: DateTime.parse(json['initiated_at'] as String),
      request: OptimizerRequestPayload.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OptimizerRequestToJson(OptimizerRequest instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'initiated_at': instance.initiatedAt.toIso8601String(),
      'request': instance.request.toJson(),
    };

OptimizerRequestPayload _$OptimizerRequestPayloadFromJson(
  Map<String, dynamic> json,
) => OptimizerRequestPayload(
  demands: (json['demands'] as List<dynamic>)
      .map((e) => OptimizerDemand.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OptimizerRequestPayloadToJson(
  OptimizerRequestPayload instance,
) => <String, dynamic>{
  'demands': instance.demands.map((e) => e.toJson()).toList(),
};

OptimizerDemand _$OptimizerDemandFromJson(Map<String, dynamic> json) =>
    OptimizerDemand(
      ingredientId: json['ingredient_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      foundationId: json['foundation_id'] as String,
      requested: RequestedQuantity.fromJson(
        json['requested'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OptimizerDemandToJson(OptimizerDemand instance) =>
    <String, dynamic>{
      'ingredient_id': instance.ingredientId,
      'ingredient_name': instance.ingredientName,
      'foundation_id': instance.foundationId,
      'requested': instance.requested.toJson(),
    };

RequestedQuantity _$RequestedQuantityFromJson(Map<String, dynamic> json) =>
    RequestedQuantity(
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$RequestedQuantityToJson(RequestedQuantity instance) =>
    <String, dynamic>{'amount': instance.amount, 'unit': instance.unit};
