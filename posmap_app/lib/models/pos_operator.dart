class PosOperator {
  final int? id;
  final String operatorName;
  final String shopName;
  final double latitude;
  final double longitude;
  final String locationLandmark;
  final String operatingSpace;
  final String numTerminals;
  final String banksServiced;
  final String phoneNumber;
  final String? whatsappNumber;
  final String tier;
  final String? selfieImage;
  final String? businessSignageImage;
  final String? idDocumentImage;
  final String? operatorSignature;
  final String? agentSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  PosOperator({
    this.id,
    required this.operatorName,
    required this.shopName,
    required this.latitude,
    required this.longitude,
    required this.locationLandmark,
    required this.operatingSpace,
    required this.numTerminals,
    required this.banksServiced,
    required this.phoneNumber,
    this.whatsappNumber,
    required this.tier,
    this.selfieImage,
    this.businessSignageImage,
    this.idDocumentImage,
    this.operatorSignature,
    this.agentSignature,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to JSON for database insertion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator_name': operatorName,
      'shop_name': shopName,
      'latitude': latitude,
      'longitude': longitude,
      'location_landmark': locationLandmark,
      'operating_space': operatingSpace,
      'num_terminals': numTerminals,
      'banks_serviced': banksServiced,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'tier': tier,
      'selfie_image': selfieImage,
      'business_signage_image': businessSignageImage,
      'id_document_image': idDocumentImage,
      'operator_signature': operatorSignature,
      'agent_signature': agentSignature,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PosOperator.fromJson(Map<String, dynamic> json) {
    return PosOperator(
      id: json['id'],
      operatorName: json['operator_name'] ?? '',
      shopName: json['shop_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationLandmark: json['location_landmark'] ?? '',
      operatingSpace: json['operating_space'] ?? '',
      numTerminals: json['num_terminals'] ?? '',
      banksServiced: json['banks_serviced'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      whatsappNumber: json['whatsapp_number'],
      tier: json['tier'] ?? '',
      selfieImage: json['selfie_image'],
      businessSignageImage: json['business_signage_image'],
      idDocumentImage: json['id_document_image'],
      operatorSignature: json['operator_signature'],
      agentSignature: json['agent_signature'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for updates
  PosOperator copyWith({
    int? id,
    String? operatorName,
    String? shopName,
    double? latitude,
    double? longitude,
    String? locationLandmark,
    String? operatingSpace,
    String? numTerminals,
    String? banksServiced,
    String? phoneNumber,
    String? whatsappNumber,
    String? tier,
    String? selfieImage,
    String? businessSignageImage,
    String? idDocumentImage,
    String? operatorSignature,
    String? agentSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PosOperator(
      id: id ?? this.id,
      operatorName: operatorName ?? this.operatorName,
      shopName: shopName ?? this.shopName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLandmark: locationLandmark ?? this.locationLandmark,
      operatingSpace: operatingSpace ?? this.operatingSpace,
      numTerminals: numTerminals ?? this.numTerminals,
      banksServiced: banksServiced ?? this.banksServiced,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      tier: tier ?? this.tier,
      selfieImage: selfieImage ?? this.selfieImage,
      businessSignageImage: businessSignageImage ?? this.businessSignageImage,
      idDocumentImage: idDocumentImage ?? this.idDocumentImage,
      operatorSignature: operatorSignature ?? this.operatorSignature,
      agentSignature: agentSignature ?? this.agentSignature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}