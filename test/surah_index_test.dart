import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart' show surahNames, Verse;

void main() {
  test('surah index covers all surahs with unique names', () {
    expect(surahNames.length, 114);
    expect(surahNames.toSet().length, 114);
    expect(surahNames.first, 'الفاتحة');
    expect(surahNames.last, 'الناس');
  });

  test('verse index distinguishes surah and verse references', () {
    expect(const Verse(1, 1, 'test').key, '1:1');
    expect(const Verse(114, 6, 'test').key, '114:6');
  });
}
