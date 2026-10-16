import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/used_vehicle_model.dart';
import '../../providers/used_vehicle_provider.dart';
import 'add_edit_used_vehicle_screen.dart';
import 'used_vehicle_detail_screen.dart';

class UsedVehicleHubScreen extends StatefulWidget {
  const UsedVehicleHubScreen({super.key});

  @override
  State<UsedVehicleHubScreen> createState() => _UsedVehicleHubScreenState();
}

class _UsedVehicleHubScreenState extends State<UsedVehicleHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, UsedVehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle Listing?'),
        content: Text('Are you sure you want to remove "${vehicle.title}" (${vehicle.regNumber}) from the sales inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<UsedVehicleProvider>().deleteVehicle(vehicle.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle listing removed!')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<UsedVehicleProvider>();
    final vehicles = vehicleProvider.filteredVehicles;
    final currentFilter = vehicleProvider.selectedTypeFilter;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Pre-Owned Sales Hub (Cars & Bikes)',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => vehicleProvider.loadVehicles(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditUsedVehicleScreen()),
          );
        },
        backgroundColor: const Color(0xFF0F2B66),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Vehicle for Sale',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Showroom Sales Overview Banner
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2B66), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              children: [
                Expanded(child: _statCol('Total', '${vehicleProvider.totalCount}', Icons.inventory_2_rounded)),
                Container(height: 32, width: 1, color: Colors.white24),
                Expanded(child: _statCol('Cars', '${vehicleProvider.carsCount}', Icons.directions_car_rounded)),
                Container(height: 32, width: 1, color: Colors.white24),
                Expanded(child: _statCol('Bikes', '${vehicleProvider.bikesCount}', Icons.two_wheeler_rounded)),
                Container(height: 32, width: 1, color: Colors.white24),
                Expanded(child: _statCol('Available', '${vehicleProvider.availableCount}', Icons.check_circle_outline_rounded)),
              ],
            ),
          ),

          // Search Bar & Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => vehicleProvider.setSearchQuery(q),
              decoration: InputDecoration(
                hintText: 'Search by model, brand, or reg number...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          vehicleProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Category Chips: All, Cars, Bikes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _filterChip(label: 'All Vehicles (${vehicleProvider.totalCount})', value: 'all', selectedValue: currentFilter, onSelect: () => vehicleProvider.setTypeFilter('all')),
                const SizedBox(width: 8),
                _filterChip(label: '🚗 Cars (${vehicleProvider.carsCount})', value: 'car', selectedValue: currentFilter, onSelect: () => vehicleProvider.setTypeFilter('car')),
                const SizedBox(width: 8),
                _filterChip(label: '🏍️ Bikes (${vehicleProvider.bikesCount})', value: 'bike', selectedValue: currentFilter, onSelect: () => vehicleProvider.setTypeFilter('bike')),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Vehicles List
          Expanded(
            child: vehicleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_car_outlined, size: 56, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text('No vehicles found in this category.'),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "+ Add Vehicle for Sale" to publish cars or bikes.',
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4, left: 14, right: 14),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final v = vehicles[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 1.5,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => UsedVehicleDetailScreen(vehicle: v)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Vehicle Icon Circle
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: v.isCar
                                              ? const Color(0xFF0F2B66).withValues(alpha: 0.1)
                                              : const Color(0xFF831843).withValues(alpha: 0.1),
                                          child: Icon(
                                            v.isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                                            color: v.isCar ? const Color(0xFF0F2B66) : const Color(0xFFBE185D),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                v.title,
                                                style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${v.year} • ${v.kmDriven} KM • ${v.fuelType} • ${v.ownershipCount} Owner',
                                                style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Reg: ${v.regNumber}',
                                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F2B66)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, size: 20),
                                          onSelected: (action) {
                                            if (action == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => AddEditUsedVehicleScreen(vehicle: v)),
                                              );
                                            } else if (action == 'mark_sold') {
                                              vehicleProvider.updateStatus(v.id, 'sold');
                                            } else if (action == 'mark_available') {
                                              vehicleProvider.updateStatus(v.id, 'available');
                                            } else if (action == 'delete') {
                                              _confirmDelete(context, v);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit Details')])),
                                            if (v.isAvailable)
                                              const PopupMenuItem(value: 'mark_sold', child: Row(children: [Icon(Icons.check_circle, size: 16, color: Colors.red), SizedBox(width: 8), Text('Mark as Sold')]))
                                            else
                                              const PopupMenuItem(value: 'mark_available', child: Row(children: [Icon(Icons.check_circle, size: 16, color: Colors.green), SizedBox(width: 8), Text('Mark as Available')])),
                                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  v.inspectionScore,
                                                  style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                              decoration: BoxDecoration(
                                                color: v.isAvailable
                                                    ? const Color(0xFFDCFCE7)
                                                    : (v.isBooked ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                v.status.toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: v.isAvailable
                                                      ? const Color(0xFF15803D)
                                                      : (v.isBooked ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              CurrencyFormatter.format(v.sellingPrice),
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F2B66),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.white70)),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required String value,
    required String selectedValue,
    required VoidCallback onSelect,
  }) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      selectedColor: const Color(0xFF0F2B66),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? const Color(0xFF0F2B66) : const Color(0xFFCBD5E1)),
    );
  }
}
