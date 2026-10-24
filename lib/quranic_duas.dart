import 'package:flutter/material.dart';
import 'main.dart' show Verse, surahNames;

/// Quranic supplications are shown directly from the bundled verified
/// Tanzil text, with exact verse references; no hadith text is invented.
class QuranicDuasPage extends StatelessWidget {
  final List<Verse> verses;
  const QuranicDuasPage({super.key, required this.verses});

  static const references = <({int surah, int ayah, String theme})>[
    (surah: 1, ayah: 6, theme: 'الهداية'),
    (surah: 2, ayah: 201, theme: 'خير الدنيا والآخرة'),
    (surah: 2, ayah: 250, theme: 'الصبر والثبات'),
    (surah: 2, ayah: 286, theme: 'العفو والمغفرة والرحمة'),
    (surah: 3, ayah: 8, theme: 'الثبات على الهدى'),
    (surah: 3, ayah: 16, theme: 'المغفرة والوقاية من النار'),
    (surah: 3, ayah: 38, theme: 'الذرية الطيبة'),
    (surah: 7, ayah: 23, theme: 'التوبة'),
    (surah: 7, ayah: 126, theme: 'الصبر وحسن الخاتمة'),
    (surah: 14, ayah: 40, theme: 'إقامة الصلاة'),
    (surah: 14, ayah: 41, theme: 'المغفرة للوالدين والمؤمنين'),
    (surah: 17, ayah: 24, theme: 'الرحمة للوالدين'),
    (surah: 20, ayah: 25, theme: 'شرح الصدر'),
    (surah: 20, ayah: 114, theme: 'طلب العلم'),
    (surah: 21, ayah: 87, theme: 'دعاء ذي النون'),
    (surah: 23, ayah: 29, theme: 'المنزل المبارك'),
    (surah: 25, ayah: 74, theme: 'صلاح الأهل والذرية'),
    (surah: 28, ayah: 24, theme: 'طلب الخير'),
    (surah: 59, ayah: 10, theme: 'المغفرة للمؤمنين'),
    (surah: 66, ayah: 8, theme: 'تمام النور والمغفرة'),
  ];

  @override
  Widget build(BuildContext context) {
    final lookup = {for (final v in verses) v.key: v};
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أدعية من القرآن الكريم')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card.filled(child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('الآيات التالية من النص القرآني الموثق داخل التطبيق، مع السورة ورقم الآية. بعض الآيات تضم دعاءً ضمن سياق أطول؛ راجع الآية كاملة في المصحف.'),
            )),
            for (final ref in references)
              if (lookup['${ref.surah}:${ref.ayah}'] case final Verse verse)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(ref.theme, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 9),
                        SelectableText(verse.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 23, height: 2)),
                        const SizedBox(height: 9),
                        Text('سورة ${surahNames[ref.surah - 1]} • الآية ${ref.ayah}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
