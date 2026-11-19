import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/app_store.dart';
import 'success_screen.dart';

enum PayMethod {
  cash('Tunai', Icons.payments_outlined),
  qris('QRIS', Icons.qr_code_2_rounded),
  card('Kartu', Icons.credit_card_rounded);

  const PayMethod(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Layar Pembayaran (nomor 6 di desain).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _store = AppStore.instance;
  late final TextEditingController _received;

  PayMethod _method = PayMethod.cash;
  bool _submitting = false;

  int get _total => _store.cartTotal;

  int get _receivedValue => int.tryParse(_received.text.trim()) ?? 0;

  bool get _isCash => _method == PayMethod.cash;

  int get _change => _isCash ? (_receivedValue - _total).clamp(0, 1 << 40) : 0;

  bool get _canPay => !_submitting && (!_isCash || _receivedValue >= _total);

  /// Pilihan nominal cepat: uang pas + 2 pecahan terdekat di atas total.
  List<int> get _quickAmounts {
    const steps = [50000, 100000, 150000, 200000, 300000, 500000];
    final above = steps.where((s) => s > _total).take(2);
    return [_total, ...above];
  }

  @override
  void initState() {
    super.initState();
    _received = TextEditingController();
  }

  @override
  void dispose() {
    _received.dispose();
    super.dispose();
  }

  void _setReceived(int value) {
    setState(() => _received.text = value == 0 ? '' : '$value');
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    if (_isCash && _receivedValue < _total) {
      showAppToast(context, 'Uang diterima kurang ${rupiah(_total - _receivedValue)}.');
      return;
    }
    setState(() => _submitting = true);
    // TODO: kirim transaksi ke database/API. Sementara disimpan di memori (AppStore).
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final trx = _store.checkout(
      method: _method.label,
      paid: _isCash ? _receivedValue : _total,
    );
    // Buang Pembayaran & Keranjang dari tumpukan, sisakan kerangka utama + struk.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SuccessScreen(trx: trx)),
          (route) => route.isFirst,
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
              listenable: _store,
              builder: (context, _) {
                return Column(
                  children: [
                    _Header(
                      subtitle: '${_store.orderNumber} • ${_store.cartItemCount} item',
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          _TotalCard(total: _total),
                          const SizedBox(height: 20),
                          const Text('Metode pembayaran',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final m in PayMethod.values) ...[
                                Expanded(
                                  child: _MethodTile(
                                    method: m,
                                    selected: m == _method,
                                    onTap: () => setState(() => _method = m),
                                  ),
                                ),
                                if (m != PayMethod.values.last) const SizedBox(width: 10),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isCash)
                            _CashCard(
                              controller: _received,
                              quick: _quickAmounts,
                              selectedAmount: _receivedValue,
                              change: _change,
                              short: _receivedValue > 0 && _receivedValue < _total,
                              onChanged: () => setState(() {}),
                              onQuick: _setReceived,
                            )
                          else
                            _NonCashCard(method: _method),
                          const SizedBox(height: 14),
                          _InfoNote(
                            text: _isCash
                                ? 'Pastikan uang sudah diterima sebelum menyelesaikan pembayaran.'
                                : 'Pastikan pembayaran ${_method.label} sudah berhasil sebelum konfirmasi.',
                          ),
                        ],
                      ),
                    ),
                    _ConfirmBar(enabled: _canPay, loading: _submitting, onTap: _confirm),
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
                const Text('Pembayaran',
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('Total yang harus dibayar',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(
            rupiah(total),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.brand,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Sudah termasuk diskon & pajak PB1',
              style: TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.selected, required this.onTap});

  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mint : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AppColors.brand : AppColors.line, width: selected ? 1.6 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(method.icon, size: 24, color: selected ? AppColors.brand : AppColors.muted),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.brand : AppColors.fg,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.check_rounded, size: 13, color: AppColors.brand),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashCard extends StatelessWidget {
  const _CashCard({
    required this.controller,
    required this.quick,
    required this.selectedAmount,
    required this.change,
    required this.short,
    required this.onChanged,
    required this.onQuick,
  });

  final TextEditingController controller;
  final List<int> quick;
  final int selectedAmount;
  final int change;
  final bool short;
  final VoidCallback onChanged;
  final ValueChanged<int> onQuick;

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
          const Text('Uang diterima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              hintText: '0',
              prefixText: 'Rp ',
              suffixIcon: Icon(Icons.payments_outlined, size: 19, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < quick.length; i++) ...[
                Expanded(
                  child: _QuickChip(
                    label: i == 0 ? 'Uang pas' : rupiah(quick[i]),
                    selected: selectedAmount == quick[i],
                    onTap: () => onQuick(quick[i]),
                  ),
                ),
                if (i != quick.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(short ? 'Kurang' : 'Kembalian',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              Text(
                short ? rupiah(0) : rupiah(change),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: short ? AppColors.danger : AppColors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mint : AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.brand : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.brand : AppColors.fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NonCashCard extends StatelessWidget {
  const _NonCashCard({required this.method});

  final PayMethod method;

  @override
  Widget build(BuildContext context) {
    final isQris = method == PayMethod.qris;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(method.icon, size: 44, color: AppColors.brand),
          const SizedBox(height: 10),
          Text(
            isQris ? 'Minta pelanggan scan kode QRIS' : 'Gesek atau tempel kartu di mesin EDC',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isQris
                ? 'Kode QRIS akan tampil di langkah berikutnya.'
                : 'Konfirmasi setelah mesin EDC menyatakan berhasil.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline_rounded, size: 14, color: AppColors.muted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4)),
        ),
      ],
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.enabled, required this.loading, required this.onTap});

  final bool enabled;
  final bool loading;
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
            onPressed: enabled ? onTap : null,
            child: loading
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text('Memproses...'),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 18),
                SizedBox(width: 8),
                Text('Konfirmasi pembayaran'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 12, color: AppColors.muted),
              SizedBox(width: 6),
              Text('Transaksi tercatat otomatis di laporan',
                  style: TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}