/// Satu produk di katalog. `sku` dipakai sebagai kunci unik.
class Product {
  Product({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.cost,
    required this.stock,
    this.minStock = 5,
    this.isActive = true,
  });

  final String name;
  final String sku;
  final String category; // 'Kopi' | 'Non-kopi' | 'Makanan'
  final int price; // harga jual (Rp)
  final int cost; // biaya modal (Rp)
  final int minStock;
  int stock;
  bool isActive;

  bool get isOut => stock <= 0;

  /// Stok sudah di batas minimum atau kurang.
  bool get isLow => stock <= minStock;
}
