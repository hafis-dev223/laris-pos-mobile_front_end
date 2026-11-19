import 'package:flutter/foundation.dart';

import '../core/format.dart';
import 'product.dart';

enum OrderType {
  dineIn('Makan di tempat'),
  takeaway('Bawa pulang');

  const OrderType(this.label);
  final String label;
}

class CartLine {
  const CartLine(this.product, this.qty);
  final Product product;
  final int qty;
  int get total => product.price * qty;
}

class SaleTransaction {
  SaleTransaction({
    required this.id,
    required this.time,
    required this.lines,
    required this.orderType,
    required this.customer,
    required this.note,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.method,
    required this.paid,
    this.cancelled = false,
  });

  final String id;
  final DateTime time;
  final List<CartLine> lines;
  final OrderType orderType;
  final String? customer;
  final String note;
  final int subtotal;
  final int discount;
  final int tax;
  final int total;
  final String method; // 'Tunai' | 'QRIS' | 'Kartu'
  final int paid;
  bool cancelled; // true kalau transaksi dibatalkan

  int get change => paid - total;
  int get itemCount => lines.fold(0, (a, l) => a + l.qty);
}

/// Penyimpan data aplikasi (produk + keranjang) yang dipakai bersama semua layar.
/// Layar cukup memakai `ListenableBuilder(listenable: AppStore.instance, ...)`.
class AppStore extends ChangeNotifier {
  AppStore._() {
    _seed();
  }
  static final AppStore instance = AppStore._();

  static const categories = ['Semua', 'Kopi', 'Non-kopi', 'Makanan'];

  /// Data contoh. Nanti diganti database lokal (Isar/SQLite) atau API.
  final List<Product> products = [
    Product(
      name: 'Kopi Susu Senja',
      sku: 'KOP-001',
      category: 'Kopi',
      price: 28000,
      cost: 11000,
      stock: 32,
    ),
    Product(
      name: 'Butter Croissant',
      sku: 'MKN-001',
      category: 'Makanan',
      price: 22000,
      cost: 9000,
      stock: 4,
    ),
    Product(
      name: 'Americano',
      sku: 'KOP-002',
      category: 'Kopi',
      price: 22000,
      cost: 8000,
      stock: 28,
    ),
    Product(
      name: 'Matcha Latte',
      sku: 'NON-001',
      category: 'Non-kopi',
      price: 32000,
      cost: 14000,
      stock: 18,
    ),
    Product(
      name: 'Cappuccino',
      sku: 'KOP-003',
      category: 'Kopi',
      price: 30000,
      cost: 12000,
      stock: 25,
    ),
    Product(
      name: 'Es Kopi Aren',
      sku: 'KOP-004',
      category: 'Kopi',
      price: 26000,
      cost: 10000,
      stock: 20,
    ),
    Product(
      name: 'Latte',
      sku: 'KOP-005',
      category: 'Kopi',
      price: 30000,
      cost: 12000,
      stock: 15,
    ),
    Product(
      name: 'Coklat Panas',
      sku: 'NON-002',
      category: 'Non-kopi',
      price: 27000,
      cost: 11000,
      stock: 14,
    ),
    Product(
      name: 'Lemon Tea',
      sku: 'NON-003',
      category: 'Non-kopi',
      price: 20000,
      cost: 7000,
      stock: 30,
    ),
    Product(
      name: 'Pain au Chocolat',
      sku: 'MKN-002',
      category: 'Makanan',
      price: 24000,
      cost: 10000,
      stock: 5,
    ),
    Product(
      name: 'Roti Bakar Coklat',
      sku: 'MKN-003',
      category: 'Makanan',
      price: 18000,
      cost: 7000,
      stock: 16,
    ),
    Product(
      name: 'Kentang Goreng',
      sku: 'MKN-004',
      category: 'Makanan',
      price: 20000,
      cost: 8000,
      stock: 5,
    ),
  ];

  // sku -> jumlah
  final Map<String, int> _cart = {};
  OrderType _orderType = OrderType.dineIn;

  OrderType get orderType => _orderType;

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  // ---- Data pesanan yang sedang berjalan (dipakai layar Keranjang & Pembayaran) ----

  /// Pajak PB1 dalam persen, dihitung setelah diskon.
  static const taxPercent = 10;

  /// Urutan transaksi hari ini (diatur ulang di _seed mengikuti data contoh).
  int _seq = 1;

  static String _idFor(DateTime n, int seq) {
    String d(int v) => v.toString().padLeft(2, '0');
    return '#KS-${d(n.day)}${d(n.month)}${d(n.year % 100)}-${seq.toString().padLeft(3, '0')}';
  }

  /// Nomor pesanan yang sedang berjalan, contoh: #KS-111126-004.
  String get orderNumber => _idFor(DateTime.now(), _seq);

  /// Riwayat transaksi yang sudah dibayar, yang terbaru di urutan pertama.
  final List<SaleTransaction> transactions = [];

  // ---- Statistik (dihitung dari riwayat transaksi) ----

  List<SaleTransaction> transactionsOn(DateTime day) => transactions
      .where((t) => isSameDay(t.time, day) && !t.cancelled)
      .toList();

  int get todaySales =>
      transactionsOn(DateTime.now()).fold(0, (a, t) => a + t.total);

  int get todayCount => transactionsOn(DateTime.now()).length;

  /// Pertumbuhan penjualan dibanding kemarin (%). Null kalau kemarin kosong.
  double? get salesGrowth {
    final y = transactionsOn(DateTime.now().subtract(const Duration(days: 1)))
        .fold<int>(0, (a, t) => a + t.total);
    if (y == 0) return null;
    return (todaySales - y) / y * 100;
  }

  /// Data contoh supaya Beranda & Riwayat tidak kosong. Hapus kalau sudah ada database.
  void _seed() {
    final now = DateTime.now();
    Product p(String sku) => products.firstWhere((x) => x.sku == sku);

    SaleTransaction demo(
      DateTime t,
      int seq,
      List<(String, int)> items,
      String method,
    ) {
      final lines = [for (final (sku, q) in items) CartLine(p(sku), q)];
      final sub = lines.fold(0, (a, l) => a + l.total);
      final tax = (sub * taxPercent / 100).round();
      final total = sub + tax;
      return SaleTransaction(
        id: _idFor(t, seq),
        time: t,
        lines: lines,
        orderType: OrderType.dineIn,
        customer: null,
        note: '',
        subtotal: sub,
        discount: 0,
        tax: tax,
        total: total,
        method: method,
        paid: method == 'Tunai' ? ((total + 9999) ~/ 10000) * 10000 : total,
      );
    }

    DateTime yesterday(int h, int m) {
      final d = now.subtract(const Duration(days: 1));
      return DateTime(d.year, d.month, d.day, h, m);
    }

    final seeds = [
      demo(now.subtract(const Duration(minutes: 95)), 1, [
        ('KOP-001', 2),
        ('MKN-001', 1),
      ], 'Tunai'),
      demo(now.subtract(const Duration(minutes: 60)), 2, [
        ('KOP-002', 1),
        ('NON-001', 1),
      ], 'QRIS'),
      demo(now.subtract(const Duration(minutes: 25)), 3, [
        ('KOP-003', 2),
        ('MKN-002', 2),
        ('NON-003', 1),
      ], 'Kartu'),
      demo(yesterday(9, 12), 1, [('KOP-004', 2), ('MKN-003', 1)], 'Tunai'),
      demo(yesterday(13, 40), 2, [('KOP-005', 1), ('NON-002', 1)], 'QRIS'),
      demo(yesterday(16, 5), 3, [('KOP-001', 3), ('MKN-004', 2)], 'Tunai'),
    ]..sort((a, b) => b.time.compareTo(a.time));

    // Data contoh 2-6 hari lalu supaya Laporan punya grafik 7 hari.
    const combos = [
      [('KOP-001', 2), ('MKN-001', 1)],
      [('KOP-002', 1), ('NON-001', 1), ('MKN-003', 1)],
      [('KOP-003', 2), ('MKN-002', 1)],
      [('KOP-004', 3), ('NON-003', 1)],
      [('KOP-005', 1), ('NON-002', 2), ('MKN-004', 1)],
    ];
    const methods = ['Tunai', 'QRIS', 'Kartu'];
    final past = <SaleTransaction>[];
    for (var d = 2; d <= 6; d++) {
      final count = 3 + (d % 3); // 3-5 transaksi per hari
      final base = now.subtract(Duration(days: d));
      for (var k = 0; k < count; k++) {
        final t = DateTime(
          base.year,
          base.month,
          base.day,
          8 + k * 2 + (d % 2),
          5 + d * 7,
        );
        past.add(
          demo(
            t,
            k + 1,
            combos[(d + k) % combos.length],
            methods[(d + k) % methods.length],
          ),
        );
      }
    }

    transactions.addAll(seeds);
    transactions.addAll(past);
    transactions.sort((a, b) => b.time.compareTo(a.time));
    _seq = 4; // transaksi hari ini berikutnya = #004
  }

  /// Batalkan transaksi: tandai batal dan kembalikan stok.
  void cancelTransaction(SaleTransaction t) {
    if (t.cancelled) return;
    t.cancelled = true;
    for (final l in t.lines) {
      l.product.stock += l.qty;
    }
    notifyListeners();
  }

  /// Selesaikan pesanan: simpan transaksi, kurangi stok, kosongkan keranjang.
  SaleTransaction checkout({required String method, required int paid}) {
    final trx = SaleTransaction(
      id: orderNumber,
      time: DateTime.now(),
      lines: List.unmodifiable(cartLines),
      orderType: _orderType,
      customer: _customer,
      note: _note,
      subtotal: cartSubtotal,
      discount: discount,
      tax: cartTax,
      total: cartTotal,
      method: method,
      paid: paid,
    );
    for (final l in trx.lines) {
      l.product.stock -= l.qty;
    }
    transactions.insert(0, trx);
    _seq++;
    clearCart(); // sekalian notifyListeners()
    return trx;
  }

  String? _customer;
  String _note = '';
  int _discount = 0;

  String? get customer => _customer;
  String get note => _note;

  /// Diskon nominal (Rp), tidak pernah melebihi subtotal.
  int get discount => _discount.clamp(0, cartSubtotal);

  int get cartTax => ((cartSubtotal - discount) * taxPercent / 100).round();

  int get cartTotal => cartSubtotal - discount + cartTax;

  void setCustomer(String? name) {
    final v = name?.trim() ?? '';
    _customer = v.isEmpty ? null : v;
    notifyListeners();
  }

  void setNote(String value) {
    _note = value;
    notifyListeners();
  }

  void setDiscount(int value) {
    _discount = value < 0 ? 0 : value;
    notifyListeners();
  }

  /// Produk yang stoknya sudah menipis, yang paling sedikit di urutan pertama.
  List<Product> get lowStock =>
      (products.where((p) => p.isLow).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock)));

  int qty(Product p) => _cart[p.sku] ?? 0;

  int get cartItemCount => _cart.values.fold(0, (a, b) => a + b);

  List<CartLine> get cartLines => [
    for (final p in products)
      if (qty(p) > 0) CartLine(p, qty(p)),
  ];

  int get cartSubtotal => cartLines.fold(0, (sum, l) => sum + l.total);

  /// Tambah 1 ke keranjang. Mengembalikan false kalau stok tidak cukup.
  bool add(Product p) {
    if (qty(p) >= p.stock) return false;
    _cart[p.sku] = qty(p) + 1;
    notifyListeners();
    return true;
  }

  void remove(Product p) {
    final q = qty(p);
    if (q <= 1) {
      _cart.remove(p.sku);
    } else {
      _cart[p.sku] = q - 1;
    }
    notifyListeners();
  }

  /// Hapus produk ini dari keranjang (semua jumlahnya).
  void removeAll(Product p) {
    _cart.remove(p.sku);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _discount = 0;
    _customer = null;
    _note = '';
    notifyListeners();
  }

  bool addProduct({
    required String name,
    required String sku,
    required String category,
    required int price,
    required int cost,
    required int stock,
    required int minStock,
    bool isActive = true,
  }) {
    if (products.any((p) => p.sku.toLowerCase() == sku.toLowerCase())) {
      return false;
    }
    products.add(
      Product(
        name: name,
        sku: sku,
        category: category,
        price: price,
        cost: cost,
        stock: stock,
        minStock: minStock,
        isActive: isActive,
      ),
    );
    notifyListeners();
    return true;
  }
}
