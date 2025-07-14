class Present {
  final String name;
  final double price;
  final String imagePath;
  final int quantity;
  final String category;

  Present({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.category,
  });

  static Present fromJson(Map<String, dynamic> json) {
    return Present(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      imagePath: json['imagePath'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
      'category': category,
    };
  }

  factory Present.fromMap(Map<String, dynamic> map) {
    return Present(
      name: map['name'],
      price: (map['price'] ?? 0.0).toDouble(),
      imagePath: map['imagePath'],
      quantity: map['quantity'],
      category: map['category'],
    );
  }
}