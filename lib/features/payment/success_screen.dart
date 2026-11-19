import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';

/// Layar Transaksi berhasil + struk (nomor 7 di desain).
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.trx});

  final SaleTransaction trx;

  void _newTransaction(BuildContext context) {
    // Kembali ke kerangka utama (tab Kasir) dengan keranjang kosong.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isCash = trx.method == 'Tunai';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _Header(onBack: () => _newTransaction(context)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      _SuccessBanner(
                        title: 'Pembayaran diterima!',
                        detail: isCash
                            ? 'Kembali pelanggan ${rupiah(trx.change)}'
                            : 'Dibayar lewat ${trx.method}',
                      ),
                      const SizedBox(height: 14),
                      _Receipt(trx: trx),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => showAppToast(context, 'Pencetakan struk dibuat di langkah berikutnya.'),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.print_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Cetak struk'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => showAppToast(context, 'Fitur bagikan dibuat di langkah berikutnya.'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                foregroundColor: AppColors.fg,
                                side: const BorderSide(color: AppColors.line),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.ios_share_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Bagikan'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 7, color: AppColors.brand),
                          SizedBox(width: 6),
                          Text('Printer Senja-01 terhubung • Kertas 58 mm',
                              style: TextStyle(fontSize: 10, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: FilledButton(
                    onPressed: () => _newTransaction(context),
                    child: const Text('Transaksi baru'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

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
          const Text('Transaksi berhasil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brand.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.check_rounded, size: 20, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.trx});

  final SaleTransaction trx;

  static const _mono = TextStyle(fontSize: 11);

  @override
  Widget build(BuildContext context) {
    final hasDiscount = trx.discount > 0;
    final isCash = trx.method == 'Tunai';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.local_cafe_outlined, size: 20, color: AppColors.brand),
                SizedBox(height: 4),
                Text('KOPI SENJA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                SizedBox(height: 3),
                Text('Jl. Meduti No. 18, Bandung',
                    style: TextStyle(fontSize: 10, color: AppColors.muted)),
                Text('Telp: 0812-3456-7890', style: TextStyle(fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          const _Dashed(),
          Text(trx.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            '${tanggalSingkat(trx.time)} • ${jam(trx.time)} WIB • Kasir: Nadia',
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            '${trx.orderType.label} • Pelanggan: ${trx.customer ?? 'umum'}',
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          if (trx.note.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('Catatan: ${trx.note.trim()}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
          const _Dashed(),
          for (final l in trx.lines) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(l.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _mono.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(rupiah(l.total), style: _mono.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 2),
            Text('${l.qty} × ${rupiah(l.product.price)}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            const SizedBox(height: 8),
          ],
          const _Dashed(),
          _Line('Subtotal', rupiah(trx.subtotal)),
          const SizedBox(height: 6),
          _Line('Diskon nominal', hasDiscount ? '-${rupiah(trx.discount)}' : rupiah(0)),
          const SizedBox(height: 6),
          _Line('Pajak PB1 (${AppStore.taxPercent}%)', rupiah(trx.tax)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Text(rupiah(trx.total),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.brand)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${trx.method}: ${rupiah(trx.paid)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted)),
              if (isCash)
                Text('Kembali: ${rupiah(trx.change)}',
                    style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const _Dashed(),
          const Center(
            child: Column(
              children: [
                Text('Terima kasih! Sampai jumpa lagi di Kopi Senja.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.muted)),
                SizedBox(height: 2),
                Text('@kopisenja.id', style: TextStyle(fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Garis putus-putus pemisah bagian struk.
class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          final count = (c.maxWidth / 6).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
                  (_) => const SizedBox(width: 3, height: 1, child: ColoredBox(color: AppColors.line)),
            ),
          );
        },
      ),
    );
  }
}