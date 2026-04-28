import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/category.dart';
import '../widgets/item_card.dart';
import 'add_edit_screen.dart';
import '../services/pdf_service.dart';
import 'home_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportPdf(BuildContext context) async {
    final provider = context.read<CollectionProvider>();
    final items = provider.filteredItems;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eksport qilish uchun element yo\'q')),
      );
      return;
    }
    try {
      await PdfService.exportItems(items);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF muvaffaqiyatli eksport qilindi'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final filtered = provider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              TabBackNotification().dispatch(context);
            }
          },
        ),
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Qidirish...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: provider.setSearch,
              )
            : const Text('Kolleksiya',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                provider.setSearch('');
              }
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Saralash',
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'name', child: Text('Nom bo\'yicha')),
              const PopupMenuItem(
                  value: 'price', child: Text('Qiymat bo\'yicha')),
              const PopupMenuItem(
                  value: 'category',
                  child: Text('Kategoriya bo\'yicha')),
              const PopupMenuItem(
                  value: 'created_at',
                  child: Text('Sana bo\'yicha')),
            ],
            onSelected: provider.setSort,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF eksport',
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategoriya filtri
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'Hammasi (${provider.totalItems})',
                  selected: provider.selectedCategory == 'all',
                  onTap: () => provider.setCategory('all'),
                  color: const Color(0xFF854F0B),
                ),
                const SizedBox(width: 8),
                ...categories.map((cat) {
                  final count = provider.categoryCount[cat.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: '${cat.emoji} ${cat.name} ($count)',
                      selected: provider.selectedCategory == cat.id,
                      onTap: () => provider.setCategory(cat.id),
                      color: cat.color,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Natijalar soni
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} ta element',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888680)),
                ),
              ],
            ),
          ),

          // Elementlar ro'yxati
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📭',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text('Element topilmadi',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF888680))),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AddEditScreen()),
                              ),
                              child: const Text("+ Yangi element qo'shish"),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          return ItemCard(
                            item: filtered[i],
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditScreen(item: filtered[i]),
                              ),
                            ),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("O'chirish"),
                                  content: Text(
                                      "'${filtered[i].name}' ni o'chirishni xohlaysizmi?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(_, false),
                                        child:
                                            const Text('Bekor qilish')),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(_, true),
                                      child: const Text("O'chirish",
                                          style: TextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && ctx.mounted) {
                                context
                                    .read<CollectionProvider>()
                                    .deleteItem(filtered[i].id!);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text("Qo'shish"),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: selected ? color : const Color(0xFFDDD8D0),
            width: selected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? color : const Color(0xFF666660),
          ),
        ),
      ),
    );
  }
}
