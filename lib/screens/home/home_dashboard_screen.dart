import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/settings_provider.dart';
import '../billing/new_bill_screen.dart';
import '../billing/invoice_list_screen.dart';
import '../billing/invoice_preview_screen.dart';
import '../inventory/inventory_list_screen.dart';
import '../inventory/add_edit_part_screen.dart';
import '../inventory/barcode_scanner_screen.dart';
import '../customers/customer_list_screen.dart';
import '../customers/add_edit_customer_screen.dart';
import '../purchases/purchase_list_screen.dart';
import '../purchases/new_purchase_screen.dart';
import '../reports/reports_dashboard_screen.dart';
import '../reports/customer_dues_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/user_mode_screen.dart';
import '../used_vehicles/used_vehicle_hub_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  void _onScanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || barcode == null || barcode.isEmpty) return;

    final part = await context.read<InventoryProvider>().findByBarcode(barcode);
    if (!mounted) return;

    if (part != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(part.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Part #: ${part.partNumber}  •  ${part.brand}'),
              Text('Category: ${part.category}'),
              Text(
                'In Stock: ${part.stockQuantity} ${part.unit}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Selling Price: ${CurrencyFormatter.format(part.sellingPrice)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BillingProvider>().addToCart(part);
                Navigator.pop(ctx);
                setState(() => _currentIndex = 1); // switch to billing tab
              },
              icon: const Icon(Icons.add_shopping_cart, size: 16),
              label: const Text('Add to Bill'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No part matched barcode: $barcode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    final List<Widget> screens = [
      _buildDashboardHome(),
      const NewBillScreen(),
      const InventoryListScreen(),
      const CustomerListScreen(),
      if (auth.isOwner)
        const ReportsDashboardScreen()
      else
        const PurchaseListScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 10,
          unselectedFontSize: 9,
          iconSize: 20,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: locale.translate('nav_dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: locale.translate('nav_billing'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: locale.translate('nav_inventory'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: locale.translate('nav_customers'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                auth.isOwner
                    ? Icons.analytics_outlined
                    : Icons.shopping_bag_outlined,
              ),
              activeIcon: Icon(
                auth.isOwner ? Icons.analytics : Icons.shopping_bag,
              ),
              label: auth.isOwner
                  ? locale.translate('nav_reports')
                  : locale.translate('nav_purchases'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: locale.translate('nav_settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    final report = context.watch<ReportProvider>();
    final inventory = context.watch<InventoryProvider>();
    final customer = context.watch<CustomerProvider>();
    final billing = context.watch<BillingProvider>();
    final settings = context.watch<SettingsProvider>();
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    final recentInvoices = billing.allInvoices.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
              );
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.shop.shopName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: auth.isOwner
                        ? AppColors.accent
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    auth.isOwner ? 'OWNER' : 'STAFF',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'GSTIN: ${settings.shop.gstin}',
                    style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: locale.translate('scan_barcode'),
            onPressed: _onScanBarcode,
          ),
          TextButton.icon(
            onPressed: () => locale.toggleLanguage(),
            icon: const Icon(Icons.language, size: 16, color: Colors.white),
            label: Text(
              locale.isTamil ? 'தமிழ்' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await inventory.loadParts();
          await billing.loadInvoices();
          await customer.loadCustomers();
          await report.loadReports();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sales Overview Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locale.translate('daily_sales').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                DateFormatter.format(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(report.todaySales),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _miniMetric(
                              'Bills Today',
                              '${report.todayInvoiceCount}',
                            ),
                            const SizedBox(width: 16),
                            _miniMetric(
                              'Month Sales',
                              CurrencyFormatter.format(report.thisMonthSales),
                            ),
                            const SizedBox(width: 16),
                            _miniMetric(
                              'GST Collected',
                              CurrencyFormatter.format(report.totalLifetimeTax),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pre-Owned Sales & Showroom Quick Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.car_rental_rounded, color: Color(0xFF0F2B66), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Second-Hand Car & Bike Sales',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              Text(
                                'Manage showroom inventory, pre-owned cars, bikes & leads.',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const UsedVehicleHubScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2B66),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Showroom', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    locale.translate('quick_actions'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.95,
                    children: [
                      _actionTile(
                        icon: Icons.receipt_long,
                        label: locale.translate('new_bill'),
                        color: AppColors.primary,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _actionTile(
                        icon: Icons.qr_code_scanner,
                        label: locale.translate('scan_barcode'),
                        color: AppColors.accentDark,
                        onTap: _onScanBarcode,
                      ),
                      _actionTile(
                        icon: Icons.add_circle_outline,
                        label: locale.translate('add_part'),
                        color: AppColors.success,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEditPartScreen(),
                            ),
                          );
                        },
                      ),
                      _actionTile(
                        icon: Icons.person_add_alt,
                        label: locale.translate('add_customer'),
                        color: AppColors.info,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEditCustomerScreen(),
                            ),
                          );
                        },
                      ),
                      _actionTile(
                        icon: Icons.add_shopping_cart,
                        label: 'Stock In (Purchase)',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewPurchaseScreen(),
                            ),
                          );
                        },
                      ),
                      _actionTile(
                        icon: Icons.account_balance_wallet,
                        label: 'Customer Dues',
                        color: AppColors.danger,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerDuesScreen(),
                            ),
                          );
                        },
                      ),
                      _actionTile(
                        icon: Icons.car_rental_rounded,
                        label: 'Sales Showroom',
                        color: const Color(0xFF0D9488),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UsedVehicleHubScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status Cards (Low Stock & Credit Dues)
                  Row(
                    children: [
                      // Low Stock Card
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            inventory.toggleLowStockFilter();
                            setState(
                              () => _currentIndex = 2,
                            ); // switch to inventory
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: inventory.lowStockCount > 0
                                  ? AppColors.dangerLight
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: inventory.lowStockCount > 0
                                    ? AppColors.danger.withValues(alpha: 0.3)
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Low Stock Parts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: inventory.lowStockCount > 0
                                            ? AppColors.danger
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                      color: inventory.lowStockCount > 0
                                          ? AppColors.danger
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${inventory.lowStockCount} items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: inventory.lowStockCount > 0
                                        ? AppColors.danger
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const Text(
                                  'Tap to review',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Customer Credit Card
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerDuesScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: customer.totalCreditDue > 0
                                  ? AppColors.warningLight
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: customer.totalCreditDue > 0
                                    ? AppColors.accent.withValues(alpha: 0.3)
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Credit Balance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: customer.totalCreditDue > 0
                                            ? AppColors.accentDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Icon(
                                      Icons.pending_actions,
                                      size: 18,
                                      color: customer.totalCreditDue > 0
                                          ? AppColors.accentDark
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  CurrencyFormatter.format(
                                    customer.totalCreditDue,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: customer.totalCreditDue > 0
                                        ? AppColors.accentDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  '${customer.customersWithDues.length} customers',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recent Invoices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Invoices',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoiceListScreen(),
                            ),
                          );
                        },
                        child: const Text('View All Invoices'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (recentInvoices.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        'No invoices generated yet. Start billing!',
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentInvoices.length,
                      itemBuilder: (context, idx) {
                        final inv = recentInvoices[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvoicePreviewScreen(invoice: inv),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight
                                  .withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.receipt,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  inv.invoiceNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(inv.grandTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${inv.customerName} ${inv.vehicleNumber.isNotEmpty ? '• 🚗 ${inv.vehicleNumber}' : ''}\n${DateFormatter.formatWithTime(inv.date)}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10.5),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
