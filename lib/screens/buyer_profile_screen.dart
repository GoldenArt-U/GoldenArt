import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/screens/orders_screen.dart';
import 'package:artisan_market/utils/constants.dart';
import 'package:artisan_market/screens/auth_screen.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: AppColors.border,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text('My Account', style: AppTextStyles.heading3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.dark,
                  child: Text(
                    auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.userName, style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text(auth.user?.email ?? 'Membre GoldenArt', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Orders
            _menuItem(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              subtitle: 'Track your recent purchases',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              },
            ),
            const SizedBox(height: 16),
            
            // Apply to be an Artisan
            _menuItem(
              icon: Icons.storefront_outlined,
              title: 'Become an Artisan',
              subtitle: 'List your 1-of-1 unique creations',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Upgrade to Artisan?', style: AppTextStyles.heading3),
                    content: Text(
                      'Ready to share your rare 1-of-1 pieces with the world? '
                      'This will permanently upgrade your account to a seller profile.',
                      style: AppTextStyles.body.copyWith(height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textMedium)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await auth.upgradeToSeller();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Welcome to GoldenArt Studio!'), backgroundColor: AppColors.success),
                            );
                            Navigator.pop(context); // Pop profile to return home, profile button will now route to dashboard.
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text('Upgrade Account', style: AppTextStyles.button.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (r) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                child: Text('Log Out', style: AppTextStyles.button.copyWith(color: AppColors.dark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading4),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
