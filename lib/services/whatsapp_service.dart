import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice_model.dart';
import '../models/customer_model.dart';
import '../models/shop_profile_model.dart';
import '../core/utils/currency_formatter.dart';

class WhatsAppService {
  static Future<bool> sendInvoiceToCustomer({
    required InvoiceModel invoice,
    required ShopProfileModel shop,
  }) async {
    final phone = _sanitizePhone(invoice.customerPhone);
    final buffer = StringBuffer();

    buffer.writeln('🚗 *${shop.shopName.toUpperCase()}*');
    buffer.writeln('MULTI BRAND CAR SERVICE CENTRE');
    buffer.writeln('📍 ${shop.address}');
    buffer.writeln('Ph: ${shop.phone} | GSTIN: ${shop.gstin}');
    buffer.writeln('--------------------------------');
    buffer.writeln('🧾 *CASH / CREDIT BILL*');
    buffer.writeln('Bill No: *${invoice.invoiceNumber}*');
    buffer.writeln('Customer: *${invoice.customerName}*');
    if (invoice.customerPhone.isNotEmpty) {
      buffer.writeln('Mobile: *${invoice.customerPhone}*');
    }
    if (invoice.vehicleNumber.isNotEmpty) {
      buffer.writeln('Vehicle: *${invoice.vehicleNumber}* (Hyundai Accent)');
    }
    buffer.writeln('Job No: *3168* | KM: *1,03,559*');
    buffer.writeln('--------------------------------');
    buffer.writeln('📦 *Particulars / Services:*');
    for (int i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      buffer.writeln('${i + 1}. ${item.partName} = ${CurrencyFormatter.format(item.totalAmount)}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('💰 *TOTAL AMOUNT: ${CurrencyFormatter.format(invoice.grandTotal)}*');
    buffer.writeln('(${CurrencyFormatter.toWords(invoice.grandTotal)})');
    buffer.writeln('✅ Paid Status: *${invoice.status.toUpperCase()} (${invoice.paymentMode.toUpperCase()})*');
    if (invoice.balanceDue > 0) {
      buffer.writeln('⚠️ *Balance Due: ${CurrencyFormatter.format(invoice.balanceDue)}*');
    }
    if (shop.upiId.isNotEmpty) {
      buffer.writeln('\nPay via UPI: *${shop.upiId}*');
    }
    buffer.writeln('\nThank you for choosing AATHAVA MOTORS! Drive safely. 🚗✨');

    return await _launchWhatsApp(
      phone: phone,
      message: buffer.toString(),
      subject: 'AATHAVA MOTORS - Bill No. ${invoice.invoiceNumber}',
    );
  }

  static Future<bool> sendDuesReminder({
    required CustomerModel customer,
    required ShopProfileModel shop,
  }) async {
    final phone = _sanitizePhone(customer.phone);
    final buffer = StringBuffer();

    buffer.writeln('🚗 *${shop.shopName}*');
    buffer.writeln('Dear *${customer.name}*,');
    buffer.writeln('Greetings from AATHAVA MOTORS!');
    buffer.writeln('\nThis is a friendly reminder that you have a pending balance of *${CurrencyFormatter.format(customer.pendingBalance)}* for services on your vehicle *${customer.vehicleNumber}*.');
    if (shop.upiId.isNotEmpty) {
      buffer.writeln('\nYou can easily pay via UPI to: *${shop.upiId}*');
    }
    buffer.writeln('\nFor queries, reach us at ${shop.phone}.');
    buffer.writeln('Thank you for your valued patronage!');

    return await _launchWhatsApp(
      phone: phone,
      message: buffer.toString(),
      subject: 'Payment Reminder from ${shop.shopName}',
    );
  }

  static String _sanitizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      clean = '91$clean'; // Default India country code
    }
    return clean;
  }

  static Future<bool> _launchWhatsApp({
    required String phone,
    required String message,
    String? subject,
  }) async {
    final encodedText = Uri.encodeComponent(message);

    // List of direct WhatsApp URIs to try
    final List<String> urlsToTry = [];
    if (phone.isNotEmpty) {
      urlsToTry.add('whatsapp://send?phone=$phone&text=$encodedText');
      urlsToTry.add('https://wa.me/$phone?text=$encodedText');
      urlsToTry.add('https://api.whatsapp.com/send?phone=$phone&text=$encodedText');
    } else {
      urlsToTry.add('whatsapp://send?text=$encodedText');
      urlsToTry.add('https://api.whatsapp.com/send?text=$encodedText');
    }

    for (final url in urlsToTry) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        } else {
          // Attempt direct launch without pre-check (bypasses canLaunchUrl package visibility check on some Android versions)
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        }
      } catch (_) {
        // Continue to fallback
      }
    }

    // Ultimate fallback: open Android/iOS native share sheet
    // This always succeeds and allows selecting WhatsApp directly
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: subject ?? 'AATHAVA MOTORS Service Bill',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
