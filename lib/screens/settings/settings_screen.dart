import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/user_mode_screen.dart';
import '../customer_portal/customer_home_screen.dart';
import '../worker_portal/worker_home_screen.dart';
import '../home/home_dashboard_screen.dart';
import 'shop_profile_screen.dart';
import 'staff_management_screen.dart';
import 'backup_restore_screen.dart';
import '../purchases/supplier_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final locale = context.watch<LocaleProvider>();
    final user = auth.currentUser;
    final shop = settings.shop;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('settings_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User & Role Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: user?.isOwner == true ? AppColors.primary : AppColors.accent,
                          child: Icon(
                            user?.isOwner == true ? Icons.admin_panel_settings : Icons.point_of_sale,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Shop User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: user?.isOwner == true ? AppColors.primaryLight.withValues(alpha: 0.15) : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user?.isOwner == true ? 'Role: Owner (Full Access)' : 'Role: Staff (Billing Only)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: user?.isOwner == true ? AppColors.primary : AppColors.accentDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick Role Switch
                        PopupMenuButton<UserRole>(
                          icon: const Icon(Icons.swap_horiz),
                          tooltip: 'Switch Demo Role',
                          onSelected: (role) async {
                            await auth.loginAsRole(role);
                            if (context.mounted) {
                              Widget target;
                              switch (role) {
                                case UserRole.admin:
                                  target = const HomeDashboardScreen();
                                  break;
                                case UserRole.user:
                                  target = const CustomerHomeScreen();
                                  break;
                                case UserRole.worker:
                                  target = const WorkerHomeScreen();
                                  break;
                              }
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => target),
                                (r) => false,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: UserRole.admin,
                              child: Text('Switch to Admin Mode'),
                            ),
                            const PopupMenuItem(
                              value: UserRole.user,
                              child: Text('Switch to Customer Mode'),
                            ),
                            const PopupMenuItem(
                              value: UserRole.worker,
                              child: Text('Switch to Mechanic Mode'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Settings Menu Items
                Card(
                  child: Column(
                    children: [
                      // Shop Profile
                      ListTile(
                        leading: const Icon(Icons.storefront, color: AppColors.primary),
                        title: Text(locale.translate('shop_profile')),
                        subtitle: Text('${shop.shopName} • GSTIN: ${shop.gstin}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ShopProfileScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Language Toggle
                      ListTile(
                        leading: const Icon(Icons.translate, color: AppColors.accentDark),
                        title: Text(locale.translate('language')),
                        subtitle: Text(locale.isTamil ? 'தமிழ் (Tamil)' : 'English'),
                        trailing: Switch(
                          value: locale.isTamil,
                          activeThumbColor: AppColors.primary,
                          onChanged: (_) => locale.toggleLanguage(),
                        ),
                      ),
                      const Divider(height: 1),

                      // Staff Management (Owner only)
                      if (auth.isOwner) ...[
                        ListTile(
                          leading: const Icon(Icons.badge, color: AppColors.info),
                          title: Text(locale.translate('staff_management')),
                          subtitle: Text('${settings.staffUsers.length} staff accounts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                      ],

                      // Suppliers Directory
                      ListTile(
                        leading: const Icon(Icons.local_shipping, color: AppColors.success),
                        title: Text(locale.translate('suppliers')),
                        subtitle: const Text('Manage automotive parts distributors'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SupplierListScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Backup & Restore
                      ListTile(
                        leading: const Icon(Icons.backup, color: AppColors.primaryDark),
                        title: Text(locale.translate('backup_restore')),
                        subtitle: const Text('Export JSON backup or restore offline data'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // App Info & Version
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${locale.translate('app_title')} • v1.0.0',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Offline-First GST Billing & Inventory Management\nSupports Android, iOS & Desktop',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: Text(locale.translate('logout'), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _showLogoutDialog(BuildContext context) {
    final isTamil = context.read<LocaleProvider>().isTamil;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
            const SizedBox(width: 8),
            Text(
              isTamil ? 'வெளியேறவா?' : 'Confirm Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          isTamil
              ? 'உங்கள் கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?'
              : 'Are you sure you want to logout and return to user mode selection?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isTamil ? 'இல்லை (No)' : 'No',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
                (r) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isTamil ? 'ஆம் (Yes)' : 'Yes',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
