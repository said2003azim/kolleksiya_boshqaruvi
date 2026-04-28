import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/collection_provider.dart';
import '../models/category.dart';
import 'add_edit_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Foydalanuvchi';
  String? _profileImagePath;
  final _wishlistCtrl = TextEditingController();
  final int _targetGoal = 50; // Maqsad: 50 ta element

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Foydalanuvchi';
      _profileImagePath = prefs.getString('profileImage');
    });
  }

  @override
  void dispose() {
    _wishlistCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)} mln';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)} ming';
    return price.toStringAsFixed(0);
  }

  List<PieChartSectionData> _buildPieSections(CollectionProvider provider) {
    final sections = <PieChartSectionData>[];
    for (var cat in categories) {
      final count = provider.categoryCount[cat.id] ?? 0;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: cat.color,
            value: count.toDouble(),
            title: '$count',
            radius: 40,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    }
    // Agar umuman element bo'lmasa, bo'sh grafik
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
        color: Colors.grey.shade300,
        value: 1,
        title: '0',
        radius: 40,
      ));
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            // Navigate to Profile tab or Screen
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFBA7517),
                backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                child: _profileImagePath == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xush kelibsiz!',
                    style: TextStyle(fontSize: 12, color: Color(0xFF854F0B)),
                  ),
                  Text(
                    _userName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Qidiruv maydoni ochish yoki qidiruv oynasiga yuborish
              showSearch(
                context: context,
                delegate: _CollectionSearchDelegate(provider, _formatPrice),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty 
              ? Center(child: Text("Xatolik: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
              onRefresh: provider.loadItems,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Umumiy Boylik va Qo'shish
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBA7517), Color(0xFFD68B22)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBA7517).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Umumiy boylik",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_formatPrice(provider.totalValue)} so'm",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddEditScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, color: Color(0xFFBA7517)),
                          label: const Text(
                            "Yangi element qo'shish",
                            style: TextStyle(
                                color: Color(0xFFBA7517),
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Maqsad (Goal) va Taraqqiyot
                  const Text(
                    "Mening maqsadim",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$_targetGoal ta noyob element yig'ish",
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                  "${provider.totalItems}/$_targetGoal",
                                  style: const TextStyle(
                                      color: Color(0xFFBA7517),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: provider.totalItems / _targetGoal,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFF0EBE0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFBA7517)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kategoriyalar taqsimoti (Pie Chart)
                  const Text(
                    "Kategoriyalar taqsimoti",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 20,
                                sections: _buildPieSections(provider),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: categories.map((cat) {
                                final count =
                                    provider.categoryCount[cat.id] ?? 0;
                                if (count == 0) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                            color: cat.color,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Text("${cat.emoji} ${cat.name}"),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Eng qimmatli elementlar
                  if (provider.topValuableItems.isNotEmpty) ...[
                    const Text(
                      "Eng qimmatli elementlar (Top-3)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.topValuableItems.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xFFEEE8E0)),
                        itemBuilder: (ctx, i) {
                          final item = provider.topValuableItems[i];
                          final cat = getCategoryById(item.category);
                          return ListTile(
                            leading: Text(cat.emoji,
                                style: const TextStyle(fontSize: 24)),
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            trailing: Text(
                              "${_formatPrice(item.price)} so'm",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF854F0B)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Istaklar ro'yxati (Wishlist)
                  const Text(
                    "Istaklar ro'yxati (Xaridlar)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _wishlistCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Nima sotib olmoqchisiz?',
                                    isDense: true,
                                  ),
                                  onSubmitted: (v) {
                                    provider.addWishlistItem(v);
                                    _wishlistCtrl.clear();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Color(0xFFBA7517)),
                                onPressed: () {
                                  provider.addWishlistItem(_wishlistCtrl.text);
                                  _wishlistCtrl.clear();
                                },
                              )
                            ],
                          ),
                          if (provider.wishlist.isNotEmpty)
                            const SizedBox(height: 12),
                          ...provider.wishlist.map((w) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.check_box_outline_blank,
                                  color: Colors.grey),
                              title: Text(w),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    provider.removeWishlistItem(w),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// Qidiruv uchun yordamchi oyna
class _CollectionSearchDelegate extends SearchDelegate {
  final CollectionProvider provider;
  final String Function(double) formatPrice;

  _CollectionSearchDelegate(this.provider, this.formatPrice);

  @override
  String get searchFieldLabel => "Element izlash...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final list = provider.items.where((i) {
      final q = query.toLowerCase();
      return i.name.toLowerCase().contains(q) ||
             i.description.toLowerCase().contains(q);
    }).toList();

    if (list.isEmpty) {
      return const Center(child: Text("Hech narsa topilmadi"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final cat = getCategoryById(item.category);
        return ListTile(
          leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(item.name),
          subtitle: Text(cat.name),
          trailing: Text("${formatPrice(item.price)} so'm"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen(item: item)),
            );
          },
        );
      },
    );
  }
}
