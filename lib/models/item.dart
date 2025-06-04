import 'item_status.dart';

enum ItemType {
  computer,
  printer,
  network,
  other,
}

enum ItemStatus {
  available,
  inUse,
  maintenance,
  retired,
}

class Item {
  final String itemId;
  final String name;
  final String location;
  final String? description;
  final ItemType type;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.itemId,
    required this.name,
    required this.location,
    this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      type: ItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ItemType.other,
      ),
      status: ItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ItemStatus.available,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'location': location,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 