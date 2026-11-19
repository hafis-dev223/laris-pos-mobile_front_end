import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';
import '../../data/product.dart';
import '../../shared/product_thumb.dart';
import '../payment/payment_screen.dart';

/// Layar Keranjang (nomor 5 di desain).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: AppStore.instance.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _add(Product p) {
    if (!AppStore.instance.add(p)) {
      showAppToast(context, 'Stok ${p.name} hanya ${p.stock}.');
    }
  }

  Future<void> _editCustomer() async {
    final store = AppStore.instance;
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _PromptDialog(
        title: 'Nama pelanggan',
        hint: 'Contoh: Budi',
        initial: store.customer ?? '',
      ),
    );
    if (result == null) return;
    store.setCustomer(result);
  }

  Future<void> _editDiscount() async {
    final store = AppStore.instance;
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _PromptDialog(
        title: 'Diskon nominal',
        hint: '0',
        prefix: 'Rp ',
        numeric: true,
        initial: store.discount == 0 ? '' : '${store.discount}',
      ),
    );
    if (result == null || !mounted) return;
    final value = int.tryParse(result.trim()) ?? 0;
    if (value > store.cartSubtotal) {
      showAppToast(context, 'Diskon tidak boleh melebihi subtotal.');
      store.setDiscount(store.cartSubtotal);
      return;
    }
    store.setDiscount(value);
  }

  void _checkout() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListenableBuilder(
              listenable: AppStore.instance,
              builder: (context, _) {
                final store = AppStore.instance;
                final lines = store.cartLines;

                return Column(
                  children: [
                    _Header(
                      subtitle: '${store.cartItemCount} item • ${store.orderType.label}',
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: lines.isEmpty
                          ? _EmptyCart(onBack: () => Navigator.of(context).maybePop())
                          : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          _CustomerRow(name: store.customer, onTap: _editCustomer),
                          const SizedBox(height: 12),
                          for (final l in lines) ...[
                            _CartItemTile(
                              line: l,
                              onAdd: () => _add(l.product),
                              onRemove: () => store.remove(l.product),
                              onDelete: () => store.removeAll(l.product),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 2),
                          TextField(
                            controller: _note,
                            onChanged: store.setNote,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Catatan untuk kasir, tanpa gula dst.',
                              prefixIcon: Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SummaryCard(store: store, onEditDiscount: _editDiscount),
                        ],
                      ),
                    ),
                    if (lines.isNotEmpty) _CheckoutBar(onTap: _checkout),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keranjang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.name, required this.onTap});

  final String? name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.brand),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name ?? 'Tambah pelanggan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.brand),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.line,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  final CartLine line;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = line.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: ProductThumb(category: p.category, iconSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text('${rupiah(p.price)} / item',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus dari keranjang',
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _StepButton(icon: Icons.remove_rounded, onTap: onRemove),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${line.qty}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                  _StepButton(icon: Icons.add_rounded, onTap: onAdd),
                ],
              ),
              Text(rupiah(line.total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.brand.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 18, color: AppColors.brand),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.store, required this.onEditDiscount});

  final AppStore store;
  final VoidCallback onEditDiscount;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = store.discount > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal (${store.cartItemCount} item)', value: rupiah(store.cartSubtotal)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Diskon nominal',
            value: hasDiscount ? '-${rupiah(store.discount)}' : rupiah(0),
            valueColor: hasDiscount ? AppColors.brand : null,
            onEdit: onEditDiscount,
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Pajak PB1 (${AppStore.taxPercent}%)', value: rupiah(store.cartTax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Text(
                rupiah(store.cartTotal),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.brand),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueColor, this.onEdit});

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        if (onEdit != null) ...[
          const SizedBox(width: 6),
          const Icon(Icons.edit_outlined, size: 14, color: AppColors.brand),
        ],
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        onEdit == null
            ? labelWidget
            : InkWell(borderRadius: BorderRadius.circular(6), onTap: onEdit, child: labelWidget),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.fg),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: onTap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, size: 18),
                SizedBox(width: 8),
                Text('Lanjut pembayaran'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Pajak dihitung setelah diskon.',
              style: TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.muted),
            const SizedBox(height: 12),
            const Text('Keranjang masih kosong', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Pilih produk di halaman Kasir dulu.',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 20),
            FilledButton(onPressed: onBack, child: const Text('Kembali ke kasir')),
          ],
        ),
      ),
    );
  }
}

/// Dialog satu kolom isian (nama pelanggan / diskon).
class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.hint,
    required this.initial,
    this.prefix,
    this.numeric = false,
  });

  final String title;
  final String hint;
  final String initial;
  final String? prefix;
  final bool numeric;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_ctrl.text);

  @override
  Widget build(BuildContext context) {
    const actionPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: widget.numeric ? TextInputType.number : TextInputType.text,
        textCapitalization: widget.numeric ? TextCapitalization.none : TextCapitalization.words,
        inputFormatters: widget.numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(hintText: widget.hint, prefixText: widget.prefix),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: actionPadding, foregroundColor: AppColors.muted),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: actionPadding),
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}