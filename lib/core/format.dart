String rupiah(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}Rp$buf';
}

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];


const _bulanSingkat = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _dua(int n) => n.toString().padLeft(2, '0');

/// Contoh: 08 Okt 2026
String tanggalSingkat(DateTime d) => '${_dua(d.day)} ${_bulanSingkat[d.month - 1]} ${d.year}';

/// Contoh: 14.32
String jam(DateTime d) => '${_dua(d.hour)}.${_dua(d.minute)}';

String tanggalLengkap(DateTime d) =>
    '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Contoh: +18,4% atau -3,2%
String persen(double v) =>
    '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(1).replaceAll('.', ',')}%';

/// "Hari ini", "Kemarin", atau tanggal lengkap.
String labelHari(DateTime d) {
  final now = DateTime.now();
  if (isSameDay(d, now)) return 'Hari ini';
  if (isSameDay(d, now.subtract(const Duration(days: 1)))) return 'Kemarin';
  return tanggalLengkap(d);
}