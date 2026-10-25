import 'package:flutter/material.dart';

/// Content is intentionally gated until a reviewed, legally usable edition is bundled.
/// No fabricated tafsir, hadith or word meanings are displayed.
class IslamicLibraryPage extends StatelessWidget {
  const IslamicLibraryPage({super.key});

  static const sections = <({String title, String detail, IconData icon})>[
    (title: 'التفسير الميسر', detail: 'بانتظار إضافة طبعة موثقة ومراجعة ربط التفسير بالآيات.', icon: Icons.menu_book_outlined),
    (title: 'معاني كلمات القرآن', detail: 'بانتظار معجم قرآني موثق وربط الكلمات بمواضعها.', icon: Icons.translate_outlined),
    (title: 'أذكار الصباح والمساء', detail: 'بانتظار نصوص الأذكار الموثقة وأعداد التكرار وتخريج الحديث.', icon: Icons.wb_twilight_outlined),
    (title: 'أذكار النوم والاستيقاظ', detail: 'بانتظار تخريج الأذكار الصحيحة وبيانات مصادرها.', icon: Icons.bedtime_outlined),
    (title: 'حصن المسلم', detail: 'بانتظار إدراج نسخة مأذون بإعادة نشرها ومراجعة التخريج.', icon: Icons.shield_outlined),
    (title: 'قصص الأنبياء', detail: 'ملخصات من القرآن مع إحالات الآيات؛ يلزم إتمام مراجعة النصوص قبل إدراجها في التطبيق.', icon: Icons.auto_stories_outlined),
    (title: 'قصص مواعظ وعبر', detail: 'قصص ذات مصدر قرآني موثق وعبر تربوية؛ قسم مخطط للتطبيق.', icon: Icons.lightbulb_outline),
    (title: 'قصص تربوية للأطفال', detail: 'قصص تعليمية مؤلفة لتعليم التوحيد والصلاة والصدق والرحمة؛ قسم مخطط للتطبيق.', icon: Icons.child_care_outlined),
    (title: 'صحيح البخاري', detail: 'بانتظار نص موثق وترقيم محدد للطبعة والتخريج.', icon: Icons.library_books_outlined),
    (title: 'صحيح مسلم', detail: 'بانتظار نص موثق وترقيم محدد للطبعة والتخريج.', icon: Icons.library_books_outlined),
    (title: 'رياض الصالحين', detail: 'بانتظار نسخة موثقة بمصادر الأحاديث.', icon: Icons.auto_stories_outlined),
  ];

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('المكتبة الإسلامية')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Card.filled(child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('تُضاف الكتب بعد التحقق من النصوص والمصادر وحقوق النشر. لا توجد نصوص غير موثقة في هذه النسخة.'),
        )),
        for (final item in sections)
          Card(child: ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            subtitle: Text(item.detail),
            trailing: const Icon(Icons.lock_clock_outlined),
            onTap: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(item.title),
                content: Text(item.detail),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
              ),
            ),
          )),
      ]),
    ),
  );
}
