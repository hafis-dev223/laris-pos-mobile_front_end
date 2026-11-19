import 'package:flutter/material.dart';

/// Gambar produk sementara (warna + ikon per kategori).
/// Kalau sudah ada foto asli, ganti isinya dengan Image.asset / Image.network.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.category, this.iconSize = 44});

  final String category;
  final double iconSize;

  (Color, Color, IconData) _style() => switch (category) {
    'Kopi' => (const Color(0xFFEADBC8), const Color(0xFF8A5A33), Icons.coffee_rounded),
    'Non-kopi' => (const Color(0xFFDCEBDD), const Color(0xFF4E8A5E), Icons.emoji_food_beverage_rounded),
    _ => (const Color(0xFFF5E1C0), const Color(0xFFC27D2B), Icons.bakery_dining_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, Color.lerp(bg, Colors.white, 0.55)!],
        ),
      ),
      child: Center(child: Icon(icon, size: iconSize, color: fg)),
    );
  }
}