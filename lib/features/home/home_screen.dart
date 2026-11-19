import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';

/// Layar Beranda (nomor 3 di desain).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  /// Pindah tab bottom bar: 0 Beranda, 1 Kasir, 2 Riwayat, 3 Laporan, 4 Menu.
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final low = store.lowStock;
        final growth = store.salesGrowth;
        final recent = store.transactions.take(3).toList();

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  subtitle: 'Halo, Nadia • ${tanggalLengkap(DateTime.now())}',
                  onBell: () => showAppToast(context, 'Belum ada notifikasi baru.'),
                ),
                const SizedBox(height: 18),
                _SalesCard(amount: store.todaySales, growth: growth == null ? null : persen(growth)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(label: 'Transaksi', value: '${store.todayCount}', icon: Icons.receipt_long_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Jumlah produk',
                        value: '${store.products.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                ),
                if (low.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LowStockBanner(
                    count: low.length,
                    detail: '${low.first.name} tersisa ${low.first.stock} • Cek stok sekarang',
                    onTap: () => onNavigate(4),
                  ),
                ],
                const SizedBox(height: 22),
                const _SectionTitle('Akses cepat'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _QuickItem(label: 'Kasir', icon: Icons.shopping_bag_outlined, onTap: () => onNavigate(1))),
                    Expanded(child: _QuickItem(label: 'Produk', icon: Icons.inventory_2_outlined, onTap: () => onNavigate(4))),
                    Expanded(child: _QuickItem(label: 'Laporan', icon: Icons.bar_chart_rounded, onTap: () => onNavigate(3))),
                    Expanded(
                      child: _QuickItem(
                        label: 'Pelanggan',
                        icon: Icons.people_outline_rounded,
                        onTap: () => showAppToast(context, 'Halaman Pelanggan dibuat di langkah berikutnya.'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle('Transaksi terbaru'),
                    TextButton(onPressed: () => onNavigate(2), child: const Text('Lihat semua')),
                  ],
                ),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('Belum ada transaksi.',
                          style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    ),
                  ),
                for (final t in recent) ...[
                  _TrxTile(trx: t),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
class _Header extends StatelessWidget {
  const _Header({required this.subtitle, required this.onBell});

  final String subtitle;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kopi Senja',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.card,
          shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBell,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(Icons.notifications_none_rounded, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.amount, required this.growth});

  final int amount;
  final String? growth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Penjualan hari ini',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
              Icon(Icons.calendar_month_outlined, size: 18, color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rupiah(amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 16, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(growth == null ? 'Belum ada data kemarin' : '$growth dibanding kemarin',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Icon(icon, size: 18, color: AppColors.brand),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.count, required this.detail, required this.onTap});

  final int count;
  final String detail;
  final VoidCallback onTap;

  static const _amber = Color(0xFFB7791F);
  static const _amberBg = Color(0xFFFFF4DC);
  static const _amberLine = Color(0xFFF6E3B4);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _amberBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _amberLine),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 24, color: _amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count produk hampir habis',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _amber)),
                    const SizedBox(height: 2),
                    Text(detail, style: const TextStyle(fontSize: 11, color: _amber)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: _amber),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800));
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: AppColors.brand),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TrxTile extends StatelessWidget {
  const _TrxTile({required this.trx});

  final SaleTransaction trx;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trx.id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${jam(trx.time)} • ${trx.itemCount} item • ${trx.method}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rupiah(trx.total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Berhasil',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brand)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}