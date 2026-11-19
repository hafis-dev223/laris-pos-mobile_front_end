import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';

const _hariSingkat = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

class _DayStat {
  const _DayStat(this.day, this.total, this.count);
  final DateTime day;
  final int total;
  final int count;
}

class _ProductStat {
  _ProductStat(this.name);
  final String name;
  int qty = 0;
  int revenue = 0;
}

/// Layar Laporan penjualan (nomor 9 di desain).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _ranges = [7, 14, 30];

  int _days = 7;
  int? _selected; // index batang yang dipilih; null = hari terakhir
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: AppStore.instance,
        builder: (context, _) {
          final store = AppStore.instance;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          DateTime dayAt(int back) => DateTime(today.year, today.month, today.day - back);

          final start = dayAt(_days - 1);
          final prevStart = dayAt(_days * 2 - 1);
          final active = store.transactions.where((t) => !t.cancelled).toList();

          // Periode ini & periode sebelumnya (untuk persentase pertumbuhan).
          final current = active.where((t) => !t.time.isBefore(start)).toList();
          final previous =
          active.where((t) => !t.time.isBefore(prevStart) && t.time.isBefore(start)).toList();

          final total = current.fold<int>(0, (a, t) => a + t.total);
          final prevTotal = previous.fold<int>(0, (a, t) => a + t.total);
          final growth = prevTotal == 0 ? null : (total - prevTotal) / prevTotal * 100;
          final avg = current.isEmpty ? 0 : (total / current.length).round();

          // Statistik per hari untuk grafik.
          final stats = <_DayStat>[
            for (var i = _days - 1; i >= 0; i--)
                  () {
                final d = dayAt(i);
                final list = current.where((t) => isSameDay(t.time, d)).toList();
                return _DayStat(d, list.fold<int>(0, (a, t) => a + t.total), list.length);
              }(),
          ];
          final selectedIndex = (_selected ?? stats.length - 1).clamp(0, stats.length - 1);

          // Produk terlaris.
          final map = <String, _ProductStat>{};
          for (final t in current) {
            for (final l in t.lines) {
              final s = map.putIfAbsent(l.product.sku, () => _ProductStat(l.product.name));
              s.qty += l.qty;
              s.revenue += l.total;
            }
          }
          final top = map.values.toList()..sort((a, b) => b.revenue.compareTo(a.revenue));
          final shown = top.take(_showAll ? 8 : 3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Laporan penjualan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                const SizedBox(height: 2),
                const Text('Kenali performa usaha Anda',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 16),
                _RangeBar(
                  label: '${tanggalSingkat(start)} – ${tanggalSingkat(today)}',
                  days: _days,
                  ranges: _ranges,
                  onSelected: (v) => setState(() {
                    _days = v;
                    _selected = null;
                  }),
                ),
                const SizedBox(height: 12),
                _OmzetCard(
                  total: total,
                  growth: growth,
                  count: current.length,
                  avg: avg,
                ),
                const SizedBox(height: 14),
                _TrendCard(
                  stats: stats,
                  selected: selectedIndex,
                  onSelect: (i) => setState(() => _selected = i),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Produk terlaris',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          if (top.length > 3)
                            TextButton(
                              onPressed: () => setState(() => _showAll = !_showAll),
                              child: Text(_showAll ? 'Ringkas' : 'Lihat semua'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (shown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('Belum ada penjualan di periode ini.',
                                style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          ),
                        ),
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) const Divider(height: 18, color: AppColors.line),
                        _TopRow(rank: i + 1, stat: shown[i]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => showAppToast(context, 'Ekspor PDF / Excel dibuat di langkah berikutnya.'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.brand,
                    side: const BorderSide(color: AppColors.line),
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Ekspor laporan • PDF / Excel'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.label,
    required this.days,
    required this.ranges,
    required this.onSelected,
  });

  final String label;
  final int days;
  final List<int> ranges;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          PopupMenuButton<int>(
            initialValue: days,
            onSelected: onSelected,
            itemBuilder: (_) => [
              for (final r in ranges) PopupMenuItem(value: r, child: Text('$r hari terakhir')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$days hari terakhir',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brand)),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.brand),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OmzetCard extends StatelessWidget {
  const _OmzetCard({
    required this.total,
    required this.growth,
    required this.count,
    required this.avg,
  });

  final int total;
  final double? growth;
  final int count;
  final int avg;

  @override
  Widget build(BuildContext context) {
    final up = (growth ?? 0) >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total omzet', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              if (growth != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 15, color: up ? AppColors.brand : AppColors.danger),
                    const SizedBox(width: 4),
                    Text(persen(growth!),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: up ? AppColors.brand : AppColors.danger)),
                  ],
                )
              else
                const Text('Belum ada pembanding',
                    style: TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(rupiah(total),
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.brand, letterSpacing: -0.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Transaksi berhasil', value: '$count')),
              Expanded(child: _MiniStat(label: 'Rata-rata transaksi', value: rupiah(avg))),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.stats, required this.selected, required this.onSelect});

  final List<_DayStat> stats;
  final int selected;
  final ValueChanged<int> onSelect;

  static const _barOff = Color(0xFFB9DDD5);

  @override
  Widget build(BuildContext context) {
    final maxTotal = stats.fold<int>(0, (m, s) => s.total > m ? s.total : m);
    final step = (stats.length / 7).ceil(); // jarang-jarangkan label kalau batang banyak
    final sel = stats[selected];
    final gap = stats.length > 14 ? 2.0 : 6.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tren penjualan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              Text('Harian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brand)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < stats.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: gap / 2),
                        child: Column(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: maxTotal == 0
                                      ? 0.02
                                      : (stats[i].total / maxTotal).clamp(0.02, 1.0),
                                  widthFactor: 1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: i == selected ? AppColors.brand : _barOff,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 12,
                              child: OverflowBox(
                                maxWidth: 40,
                                child: Text(
                                  (stats.length - 1 - i) % step == 0
                                      ? (stats.length <= 7
                                      ? _hariSingkat[stats[i].day.weekday - 1]
                                      : '${stats[i].day.day}')
                                      : '',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: i == selected ? FontWeight.w800 : FontWeight.w500,
                                    color: i == selected ? AppColors.brand : AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Text(
            '${tanggalSingkat(sel.day)}: ${rupiah(sel.total)} • ${sel.count} transaksi',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.rank, required this.stat});

  final int rank;
  final _ProductStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rank == 1 ? AppColors.brand : AppColors.mint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('$rank',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: rank == 1 ? Colors.white : AppColors.brand)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${stat.qty} terjual', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(rupiah(stat.revenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }
}