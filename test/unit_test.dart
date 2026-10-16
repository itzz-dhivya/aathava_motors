import 'package:flutter_test/flutter_test.dart';
import 'package:freelancing/core/utils/gst_calculator.dart';
import 'package:freelancing/core/localization/translations.dart';
import 'package:freelancing/models/part_model.dart';
import 'package:freelancing/models/invoice_model.dart';
import 'package:freelancing/models/customer_model.dart';

void main() {
  group('GST Calculator Tests', () {
    test('Intra-state GST exclusive calculation (CGST + SGST)', () {
      // 1 item @ ₹1000 with 18% GST exclusive, Intra-state
      final result = GstCalculator.calculateItem(
        price: 1000.0,
        quantity: 1.0,
        gstRate: 18.0,
        isGstInclusive: false,
        isInterState: false,
      );

      expect(result.itemTaxable, 1000.0);
      expect(result.itemTax, 180.0);
      expect(result.itemCgst, 90.0);
      expect(result.itemSgst, 90.0);
      expect(result.itemIgst, 0.0);
      expect(result.itemTotal, 1180.0);
    });

    test('Inter-state GST exclusive calculation (IGST)', () {
      // 2 items @ ₹500 with 18% GST exclusive, Inter-state
      final result = GstCalculator.calculateItem(
        price: 500.0,
        quantity: 2.0,
        gstRate: 18.0,
        isGstInclusive: false,
        isInterState: true,
      );

      expect(result.itemTaxable, 1000.0);
      expect(result.itemTax, 180.0);
      expect(result.itemCgst, 0.0);
      expect(result.itemSgst, 0.0);
      expect(result.itemIgst, 180.0);
      expect(result.itemTotal, 1180.0);
    });

    test('GST inclusive pricing calculation', () {
      // 1 item @ ₹1180 with 18% GST inclusive
      final result = GstCalculator.calculateItem(
        price: 1180.0,
        quantity: 1.0,
        gstRate: 18.0,
        isGstInclusive: true,
        isInterState: false,
      );

      expect(result.itemTaxable, 1000.0);
      expect(result.itemTax, 180.0);
      expect(result.itemCgst, 90.0);
      expect(result.itemSgst, 90.0);
      expect(result.itemTotal, 1180.0);
    });

    test('Item discount calculation', () {
      // ₹1000 with 10% discount = ₹900 taxable, 18% GST = ₹162 tax
      final result = GstCalculator.calculateItem(
        price: 1000.0,
        quantity: 1.0,
        gstRate: 18.0,
        isGstInclusive: false,
        isInterState: false,
        itemDiscountPercent: 10.0,
      );

      expect(result.itemTaxable, 900.0);
      expect(result.itemTax, 162.0);
      expect(result.itemCgst, 81.0);
      expect(result.itemSgst, 81.0);
      expect(result.itemTotal, 1062.0);
    });

    test('Inter-state detection logic', () {
      expect(GstCalculator.checkIsInterState('Tamil Nadu', 'Tamil Nadu'), isFalse);
      expect(GstCalculator.checkIsInterState('Tamil Nadu', 'tamil nadu'), isFalse);
      expect(GstCalculator.checkIsInterState('Tamil Nadu', 'Kerala'), isTrue);
      expect(GstCalculator.checkIsInterState('Tamil Nadu', ''), isFalse);
    });
  });

  group('Localization & Translations Tests', () {
    test('English translations exist for key terms', () {
      expect(AppTranslations.get('app_title', locale: 'en'), 'AutoSpare Pro');
      expect(AppTranslations.get('nav_inventory', locale: 'en'), 'Inventory');
      expect(AppTranslations.get('new_bill', locale: 'en'), 'Create GST Bill');
      expect(AppTranslations.get('nav_customers', locale: 'en'), 'Customers');
      expect(AppTranslations.get('nav_reports', locale: 'en'), 'Reports');
    });

    test('Tamil (தமிழ்) translations exist for key terms', () {
      expect(AppTranslations.get('app_title', locale: 'ta'), 'ஆட்டோஸ்பேர் புரோ');
      expect(AppTranslations.get('nav_inventory', locale: 'ta'), 'இருப்பு (பொருட்கள்)');
      expect(AppTranslations.get('new_bill', locale: 'ta'), 'ஜிஎஸ்டி பில் தயாரிப்பு');
      expect(AppTranslations.get('nav_customers', locale: 'ta'), 'வாடிக்கையாளர்கள்');
      expect(AppTranslations.get('nav_reports', locale: 'ta'), 'அறிக்கைகள்');
    });

    test('Fallback to English if key missing or invalid language', () {
      expect(AppTranslations.get('nav_inventory', locale: 'fr'), 'Inventory');
      expect(AppTranslations.get('non_existent_key_test', locale: 'en'), 'non_existent_key_test');
    });
  });

  group('Data Models Tests', () {
    test('PartModel serialization and low stock check', () {
      final part = PartModel(
        id: 'P001',
        name: 'Bosch Brake Pads',
        partNumber: 'BP-0912',
        brand: 'Bosch',
        hsnCode: '8708',
        purchasePrice: 650.0,
        sellingPrice: 1100.0,
        gstRate: 18.0,
        stockQuantity: 4.0,
        minStockAlert: 5.0,
        unit: 'Set',
        category: 'Brakes',
        barcode: '8901234567890',
        createdAt: DateTime.now(),
      );

      expect(part.isLowStock, isTrue);
      expect(part.isOutOfStock, isFalse);

      final map = part.toMap();
      final fromMap = PartModel.fromMap(map);
      expect(fromMap.id, part.id);
      expect(fromMap.name, part.name);
      expect(fromMap.sellingPrice, 1100.0);
    });

    test('CustomerModel pending dues check', () {
      final customer = CustomerModel(
        id: 'C001',
        name: 'Muthu Kumar',
        phone: '9876543210',
        vehicleNumber: 'TN-01-AB-1234',
        address: '12 Anna Salai, Chennai',
        state: 'Tamil Nadu',
        pendingBalance: 1500.0,
        createdAt: DateTime.now(),
      );

      expect(customer.hasDues, isTrue);
      final map = customer.toMap();
      final fromMap = CustomerModel.fromMap(map);
      expect(fromMap.pendingBalance, 1500.0);
      expect(fromMap.vehicleNumber, 'TN-01-AB-1234');
    });

    test('InvoiceModel and InvoiceItemModel calculation integrity', () {
      final item = InvoiceItemModel(
        id: 'item-1',
        partId: 'P001',
        partName: 'Bosch Brake Pads',
        partNumber: 'BP-0912',
        hsnCode: '8708',
        unit: 'Set',
        price: 1000.0,
        quantity: 2.0,
        gstRate: 18.0,
        discount: 0.0,
        taxableAmount: 2000.0,
        cgstAmount: 180.0,
        sgstAmount: 180.0,
        igstAmount: 0.0,
        totalTax: 360.0,
        totalAmount: 2360.0,
      );

      final invoice = InvoiceModel(
        id: 'INV-001',
        invoiceNumber: 'INV-2026-0001',
        customerName: 'Muthu Kumar',
        customerPhone: '9876543210',
        vehicleNumber: 'TN-01-AB-1234',
        customerState: 'Tamil Nadu',
        date: DateTime.now(),
        items: [item],
        subtotalTaxable: 2000.0,
        cgstTotal: 180.0,
        sgstTotal: 180.0,
        igstTotal: 0.0,
        totalTax: 360.0,
        discountTotal: 0.0,
        roundOff: 0.0,
        grandTotal: 2360.0,
        paidAmount: 2000.0,
        balanceDue: 360.0,
        paymentMode: 'Credit',
        isGstInclusive: false,
        isInterState: false,
      );

      expect(invoice.isPaidFull, isFalse);
      expect(invoice.balanceDue, 360.0);
      expect(invoice.items.length, 1);
    });
  });
}
