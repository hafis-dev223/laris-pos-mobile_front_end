import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();
  final _minimum = TextEditingController(text: '5');
  String _category = 'Kopi';
  bool _isActive = true;

  @override
  void dispose() {
    for (final c in [_name, _sku, _price, _cost, _stock, _minimum]) {
      c.dispose();
    }
    super.dispose();
  }

  int _number(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  void _save() {
    if (!_form.currentState!.validate()) return;
    final ok = AppStore.instance.addProduct(
      name: _name.text.trim(),
      sku: _sku.text.trim().toUpperCase(),
      category: _category,
      price: _number(_price),
      cost: _number(_cost),
      stock: _number(_stock),
      minStock: _number(_minimum),
      isActive: _isActive,
    );
    if (!ok) {
      showAppToast(context, 'SKU sudah digunakan. Gunakan SKU lain.');
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Tambah produk',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      leading: const BackButton(),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showAppToast(
                context,
                'Unggah foto produk dibuat di langkah berikutnya.',
              ),
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.brand,
                      size: 28,
                    ),
                    SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambahkan foto produk',
                          style: TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'JPG / PNG • Maks. 5 MB',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _field('Nama produk', _name, validator: _required),
          Row(
            children: [
              Expanded(child: _dropdown()),
              const SizedBox(width: 10),
              Expanded(
                child: _field('SKU / Barcode', _sku, validator: _required),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Harga jual',
                  _price,
                  keyboard: TextInputType.number,
                  validator: _required,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Biaya modal',
                  _cost,
                  keyboard: TextInputType.number,
                  validator: _required,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Stok awal',
                  _stock,
                  keyboard: TextInputType.number,
                  validator: _required,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Stok minimum',
                  _minimum,
                  keyboard: TextInputType.number,
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ActiveProductToggle(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Simpan produk'),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    ),
  );
  Widget _dropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: const InputDecoration(labelText: 'Kategori'),
      items: [
        for (final c in AppStore.categories.skip(1))
          DropdownMenuItem(value: c, child: Text(c)),
      ],
      onChanged: (v) => setState(() => _category = v!),
    ),
  );
}

class _ActiveProductToggle extends StatelessWidget {
  const _ActiveProductToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.brand),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk aktif',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Tampilkan produk di menu kasir',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
