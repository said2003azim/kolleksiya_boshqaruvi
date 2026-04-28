import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import '../database/db_helper.dart';

class CollectionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper();

  List<CollectionItem> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _sortField = 'created_at';
  bool _sortAsc = false;
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<String> _wishlist = [];

  List<CollectionItem> get items => _items;
  List<String> get wishlist => _wishlist;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<CollectionItem> get filteredItems {
    var filtered = List<CollectionItem>.from(_items);

    // Kategoriya filtri
    if (_selectedCategory != 'all') {
      filtered = filtered.where((i) => i.category == _selectedCategory).toList();
    }

    // Qidiruv filtri
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q))
          .toList();
    }

    // Saralash
    filtered.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'price':
          cmp = a.price.compareTo(b.price);
          break;
        case 'category':
          cmp = a.category.compareTo(b.category);
          break;
        default:
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return filtered;
  }

  // Statistika
  int get totalItems => _items.length;
  double get totalValue => _items.fold(0.0, (sum, i) => sum + i.price);
  double get averageValue => totalItems > 0 ? totalValue / totalItems : 0;

  Map<String, int> get categoryCount {
    final map = <String, int>{};
    for (var item in _items) {
      map[item.category] = (map[item.category] ?? 0) + 1;
    }
    return map;
  }

  Map<String, double> get categoryValue {
    final map = <String, double>{};
    for (var item in _items) {
      map[item.category] = (map[item.category] ?? 0.0) + item.price;
    }
    return map;
  }

  List<CollectionItem> get recentItems {
    final sorted = List<CollectionItem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<CollectionItem> get topValuableItems {
    final sorted = List<CollectionItem>.from(_items)
      ..sort((a, b) => b.price.compareTo(a.price));
    return sorted.take(3).toList();
  }

  // Ma'lumotlarni yuklash
  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _items = await _db.getAllItems();
      
      // Agar baza bo'sh bo'lsa, dummy ma'lumotlar qo'shamiz
      if (_items.isEmpty) {
        await _generateDummyData();
        _items = await _db.getAllItems();
      }

      await _loadWishlist();
    } catch (e, stack) {
      _errorMessage = e.toString();
      debugPrint('XATOLIK loadItems da: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _generateDummyData() async {
    final dummies = [
      CollectionItem(name: "Alisher Navoiy 'Xamsa'", category: "kitob", description: "1991 yil nashri, yaxshi holatda", price: 150000),
      CollectionItem(name: "Amir Temur 1996 tanga", category: "tanga", description: "Yubiley tangasi", price: 500000),
      CollectionItem(name: "O'zbekiston pochtasi", category: "marka", description: "Ilk mustaqillik markalari", price: 50000),
      CollectionItem(name: "Eski mis tanga", category: "tanga", description: "Qadimiy tanga", price: 250000),
      CollectionItem(name: "Spider-Man figurasi", category: "figura", description: "Original Marvel figurasi", price: 300000),
    ];
    for (var d in dummies) {
      await _db.insertItem(d);
    }
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    _wishlist = prefs.getStringList('wishlist') ?? [];
  }

  Future<void> addWishlistItem(String item) async {
    if (item.trim().isEmpty || _wishlist.contains(item)) return;
    _wishlist.add(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', _wishlist);
    notifyListeners();
  }

  Future<void> removeWishlistItem(String item) async {
    _wishlist.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', _wishlist);
    notifyListeners();
  }

  // Qidirish
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Kategoriya filtri
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Saralash
  void setSort(String field) {
    if (_sortField == field) {
      _sortAsc = !_sortAsc;
    } else {
      _sortField = field;
      _sortAsc = true;
    }
    notifyListeners();
  }

  // Element qo'shish
  Future<void> addItem(CollectionItem item) async {
    await _db.insertItem(item);
    await loadItems();
  }

  // Element yangilash
  Future<void> updateItem(CollectionItem item) async {
    await _db.updateItem(item);
    await loadItems();
  }

  // Element o'chirish
  Future<void> deleteItem(int id) async {
    await _db.deleteItem(id);
    await loadItems();
  }
}
