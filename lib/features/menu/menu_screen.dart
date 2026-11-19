import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';
import 'product_list_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: AppStore.instance,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu & pengaturan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Atur usaha, sesuaikan cara Anda',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _StoreCard(
                onTap: () =>
                    showAppToast(context, 'Profil toko siap diubah di sini.'),
              ),
              const SizedBox(height: 18),
              const _Label('KELOLA USAHA'),
              const SizedBox(height: 8),
              _SettingsGroup(
                items: [
                  _SettingItem(
                    Icons.inventory_2_outlined,
                    'Produk & menu',
                    '${AppStore.instance.products.length} produk • ${AppStore.categories.length - 1} kategori',
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProductListScreen(),
                      ),
                    ),
                  ),
                  _SettingItem(
                    Icons.people_outline_rounded,
                    'Pengguna & kasir',
                    '3 pengguna • Kelola hak akses',
                    () => showAppToast(
                      context,
                      'Pengaturan pengguna dibuat di langkah berikutnya.',
                    ),
                  ),
                  _SettingItem(
                    Icons.person_outline_rounded,
                    'Pelanggan',
                    '128 pelanggan terdaftar',
                    () => showAppToast(
                      context,
                      'Halaman pelanggan dibuat di langkah berikutnya.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _Label('PENGATURAN TRANSAKSI'),
              const SizedBox(height: 8),
              _SettingsGroup(
                items: [
                  _SettingItem(
                    Icons.print_outlined,
                    'Printer struk',
                    'Senja-01 • Terhubung • 58 mm',
                    () => showAppToast(context, 'Printer struk terhubung.'),
                  ),
                  _SettingItem(
                    Icons.percent_rounded,
                    'Pajak & biaya',
                    'Pajak PB1 10% • Aktif',
                    () => showAppToast(context, 'Pajak PB1 aktif sebesar 10%.'),
                  ),
                  _SettingItem(
                    Icons.credit_card_outlined,
                    'Metode pembayaran',
                    'Tunai, QRIS, dan kartu',
                    () => showAppToast(
                      context,
                      'Metode pembayaran tersedia: Tunai, QRIS, Kartu.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsGroup(
                items: [
                  _SettingItem(
                    Icons.help_outline_rounded,
                    'Bantuan & dukungan',
                    'Panduan aplikasi dan hubungi kami',
                    () => showAppToast(
                      context,
                      'Silakan hubungi dukungan Laris POS.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: () => showAppToast(
                    context,
                    'Anda tetap berada di perangkat ini.',
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Keluar dari akun',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Laris POS • Versi 2.4.0',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: AppColors.muted,
    ),
  );
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.brand,
              child: Icon(Icons.storefront_outlined, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kopi Senja',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Nadia Putri • Pemilik',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  Text(
                    'Kelola profil toko',
                    style: TextStyle(fontSize: 10, color: AppColors.brand),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _SettingItem {
  const _SettingItem(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<_SettingItem> items;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          ListTile(
            onTap: items[i].onTap,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(items[i].icon, size: 18, color: AppColors.brand),
            ),
            title: Text(
              items[i].title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              items[i].subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ),
          if (i < items.length - 1)
            const Divider(height: 1, indent: 54, color: AppColors.line),
        ],
      ],
    ),
  );
}
