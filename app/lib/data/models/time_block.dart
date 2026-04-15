class TimeBlock {
  final String id;
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"
  final String description;

  /// For actual blocks: which plan block ID this came from (null = free-add)
  final String? sourcePlanId;

  const TimeBlock({
    required this.id,
    this.startTime = '',
    this.endTime = '',
    this.description = '',
    this.sourcePlanId,
  });

  bool get hasSource => sourcePlanId != null && sourcePlanId!.isNotEmpty;

  TimeBlock copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? description,
    String? sourcePlanId,
    bool clearSource = false,
  }) =>
      TimeBlock(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        description: description ?? this.description,
        sourcePlanId: clearSource ? null : (sourcePlanId ?? this.sourcePlanId),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'description': description,
        'sourcePlanId': sourcePlanId,
      };

  factory TimeBlock.fromJson(Map<String, dynamic> json) => TimeBlock(
        id: (json['id'] as String?) ?? '',
        startTime: (json['startTime'] as String?) ?? '',
        endTime: (json['endTime'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        sourcePlanId: json['sourcePlanId'] as String?,
      );
}
