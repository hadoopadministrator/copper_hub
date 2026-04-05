class CartItemModel {
  final int cartId;
  final int userId;
  final int slabId;
  final String slabName;
  final double minWeight;
  final double maxWeight;
  final double pricePerKg;
  final int quantity;
  final double totalAmount;
  final String addedOn;

  CartItemModel({
    required this.cartId,
    required this.userId,
    required this.slabId,
    required this.slabName,
    required this.minWeight,
    required this.maxWeight,
    required this.pricePerKg,
    required this.quantity,
    required this.totalAmount,
    required this.addedOn,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: json['CartID'] ?? 0,
      userId: json['UserID'] ?? 0,
      slabId: json['SlabId'] ?? 0,
      slabName: json['SlabName'] ?? '',
      minWeight: (json['MinWeight'] as num?)?.toDouble() ?? 0.0,
      maxWeight: (json['MaxWeight'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['PricePerKg'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['Quantity'] as num?)?.toInt() ?? 0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
      addedOn: json['AddedOn'] ?? '',
    );
  }

  CartItemModel copyWith({int? quantity, double? totalAmount}) {
    return CartItemModel(
      cartId: cartId,
      userId: userId,
      slabId: slabId,
      slabName: slabName,
      minWeight: minWeight,
      maxWeight: maxWeight,
      pricePerKg: pricePerKg,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      addedOn: addedOn,
    );
  }
}
