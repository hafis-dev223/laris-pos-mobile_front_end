import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';

enum _Status { all, success, cancelled }

/// Layar Riwayat transaksi (nomor 8 di desain).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  _Status _status = _Status.all;
  DateTime? _day; // null = semua tanggal
  String? _method; // null = semua metode

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<SaleTransaction> _visible(AppStore store) {
    final q = _search.text.trim().toLowerCase();
    return store.transactions.where((t) {
      if (_day != null && !isSameDay(t.time, _day!)) return false;
      if (_method != null && t.method != _method) return false;
      if (_status == _Status.success && t.cancelled) return false;
      if (_status == _Status.cancelled && !t.cancelled) return false;
      if (q.isNotEmpty) {
        final hit = t.id.toLowerCase().contains(q) ||
            (t.customer ?? '').toLowerCase().contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  /// Kelompokkan per hari, urutan mengikuti data (terbaru dulu).
  List<(DateTime, List<SaleTransaction>)> _group(List<SaleTransaction> list) {
    final groups = <(DateTime, List<SaleTransaction>)>[];
    for (final t in list) {
      if (groups.isNotEmpty && isSameDay(groups.last.$1, t.time)) {
        groups.last.$2.add(t);
      } else {
        groups.add((t.time, [t]));
      }
    }
    return groups;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.brand),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MethodSheet(selected: _method),
    );
    if (result == null) return;
    setState(() => _method = result == 'Semua' ? null : result);
  }

  void _reprint(SaleTransaction t) =>
      showAppToast(context, 'Cetak ulang ${t.id} dibuat di langkah berikutnya.');

  Future<void> _openDetail(SaleTransaction t) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(trx: t),
    );
    if (!mounted || action == null) return;
    if (action == 'print') {
      _reprint(t);
    } else if (action == 'cancel') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Batalkan transaksi?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: Text('${t.id} akan ditandai dibatalkan dan stok produk dikembalikan.',
              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Ya, batalkan'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        AppStore.instance.cancelTransaction(t);
        showAppToast(context, '${t.id} dibatalkan.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: AppStore.instance,
        builder: (context, _) {
          final store = AppStore.instance;
          final items = _visible(store);
          final groups = _group(items);
          final hasFilter = _method != null;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Riwayat transaksi',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    const SizedBox(height: 2),
                    const Text('Semua transaksi, rapi dalam satu tempat',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Cari nomor transaksi atau pelanggan',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.muted),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                          onPressed: () => setState(_search.clear),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _OutlineButton(
                            icon: Icons.calendar_month_outlined,
                            label: _day == null ? 'Semua tanggal' : tanggalSingkat(_day!),
                            trailing: _day == null
                                ? const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.muted)
                                : InkWell(
                              onTap: () => setState(() => _day = null),
                              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.muted),
                            ),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _OutlineButton(
                          icon: Icons.tune_rounded,
                          label: hasFilter ? _method! : 'Filter',
                          highlighted: hasFilter,
                          onTap: _pickFilter,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Chip(
                          label: 'Semua',
                          selected: _status == _Status.all,
                          onTap: () => setState(() => _status = _Status.all),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: 'Berhasil',
                          selected: _status == _Status.success,
                          onTap: () => setState(() => _status = _Status.success),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: 'Dibatalkan',
                          selected: _status == _Status.cancelled,
                          onTap: () => setState(() => _status = _Status.cancelled),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    for (final g in groups) ...[
                      _GroupHeader(day: g.$1, list: g.$2),
                      const SizedBox(height: 10),
                      for (final t in g.$2) ...[
                        _TrxCard(
                          trx: t,
                          onTap: () => _openDetail(t),
                          onReprint: () => _reprint(t),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.day, required this.list});

  final DateTime day;
  final List<SaleTransaction> list;

  @override
  Widget build(BuildContext context) {
    final cancelled = list.where((t) => t.cancelled).length;
    final success = list.length - cancelled;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(labelHari(day), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        Text(
          cancelled == 0 ? '$success berhasil' : '$success berhasil • $cancelled batal',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brand),
        ),
      ],
    );
  }
}

class _TrxCard extends StatelessWidget {
  const _TrxCard({required this.trx, required this.onTap, required this.onReprint});

  final SaleTransaction trx;
  final VoidCallback onTap;
  final VoidCallback onReprint;

  static const _amber = Color(0xFFB7791F);
  static const _amberBg = Color(0xFFFFF4DC);

  @override
  Widget build(BuildContext context) {
    final cancelled = trx.cancelled;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(trx.id,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cancelled ? _amberBg : AppColors.mint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cancelled ? 'Dibatalkan' : 'Berhasil',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cancelled ? _amber : AppColors.brand,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${jam(trx.time)} • ${trx.itemCount} item • ${trx.method}',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  Text(
                    rupiah(trx.total),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: cancelled ? AppColors.muted : AppColors.fg,
                      decoration: cancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Kasir: Nadia${trx.customer == null ? '' : ' • ${trx.customer}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ),
                  if (!cancelled)
                    InkWell(
                      onTap: onReprint,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.print_outlined, size: 13, color: AppColors.brand),
                          SizedBox(width: 4),
                          Text('Cetak ulang',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brand)),
                          Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.brand),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.mint : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: highlighted ? AppColors.brand : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.brand),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.brand : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.white : AppColors.fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodSheet extends StatelessWidget {
  const _MethodSheet({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    const methods = ['Semua', 'Tunai', 'QRIS', 'Kartu'];
    final current = selected ?? 'Semua';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metode pembayaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final m in methods)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(m, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: m == current
                    ? const Icon(Icons.check_rounded, color: AppColors.brand, size: 20)
                    : null,
                onTap: () => Navigator.pop(context, m),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.trx});

  final SaleTransaction trx;

  static const _amber = Color(0xFFB7791F);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(trx.id,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                        if (trx.cancelled)
                          const Text('Dibatalkan',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _amber)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tanggalSingkat(trx.time)} • ${jam(trx.time)} WIB • ${trx.orderType.label}',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    Text('Pelanggan: ${trx.customer ?? 'umum'}',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    if (trx.note.trim().isNotEmpty)
                      Text('Catatan: ${trx.note.trim()}',
                          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 12),
                    for (final l in trx.lines) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.product.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('${l.qty} × ${rupiah(l.product.price)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Text(rupiah(l.total),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 12),
                    _Row('Subtotal', rupiah(trx.subtotal)),
                    const SizedBox(height: 6),
                    _Row('Diskon nominal', trx.discount > 0 ? '-${rupiah(trx.discount)}' : rupiah(0)),
                    const SizedBox(height: 6),
                    _Row('Pajak PB1 (${AppStore.taxPercent}%)', rupiah(trx.tax)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        Text(rupiah(trx.total),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.brand)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Row(trx.method, rupiah(trx.paid)),
                    if (trx.method == 'Tunai') ...[
                      const SizedBox(height: 6),
                      _Row('Kembali', rupiah(trx.change)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    if (!trx.cancelled) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, 'cancel'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          child: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: trx.cancelled ? null : () => Navigator.pop(context, 'print'),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Cetak ulang'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.muted),
          SizedBox(height: 10),
          Text('Transaksi tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('Coba ubah pencarian atau filter.',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}