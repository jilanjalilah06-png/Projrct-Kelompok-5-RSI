class CommodityModel {
  final int id;
  final String name;
  final String cycle;
  final double currentPrice;

  CommodityModel({
    required this.id,
    required this.name,
    required this.cycle,
    required this.currentPrice,
  });

  factory CommodityModel.fromJson(Map<String, dynamic> json) {
    return CommodityModel(
      id: json['id'],
      name: json['name'],
      cycle: json['cycle'],
      currentPrice: json['current_price'].toDouble(),
    );
  }
}
