import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/report_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_report_service.dart';
import '../../services/csv_export_service.dart';

class GstReportScreen extends StatelessWidget {
  const GstReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    final shop = context.watch<SettingsProvider>().shop;
    final locale = context.watch<LocaleProvider>();
    final summary = report.gstr1Summary;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('gstr1_summary')),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: locale.translate('export_pdf'),
            onPressed: () => PdfReportService.shareGstr1Pdf(summary, shop),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: locale.translate('export_csv'),
            onPressed: () => CsvExportService.exportGstr1SummaryToCsv(report.completedInvoices),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('GSTR-1 Tax Summary (Monthly / All)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Filing GSTIN: ${shop.gstin} (${shop.state})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                              child: const Text('GSTR-1 Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.success)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => PdfReportService.shareGstr1Pdf(summary, shop),
                                icon: const Icon(Icons.picture_as_pdf, size: 16),
                                label: const Text('Export PDF'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => CsvExportService.exportGstr1SummaryToCsv(report.completedInvoices),
                                icon: const Icon(Icons.file_download, size: 16),
                                label: const Text('Export Excel (CSV)'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 1. Overview Totals
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Outward Supplies (Sales)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        _taxRow('Total Taxable Value:', CurrencyFormatter.format(summary.totalTaxable), isBold: true),
                        _taxRow('Total GST Tax Collected:', CurrencyFormatter.format(summary.grandTotalTax), isBold: true, color: AppColors.success),
                        const Divider(),
                        _taxRow('Total Gross Invoice Sales:', CurrencyFormatter.format(summary.totalSales), isBold: true, fontSize: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 2. B2B vs B2C Breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Table 4 & 5: B2B vs B2C Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),

                        // B2B
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('B2B Sales (With Customer GSTIN)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${summary.b2bInvoicesCount} Invoices', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _taxRow('Taxable Value:', CurrencyFormatter.format(summary.b2bTaxable)),
                              _taxRow('Tax Collected:', CurrencyFormatter.format(summary.b2bTotalTax)),
                              _taxRow('Grand Total:', CurrencyFormatter.format(summary.b2bGrandTotal), isBold: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // B2C
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('B2C Sales (Consumers & Retail)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${summary.b2cInvoicesCount} Invoices', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _taxRow('Taxable Value:', CurrencyFormatter.format(summary.b2cTaxable)),
                              _taxRow('Tax Collected:', CurrencyFormatter.format(summary.b2cTotalTax)),
                              _taxRow('Grand Total:', CurrencyFormatter.format(summary.b2cGrandTotal), isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Tax Components (CGST, SGST, IGST)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tax Component Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        _taxRow('Central Tax (CGST):', CurrencyFormatter.format(summary.totalCgst)),
                        _taxRow('State Tax (SGST):', CurrencyFormatter.format(summary.totalSgst)),
                        _taxRow('Integrated Tax (IGST):', CurrencyFormatter.format(summary.totalIgst)),
                        const Divider(),
                        _taxRow('Total Tax:', CurrencyFormatter.format(summary.grandTotalTax), isBold: true, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taxRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
