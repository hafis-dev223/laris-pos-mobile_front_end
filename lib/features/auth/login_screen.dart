import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'widgets/hero_illustration.dart';
import '../shell/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'nadia@kopisenja.id');
  final _passwordCtrl = TextEditingController(text: 'rahasia1234');

  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Isi email Anda.';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v);
    if (!ok) return 'Format email belum benar, contoh: nama@usaha.id';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Isi password Anda.';
    if (v.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.fg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    // TODO: sambungkan ke API login. Sementara hanya simulasi.
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _forgotPassword() {
    final email = _emailCtrl.text.trim();
    _toast(email.isEmpty
        ? 'Isi email dulu untuk reset password.'
        : 'Tautan reset dikirim ke $email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 18),
                  const HeroIllustration(),
                  const SizedBox(height: 22),
                  Text(
                    'Selamat datang kembali',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Masuk untuk mulai melayani pelanggan dan pantau usaha Anda.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _buildForm(),
                  const SizedBox(height: 18),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Belum punya akun? ',
                            style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        TextButton(
                          onPressed: () => _toast('Halaman Daftar adalah layar nomor 2 di desain.'),
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          child: const Text('Daftar sekarang'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 13, color: AppColors.muted),
                        SizedBox(width: 6),
                        Text('Data usaha Anda aman dan terlindungi',
                            style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Email'),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
            decoration: const InputDecoration(
              hintText: 'nama@usaha.id',
              suffixIcon: Icon(Icons.mail_outline, size: 19, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Password'),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            validator: _validatePassword,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 19,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _remember = !_remember),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _remember,
                        activeColor: AppColors.brand,
                        side: const BorderSide(color: AppColors.line, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (v) => setState(() => _remember = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Ingat saya', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              TextButton(onPressed: _forgotPassword, child: const Text('Lupa password?')),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
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
                Icon(Icons.arrow_forward, size: 18),
                SizedBox(width: 8),
                Text('Masuk'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          'laris',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'POS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.brand,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}