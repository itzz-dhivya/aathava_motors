import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/stock_history_model.dart';

class StockHistoryScreen extends StatefulWidget {
  final String? partId;
  final String? partName;

  const StockHistoryScreen({super.key, this.partId, this.partName});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  List<StockHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    if (widget.partId != null) {
      _history = await AppDatabase.instance.getStockHistoryByPart(widget.partId!);
    } else {
      _history = await AppDatabase.instance.getAllStockHistory();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partName != null ? 'Stock Logs: ${widget.partName}' : 'Stock Movement History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text('No stock movement records yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final isPositive = item.quantityChange >= 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon container
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isPositive ? AppColors.successLight : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isPositive ? AppColors.success : AppColors.danger,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.partName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPositive ? AppColors.successLight : AppColors.dangerLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${isPositive ? '+' : ''}${item.quantityChange}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isPositive ? AppColors.success : AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Type: ${item.changeType}  •  Bal: ${item.resultingStock}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  ),
                                  if (item.referenceNumber.isNotEmpty)
                                    Text(
                                      'Ref: ${item.referenceNumber}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                  if (item.notes.isNotEmpty)
                                    Text(
                                      item.notes,
                                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormatter.formatWithTime(item.timestamp),
                                    style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
