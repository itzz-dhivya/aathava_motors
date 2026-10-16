import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/report_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../services/csv_export_service.dart';
import 'gst_report_screen.dart';
import 'customer_dues_screen.dart';
import '../inventory/inventory_list_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    final inventory = context.watch<InventoryProvider>();
    final locale = context.watch<LocaleProvider>();

    final paymentData = report.paymentModeBreakdown;
    final totalPaymentAmount = paymentData.values.fold(0.0, (sum, val) => sum + val);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('reports_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: locale.translate('export_csv'),
            onPressed: () => CsvExportService.exportInvoicesToCsv(report.completedInvoices),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top KPI Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        title: locale.translate('daily_sales'),
                        value: CurrencyFormatter.format(report.todaySales),
                        subtitle: '${report.todayInvoiceCount} bills today',
                        icon: Icons.today,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        title: locale.translate('monthly_sales'),
                        value: CurrencyFormatter.format(report.thisMonthSales),
                        subtitle: '${report.thisMonthInvoiceCount} bills this month',
                        icon: Icons.calendar_month,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        title: locale.translate('total_tax_collected'),
                        value: CurrencyFormatter.format(report.totalLifetimeTax),
                        subtitle: 'CGST + SGST + IGST',
                        icon: Icons.receipt_long,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomerDuesScreen()),
                          );
                        },
                        child: _kpiCard(
                          title: 'Customer Dues',
                          value: CurrencyFormatter.format(report.totalOutstandingDues),
                          subtitle: 'Tap to view dues ledger',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Report Links Bar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GstReportScreen()),
                          );
                        },
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text('GSTR-1 Tax Summary'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomerDuesScreen()),
                          );
                        },
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Customer Dues'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Payment Mode Distribution (Interactive Pie Chart)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Mode Revenue Distribution',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        if (totalPaymentAmount <= 0)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No payment transaction data yet.'),
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: [
                                  if ((paymentData['Cash'] ?? 0) > 0)
                                    PieChartSectionData(
                                      color: AppColors.success,
                                      value: paymentData['Cash']!,
                                      title: 'Cash',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  if ((paymentData['UPI'] ?? 0) > 0)
                                    PieChartSectionData(
                                      color: AppColors.primary,
                                      value: paymentData['UPI']!,
                                      title: 'UPI',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  if ((paymentData['Card'] ?? 0) > 0)
                                    PieChartSectionData(
                                      color: AppColors.accent,
                                      value: paymentData['Card']!,
                                      title: 'Card',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  if ((paymentData['Credit'] ?? 0) > 0)
                                    PieChartSectionData(
                                      color: AppColors.danger,
                                      value: paymentData['Credit']!,
                                      title: 'Credit',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _legend('Cash', CurrencyFormatter.format(paymentData['Cash'] ?? 0), AppColors.success),
                              _legend('UPI', CurrencyFormatter.format(paymentData['UPI'] ?? 0), AppColors.primary),
                              _legend('Card', CurrencyFormatter.format(paymentData['Card'] ?? 0), AppColors.accent),
                              _legend('Credit', CurrencyFormatter.format(paymentData['Credit'] ?? 0), AppColors.danger),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Top-Selling Spare Parts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(locale.translate('top_selling'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                            ),
                            const Icon(Icons.trending_up, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (report.topSellingParts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Generate bills to rank your best selling spare parts.'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: report.topSellingParts.take(5).length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, idx) {
                              final item = report.topSellingParts[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryDark,
                                  child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(item.partName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                                subtitle: Text('Part#: ${item.partNumber} • Qty Sold: ${item.totalQuantity.toInt()} units'),
                                trailing: Text(
                                  CurrencyFormatter.format(item.totalRevenue),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Low Stock Alerts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Low Stock Warnings',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.danger),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                inventory.toggleLowStockFilter();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const InventoryListScreen()),
                                );
                              },
                              child: const Text('View All in Inventory'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (report.lowStockParts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('✅ Inventory health is optimal. No parts are below threshold!'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: report.lowStockParts.take(4).length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, idx) {
                              final p = report.lowStockParts[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text('Alert threshold: <= ${p.minStockAlert} ${p.unit}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${p.stockQuantity.toInt()} left',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _legend(String title, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
