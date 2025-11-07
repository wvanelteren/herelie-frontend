import 'package:json_annotation/json_annotation.dart';

part 'optimizer_request.g.dart';

@JsonSerializable(explicitToJson: true)
class OptimizerRequest {
  @JsonKey(name: 'job_id')
  final String jobId;
  @JsonKey(name: 'initiated_at')
  final DateTime initiatedAt;
  final OptimizerRequestPayload request;

  const OptimizerRequest({
    required this.jobId,
    required this.initiatedAt,
    required this.request,
  });

  factory OptimizerRequest.fromJson(Map<String, dynamic> json) =>
      _$OptimizerRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizerRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OptimizerRequestPayload {
  final List<OptimizerDemand> demands;

  const OptimizerRequestPayload({required this.demands});

  factory OptimizerRequestPayload.fromJson(Map<String, dynamic> json) =>
      _$OptimizerRequestPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizerRequestPayloadToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OptimizerDemand {
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  @JsonKey(name: 'ingredient_name')
  final String ingredientName;
  @JsonKey(name: 'foundation_id')
  final String foundationId;
  final RequestedQuantity requested;

  const OptimizerDemand({
    required this.ingredientId,
    required this.ingredientName,
    required this.foundationId,
    required this.requested,
  });

  factory OptimizerDemand.fromJson(Map<String, dynamic> json) =>
      _$OptimizerDemandFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizerDemandToJson(this);
}

@JsonSerializable()
class RequestedQuantity {
  final double amount;
  final String unit;

  const RequestedQuantity({
    required this.amount,
    required this.unit,
  });

  factory RequestedQuantity.fromJson(Map<String, dynamic> json) =>
      _$RequestedQuantityFromJson(json);

  Map<String, dynamic> toJson() => _$RequestedQuantityToJson(this);
}
