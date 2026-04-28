class CollectionItem {
  final int? id;
  final String name;
  final String category; // kitob, marka, tanga, figura
  final String description;
  final double price;
  final String? photoPath;
  final DateTime createdAt;

  CollectionItem({
    this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.price = 0.0,
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CollectionItem.fromMap(Map<String, dynamic> map) {
    return CollectionItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      photoPath: map['photo_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  CollectionItem copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    double? price,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
