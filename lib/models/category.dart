import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Color lightColor;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.lightColor,
  });
}

const List<Category> categories = [
  Category(
    id: 'kitob',
    name: 'Kitob',
    emoji: '📚',
    color: Color(0xFF185FA5),
    lightColor: Color(0xFFE6F1FB),
  ),
  Category(
    id: 'marka',
    name: 'Marka',
    emoji: '📬',
    color: Color(0xFF3B6D11),
    lightColor: Color(0xFFEAF3DE),
  ),
  Category(
    id: 'tanga',
    name: 'Tanga',
    emoji: '🪙',
    color: Color(0xFF854F0B),
    lightColor: Color(0xFFFAEEDA),
  ),
  Category(
    id: 'figura',
    name: 'Figura',
    emoji: '🌎',
    color: Color(0xFF993556),
    lightColor: Color(0xFFFBEAF0),
  ),
];

Category getCategoryById(String id) {
  return categories.firstWhere(
    (c) => c.id == id,
    orElse: () => categories.first,
  );
}
