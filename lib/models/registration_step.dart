import 'package:hive_flutter/adapters.dart';

part 'registration_step.g.dart';

@HiveType(typeId: 2)
class RegistrationStep extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String posOperatorId;

  @HiveField(2)
  int stepNumber; // 1-5

  @HiveField(3)
  Map<String, dynamic>? data; // Step-specific data

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  RegistrationStep({
    required this.id,
    required this.posOperatorId,
    required this.stepNumber,
    this.data,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
}