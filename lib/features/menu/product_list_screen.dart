import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../shared/product_thumb.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _search = TextEditingController();
  String _category = 'Semua';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Produk & menu',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      leading: const BackButton(),
    ),
    body: ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final products = AppStore.instance.products
            .where(
              (p) =>
                  (_category == 'Semua' || p.category == _category) &&
                  (p.name.toLowerCase().contains(_search.text.toLowerCase()) ||
                      p.sku.toLowerCase().contains(_search.text.toLowerCase())),
            )
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari nama produk atau SKU',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final c in AppStore.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ListTile(
                    tileColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    leading: SizedBox(
                      width: 52,
                      height: 52,
                      child: ProductThumb(category: p.category),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${p.sku} • ${p.category}\n${rupiah(p.price)} • Stok ${p.stock}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ProductFormScreen())),
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Tambah produk'),
    ),
  );
}
