import 'package:hive_flutter/adapters.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String role; // 'agent' or 'supervisor'

  @HiveField(4)
  String? assignedLga;

  @HiveField(5)
  String? assignedTown;

  @HiveField(6)
  String? assignedWard;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isActive;

  User({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.role,
    this.assignedLga,
    this.assignedTown,
    this.assignedWard,
    required this.createdAt,
    this.isActive = true,
  });
}