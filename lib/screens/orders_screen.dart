import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/models/order_model.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/utils/constants.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
      case OrderStatus.shipped: return AppColors.dark;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes commandes', style: AppTextStyles.heading3),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: service.getUserOrders(auth.userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 80, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text('Aucune commande',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 8),
                  Text('Vos commandes apparaîtront ici',
                      style: AppTextStyles.caption),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          '#${order.id.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            order.statusLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: _statusColor(order.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.items.length} article(s)',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.address,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          AppConstants.formatMoney(order.total),
                          style: AppTextStyles.price,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
