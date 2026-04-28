import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} mln so\'m';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} ming so\'m';
    }
    return '${price.toStringAsFixed(0)} so\'m';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFBA7517),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.collections_bookmark,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kolleksiya',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Statistika',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF854F0B))),
              ],
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadItems,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Umumiy statistika
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Jami elementlar',
                          value: '${provider.totalItems}',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF185FA5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: 'Kategoriyalar',
                          value: '${categories.length}',
                          icon: Icons.category_outlined,
                          color: const Color(0xFF3B6D11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Umumiy qiymat',
                          value: _formatPrice(provider.totalValue),
                          icon: Icons.account_balance_wallet_outlined,
                          color: const Color(0xFFBA7517),
                          small: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: "O'rtacha qiymat",
                          value: _formatPrice(provider.averageValue),
                          icon: Icons.trending_up,
                          color: const Color(0xFF993556),
                          small: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Kategoriya kartalari
                  const Text(
                    'Kategoriyalar',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: categories.map((cat) {
                      final count = provider.categoryCount[cat.id] ?? 0;
                      final value = provider.categoryValue[cat.id] ?? 0;
                      final maxCount = provider.totalItems > 0
                          ? provider.totalItems
                          : 1;
                      return _CategoryCard(
                        cat: cat,
                        count: count,
                        value: value,
                        percent: count / maxCount,
                        formatPrice: _formatPrice,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Qiymat grafigi
                  if (provider.totalItems > 0) ...[
                    const Text(
                      "Kategoriya bo'yicha qiymat",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: categories.map((cat) {
                            final value =
                                provider.categoryValue[cat.id] ?? 0;
                            final maxValue = provider.categoryValue.values
                                .fold(0.0, (a, b) => a > b ? a : b);
                            final percent =
                                maxValue > 0 ? value / maxValue : 0.0;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Text(cat.emoji,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 52,
                                    child: Text(cat.name,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF666))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 20,
                                        backgroundColor:
                                            const Color(0xFFF5F0E8),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                cat.color),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatPrice(value),
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: cat.color),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Oxirgi qo'shilganlar
                  if (provider.recentItems.isNotEmpty) ...[
                    const Text(
                      "Oxirgi qo'shilganlar",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.recentItems.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xFFEEE8E0)),
                        itemBuilder: (ctx, i) {
                          final item = provider.recentItems[i];
                          final cat = getCategoryById(item.category);
                          return ListTile(
                            leading: Text(cat.emoji,
                                style: const TextStyle(fontSize: 22)),
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(cat.name,
                                style: TextStyle(
                                    fontSize: 11, color: cat.color)),
                            trailing: Text(
                              _formatPrice(item.price),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF854F0B)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final dynamic cat;
  final int count;
  final double value;
  final double percent;
  final String Function(double) formatPrice;

  const _CategoryCard({
    required this.cat,
    required this.count,
    required this.value,
    required this.percent,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(cat.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Text('$count ta',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cat.color)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 4,
                backgroundColor: const Color(0xFFF0EBE0),
                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
