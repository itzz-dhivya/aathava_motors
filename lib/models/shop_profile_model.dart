class ShopProfileModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String gstin;
  final String address;
  final String state;
  final String upiId;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String termsAndConditions;
  final String? logoPath;

  ShopProfileModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.gstin,
    required this.address,
    required this.state,
    this.upiId = '',
    this.invoicePrefix = 'INV-2026',
    this.nextInvoiceNumber = 1001,
    this.termsAndConditions = '1. Goods once sold will be accepted for return within 7 days in original condition.\n2. Electrical goods carry manufacturer warranty only.\n3. Subject to local jurisdiction.',
    this.logoPath,
  });

  ShopProfileModel copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? gstin,
    String? address,
    String? state,
    String? upiId,
    String? invoicePrefix,
    int? nextInvoiceNumber,
    String? termsAndConditions,
    String? logoPath,
  }) {
    return ShopProfileModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      state: state ?? this.state,
      upiId: upiId ?? this.upiId,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'gstin': gstin,
      'address': address,
      'state': state,
      'upiId': upiId,
      'invoicePrefix': invoicePrefix,
      'nextInvoiceNumber': nextInvoiceNumber,
      'termsAndConditions': termsAndConditions,
      'logoPath': logoPath,
    };
  }

  factory ShopProfileModel.fromMap(Map<String, dynamic> map) {
    return ShopProfileModel(
      id: map['id'] as String? ?? 'default_shop',
      shopName: map['shopName'] as String? ?? 'AutoZone Spare Parts & Accessories',
      ownerName: map['ownerName'] as String? ?? 'R. Rajesh',
      phone: map['phone'] as String? ?? '+91 98765 43210',
      email: map['email'] as String? ?? 'sales@autozonespares.com',
      gstin: map['gstin'] as String? ?? '33AABCA1234F1Z8',
      address: map['address'] as String? ?? '42/A, Mount Road, Automobile Hub, Guindy',
      state: map['state'] as String? ?? 'Tamil Nadu',
      upiId: map['upiId'] as String? ?? 'autozonespares@okaxis',
      invoicePrefix: map['invoicePrefix'] as String? ?? 'INV-2026',
      nextInvoiceNumber: map['nextInvoiceNumber'] as int? ?? 1001,
      termsAndConditions: map['termsAndConditions'] as String? ??
          '1. Goods once sold will be accepted for return within 7 days in original condition.\n2. Electrical goods carry manufacturer warranty only.\n3. Subject to local jurisdiction.',
      logoPath: map['logoPath'] as String?,
    );
  }
}
