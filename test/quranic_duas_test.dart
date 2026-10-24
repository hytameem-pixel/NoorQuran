import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart';
import 'package:noor_quran/quranic_duas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Every Quranic supplication reference exists in offline Quran', () async {
    final verses = await QuranRepository.load();
    final lookup = {for (final v in verses) v.key: v};
    expect(QuranicDuasPage.references.length, 20);
    for (final ref in QuranicDuasPage.references) {
      final verse = lookup['${ref.surah}:${ref.ayah}'];
      expect(verse, isNotNull, reason: 'Missing supplication ${ref.surah}:${ref.ayah}');
      expect(verse!.text.trim(), isNotEmpty);
    }
  });
}
