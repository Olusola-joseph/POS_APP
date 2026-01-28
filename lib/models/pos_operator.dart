import 'package:hive_flutter/adapters.dart';

part 'pos_operator.g.dart';

@HiveType(typeId: 1)
class PosOperator extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String shopName;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  String? address;

  @HiveField(5)
  String? landmark;

  @HiveField(6)
  String operatorName;

  @HiveField(7)
  String phoneNumber;

  @HiveField(8)
  String? whatsappNumber;

  @HiveField(9)
  String? bvn;

  @HiveField(10)
  String? nin;

  @HiveField(11)
  String? voterId;

  @HiveField(12)
  int? terminalsCount;

  @HiveField(13)
  List<String>? banks;

  @HiveField(14)
  String? tier;

  @HiveField(15)
  String lga;

  @HiveField(16)
  String town;

  @HiveField(17)
  String ward;

  @HiveField(18)
  String? street;

  @HiveField(19)
  String? spaceSize;

  @HiveField(20)
  String? photoUrl;

  @HiveField(21)
  String? signagePhotoUrl;

  @HiveField(22)
  String? idPhotoUrl;

  @HiveField(23)
  String? operatorSignature;

  @HiveField(24)
  String? agentSignature;

  @HiveField(25)
  String? verificationSlipUrl;

  @HiveField(26)
  String? qrCodeUrl;

  @HiveField(27)
  String registeredBy;

  @HiveField(28)
  DateTime createdAt;

  @HiveField(29)
  DateTime updatedAt;

  @HiveField(30)
  bool isVerified;

  @HiveField(31)
  bool needsCash;

  @HiveField(32)
  bool needsPaperRolls;

  @HiveField(33)
  String? referralCode;

  PosOperator({
    required this.id,
    required this.shopName,
    required this.latitude,
    required this.longitude,
    this.address,
    this.landmark,
    required this.operatorName,
    required this.phoneNumber,
    this.whatsappNumber,
    this.bvn,
    this.nin,
    this.voterId,
    this.terminalsCount,
    this.banks,
    this.tier,
    required this.lga,
    required this.town,
    required this.ward,
    this.street,
    this.spaceSize,
    this.photoUrl,
    this.signagePhotoUrl,
    this.idPhotoUrl,
    this.operatorSignature,
    this.agentSignature,
    this.verificationSlipUrl,
    this.qrCodeUrl,
    required this.registeredBy,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.needsCash = false,
    this.needsPaperRolls = false,
    this.referralCode,
  });
}