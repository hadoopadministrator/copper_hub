class CartItemModel {
  final int cartId;
  final int userId;
  final int slabId;

  final String slabName;
  final int minWeight;
  final int maxWeight;

  final double pricePerKg;
  final double quantity;
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

  /// FROM API
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: json['CartID'] ?? 0,
      userId: json['UserID'] ?? 0,
      slabId: json['SlabId'] ?? 0,

      slabName: json['SlabName'] ?? '',
      minWeight: json['MinWeight'] ?? 0,
      maxWeight: json['MaxWeight'] ?? 0,

      pricePerKg:
          (json['PricePerKg'] as num?)?.toDouble() ?? 0.0,

      quantity:
          (json['Quantity'] as num?)?.toDouble() ?? 0.0,

      totalAmount:
          (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,

      addedOn: json['AddedOn'] ?? '',
    );
  }

  /// OPTIONAL (update locally if needed)
  CartItemModel copyWith({
    double? quantity,
  }) {
    final newQty = quantity ?? this.quantity;

    return CartItemModel(
      cartId: cartId,
      userId: userId,
      slabId: slabId,
      slabName: slabName,
      minWeight: minWeight,
      maxWeight: maxWeight,
      pricePerKg: pricePerKg,
      quantity: newQty,
      totalAmount: pricePerKg * newQty,
      addedOn: addedOn,
    );
  }
}
