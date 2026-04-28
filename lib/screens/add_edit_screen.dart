import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../providers/collection_provider.dart';
import '../models/item.dart';
import '../models/category.dart';

class AddEditScreen extends StatefulWidget {
  final CollectionItem? item;

  const AddEditScreen({super.key, this.item});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedCategory = 'kitob';
  String? _photoPath;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final item = widget.item!;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      _priceCtrl.text = item.price > 0 ? item.price.toStringAsFixed(0) : '';
      _selectedCategory = item.category;
      _photoPath = item.photoPath;
      _selectedDate = item.createdAt;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile != null) {
      setState(() => _photoPath = xFile.path);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galereya'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading:
                    const Icon(Icons.delete, color: Colors.red),
                title: const Text("Rasmni o'chirish",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<CollectionProvider>();
      final price = double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;

      final item = CollectionItem(
        id: widget.item?.id,
        name: _nameCtrl.text.trim(),
        category: _selectedCategory,
        description: _descCtrl.text.trim(),
        price: price,
        photoPath: _photoPath,
        createdAt: _selectedDate,
      );

      if (isEdit) {
        await provider.updateItem(item);
      } else {
        await provider.addItem(item);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik yuz berdi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(isEdit ? 'Tahrirlash' : "Yangi element"),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Saqlash',
                  style: TextStyle(
                      color: Color(0xFFBA7517),
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Rasm
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  border: Border.all(
                    color: const Color(0xFFDDD8D0),
                    style: _photoPath == null
                        ? BorderStyle.none
                        : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  image: _photoPath != null
                      ? DecorationImage(
                          image: kIsWeb ? NetworkImage(_photoPath!) as ImageProvider : FileImage(File(_photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAEEDA),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                color: Color(0xFFBA7517), size: 24),
                          ),
                          const SizedBox(height: 10),
                          const Text('Rasm qo\'shish',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF854F0B),
                                  fontWeight: FontWeight.w500)),
                          const Text('Kamera yoki galereya',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888680))),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 14),
                              onPressed: _showImageOptions,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Kategoriya tanlash
            const Text('Kategoriya',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555450))),
            const SizedBox(height: 8),
            Row(
              children: categories.map((cat) {
                final sel = _selectedCategory == cat.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: cat == categories.last ? 0 : 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            sel ? cat.lightColor : Colors.white,
                        border: Border.all(
                          color: sel
                              ? cat.color
                              : const Color(0xFFDDD8D0),
                          width: sel ? 2 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(cat.name,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: sel
                                      ? cat.color
                                      : const Color(0xFF666660))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Nomi
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nomi *',
                hintText: "Element nomi",
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nom kiritish majburiy' : null,
            ),

            const SizedBox(height: 12),

            // Tavsif
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tavsif',
                hintText: 'Qisqacha tavsif, yil, holat...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 12),

            // Qiymat
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Qiymat (so'm)",
                hintText: '0',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                suffixText: "so'm",
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final n = double.tryParse(v.replaceAll(' ', ''));
                  if (n == null || n < 0) return "To'g'ri qiymat kiriting";
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Sana
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text("Xarid sanasi"),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),

            const SizedBox(height: 32),

            // Saqlash tugmasi
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEdit ? 'Saqlash' : "Qo'shish"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            if (isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("O'chirish"),
                      content: const Text(
                          "Bu elementni o'chirishni xohlaysizmi?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(_, false),
                            child: const Text('Bekor qilish')),
                        TextButton(
                          onPressed: () => Navigator.pop(_, true),
                          child: const Text("O'chirish",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await context
                        .read<CollectionProvider>()
                        .deleteItem(widget.item!.id!);
                    if (mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("O'chirish",
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
