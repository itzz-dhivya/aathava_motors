import 'dart:convert';

class InvoiceItemModel {
  final String id;
  final String partId;
  final String partName;
  final String partNumber;
  final String hsnCode;
  final String unit;
  final double price; // per unit
  final double quantity;
  final double gstRate;
  final double discount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalTax;
  final double totalAmount;
  final double returnedQuantity;

  InvoiceItemModel({
    required this.id,
    required this.partId,
    required this.partName,
    this.partNumber = '',
    this.hsnCode = '8708',
    this.unit = 'Pcs',
    required this.price,
    required this.quantity,
    this.gstRate = 18.0,
    this.discount = 0.0,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalTax,
    required this.totalAmount,
    this.returnedQuantity = 0.0,
  });

  bool get isFullyReturned => returnedQuantity >= quantity;

  InvoiceItemModel copyWith({
    String? id,
    String? partId,
    String? partName,
    String? partNumber,
    String? hsnCode,
    String? unit,
    double? price,
    double? quantity,
    double? gstRate,
    double? discount,
    double? taxableAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalTax,
    double? totalAmount,
    double? returnedQuantity,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      partName: partName ?? this.partName,
      partNumber: partNumber ?? this.partNumber,
      hsnCode: hsnCode ?? this.hsnCode,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      gstRate: gstRate ?? this.gstRate,
      discount: discount ?? this.discount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalTax: totalTax ?? this.totalTax,
      totalAmount: totalAmount ?? this.totalAmount,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partId': partId,
      'partName': partName,
      'partNumber': partNumber,
      'hsnCode': hsnCode,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'gstRate': gstRate,
      'discount': discount,
      'taxableAmount': taxableAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'totalTax': totalTax,
      'totalAmount': totalAmount,
      'returnedQuantity': returnedQuantity,
    };
  }

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      id: map['id'] as String,
      partId: map['partId'] as String,
      partName: map['partName'] as String,
      partNumber: map['partNumber'] as String? ?? '',
      hsnCode: map['hsnCode'] as String? ?? '8708',
      unit: map['unit'] as String? ?? 'Pcs',
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      gstRate: (map['gstRate'] as num?)?.toDouble() ?? 18.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (map['taxableAmount'] as num).toDouble(),
      cgstAmount: (map['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (map['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (map['igstAmount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      returnedQuantity: (map['returnedQuantity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleNumber;
  final String customerAddress;
  final String customerGstin;
  final String customerState;
  final DateTime date;
  final List<InvoiceItemModel> items;
  final bool isGstInclusive;
  final bool isInterState;
  final double subtotalTaxable;
  final double cgstTotal;
  final double sgstTotal;
  final double igstTotal;
  final double totalTax;
  final double discountTotal;
  final double roundOff;
  final double grandTotal;
  final String paymentMode; // 'Cash', 'UPI', 'Card', 'Credit'
  final double paidAmount;
  final double balanceDue;
  final String status; // 'Completed', 'Returned', 'Cancelled'
  final String notes;
  final String createdBy;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName = 'Walk-in Customer',
    this.customerPhone = '',
    this.vehicleNumber = '',
    this.customerAddress = '',
    this.customerGstin = '',
    this.customerState = 'Tamil Nadu',
    required this.date,
    required this.items,
    this.isGstInclusive = true,
    this.isInterState = false,
    required this.subtotalTaxable,
    required this.cgstTotal,
    required this.sgstTotal,
    required this.igstTotal,
    required this.totalTax,
    this.discountTotal = 0.0,
    this.roundOff = 0.0,
    required this.grandTotal,
    this.paymentMode = 'Cash',
    required this.paidAmount,
    this.balanceDue = 0.0,
    this.status = 'Completed',
    this.notes = '',
    this.createdBy = 'Owner',
  });

  bool get isPaidFull => balanceDue <= 0.01;
  bool get isB2B => customerGstin.trim().isNotEmpty;
  bool get isCancelled => status == 'Cancelled';
  bool get isReturned => status == 'Returned';

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? vehicleNumber,
    String? customerAddress,
    String? customerGstin,
    String? customerState,
    DateTime? date,
    List<InvoiceItemModel>? items,
    bool? isGstInclusive,
    bool? isInterState,
    double? subtotalTaxable,
    double? cgstTotal,
    double? sgstTotal,
    double? igstTotal,
    double? totalTax,
    double? discountTotal,
    double? roundOff,
    double? grandTotal,
    String? paymentMode,
    double? paidAmount,
    double? balanceDue,
    String? status,
    String? notes,
    String? createdBy,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGstin: customerGstin ?? this.customerGstin,
      customerState: customerState ?? this.customerState,
      date: date ?? this.date,
      items: items ?? this.items,
      isGstInclusive: isGstInclusive ?? this.isGstInclusive,
      isInterState: isInterState ?? this.isInterState,
      subtotalTaxable: subtotalTaxable ?? this.subtotalTaxable,
      cgstTotal: cgstTotal ?? this.cgstTotal,
      sgstTotal: sgstTotal ?? this.sgstTotal,
      igstTotal: igstTotal ?? this.igstTotal,
      totalTax: totalTax ?? this.totalTax,
      discountTotal: discountTotal ?? this.discountTotal,
      roundOff: roundOff ?? this.roundOff,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMode: paymentMode ?? this.paymentMode,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehicleNumber': vehicleNumber,
      'customerAddress': customerAddress,
      'customerGstin': customerGstin,
      'customerState': customerState,
      'date': date.toIso8601String(),
      'itemsJson': jsonEncode(items.map((i) => i.toMap()).toList()),
      'isGstInclusive': isGstInclusive ? 1 : 0,
      'isInterState': isInterState ? 1 : 0,
      'subtotalTaxable': subtotalTaxable,
      'cgstTotal': cgstTotal,
      'sgstTotal': sgstTotal,
      'igstTotal': igstTotal,
      'totalTax': totalTax,
      'discountTotal': discountTotal,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'paymentMode': paymentMode,
      'paidAmount': paidAmount,
      'balanceDue': balanceDue,
      'status': status,
      'notes': notes,
      'createdBy': createdBy,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    List<InvoiceItemModel> parsedItems = [];
    if (map['itemsJson'] != null) {
      try {
        final decoded = jsonDecode(map['itemsJson'] as String) as List<dynamic>;
        parsedItems = decoded
            .map((item) => InvoiceItemModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return InvoiceModel(
      id: map['id'] as String,
      invoiceNumber: map['invoiceNumber'] as String,
      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String? ?? 'Walk-in Customer',
      customerPhone: map['customerPhone'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      customerAddress: map['customerAddress'] as String? ?? '',
      customerGstin: map['customerGstin'] as String? ?? '',
      customerState: map['customerState'] as String? ?? 'Tamil Nadu',
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      items: parsedItems,
      isGstInclusive: (map['isGstInclusive'] is int)
          ? map['isGstInclusive'] == 1
          : (map['isGstInclusive'] as bool? ?? true),
      isInterState: (map['isInterState'] is int)
          ? map['isInterState'] == 1
          : (map['isInterState'] as bool? ?? false),
      subtotalTaxable: (map['subtotalTaxable'] as num?)?.toDouble() ?? 0.0,
      cgstTotal: (map['cgstTotal'] as num?)?.toDouble() ?? 0.0,
      sgstTotal: (map['sgstTotal'] as num?)?.toDouble() ?? 0.0,
      igstTotal: (map['igstTotal'] as num?)?.toDouble() ?? 0.0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (map['discountTotal'] as num?)?.toDouble() ?? 0.0,
      roundOff: (map['roundOff'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMode: map['paymentMode'] as String? ?? 'Cash',
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (map['balanceDue'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Completed',
      notes: map['notes'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? 'Owner',
    );
  }
}
