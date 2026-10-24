import 'package:flutter/material.dart';
import 'main.dart' show QuranRepository;
import 'mushaf_pages.dart' show MushafNavigation;

/// Local self-check: no network, accounts or telemetry.
class QuranDiagnosticsPage extends StatelessWidget {
  const QuranDiagnosticsPage({super.key});

  Future<List<String>> _check() async {
    final results = <String>[];
    try {
      final verses = await QuranRepository.load();
      results.add('✓ نص المصحف: ${verses.length} آية، ${verses.map((v) => v.surah).toSet().length} سورة');
    } catch (e) {
      results.add('✗ تعذر قراءة نص المصحف: $e');
    }
    try {
      final nav = await MushafNavigation.load();
      results.add('✓ فهرس الصفحات: ${nav.pages.length} صفحة');
      results.add('✓ فهرس الأجزاء: ${nav.juz.length} جزء');
      results.add('✓ أرباع الأحزاب: ${nav.quarters.length} ربع');
    } catch (e) {
      results.add('✗ تعذر قراءة فهرس المصحف: $e');
    }
    results.add('الصوتيات: لا توجد تسجيلات مدمجة. افتح قسم الحفظ واختر ملفًا صوتيًا من هاتفك.');
    return results;
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('فحص المصحف والصوتيات')),
      body: FutureBuilder<List<String>>(
        future: _check(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('فحص الملفات المضمنة في التطبيق دون إنترنت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final line in snapshot.data!)
              Card(child: Padding(padding: const EdgeInsets.all(14),
                child: SelectableText(line))),
            const SizedBox(height: 12),
            const Text('يمكن نسخ نص الخطأ وإرساله للمطور. نجاح هذا الفحص لا يؤكد أن الصوت يعمل على جهازك.'),
          ]);
        },
      ),
    ),
  );
}
