import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart';

void main() {
  test('114 correctly named surahs', () {
    expect(surahNames.length, 114);
    expect(surahNames.first, 'الفاتحة');
    expect(surahNames.last, 'الناس');
  });
  test('Arabic search normalizes diacritics without changing source', () {
    expect(normalizedArabic('الرَّحْمَٰن'), normalizedArabic('الرحمن'));
    expect(normalizedArabic('إِلَى'), normalizedArabic('الى'));
  });
}
