import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Offline Quran bundle contains 114 surahs and 6236 ordered verses', () async {
    final verses = await QuranRepository.load();
    expect(verses.length, 6236);
    expect(verses.first.key, '1:1');
    expect(verses.last.key, '114:6');
    expect(verses.map((v) => v.key).toSet().length, 6236);
    expect(verses.map((v) => v.surah).toSet().length, 114);
    expect(verses.every((v) => v.text.trim().isNotEmpty), isTrue);
  });
}
