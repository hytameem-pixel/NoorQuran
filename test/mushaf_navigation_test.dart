import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:noor_quran/mushaf_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Hafs navigation has 604 pages, 30 juz and 240 quarters', () async {
    final nav = await MushafNavigation.load();
    expect(nav.pages.length, 604);
    expect(nav.juz.length, 30);
    expect(nav.quarters.length, 240);
    expect(nav.pages.first, 1);
    expect(nav.pageOf(1), 1);
    expect(nav.pageOf(8), 2);
    expect(nav.pageOf(6236), 604);
    expect(nav.juzOf(1), 1);
    expect(nav.juzOf(6236), 30);
    expect(nav.quarterOf(6236), 240);
  });
}
