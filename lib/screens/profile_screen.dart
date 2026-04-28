import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('userName') ?? '';
      _emailCtrl.text = prefs.getString('userEmail') ?? '';
      _passwordCtrl.text = prefs.getString('userPassword') ?? '';
      _profileImagePath = prefs.getString('profileImage');
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameCtrl.text.trim());
    await prefs.setString('userEmail', _emailCtrl.text.trim());
    await prefs.setString('userPassword', _passwordCtrl.text);
    if (_profileImagePath != null) {
      await prefs.setString('profileImage', _profileImagePath!);
    }

    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ma'lumotlar saqlandi! O'zgarishlarni ko'rish uchun ilovani yangilang.")),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
      (route) => false,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _profileImagePath = xFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        title: const Text("Mening Profilim"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFBA7517),
                      backgroundImage: _profileImagePath != null 
                        ? FileImage(File(_profileImagePath!)) 
                        : null,
                      child: _profileImagePath == null 
                        ? const Icon(Icons.person, size: 50, color: Colors.white) 
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Color(0xFFBA7517)),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Name field
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ism',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ismni kiriting' : null,
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Pochta',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Pochtani kiriting';
                  if (!v.contains('@')) return 'To\'g\'ri pochta kiriting';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Parol',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) return 'Parol kamida 6 ta belgi bo\'lishi kerak';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Theme Switcher
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Card(
                    child: SwitchListTile(
                      title: const Text("Tungi rejim (Dark Mode)"),
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: const Color(0xFFBA7517),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (v) => themeProvider.toggleTheme(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Saqlash",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Logout button
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Akkauntdan chiqish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
