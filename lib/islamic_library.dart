import 'package:flutter/material.dart';

/// Content is intentionally gated until a reviewed, legally usable edition is bundled.
/// No fabricated tafsir, hadith or word meanings are displayed.
class IslamicLibraryPage extends StatelessWidget {
  const IslamicLibraryPage({super.key});

  static const sections = <({String title, String detail, IconData icon})>[
    (title: 'التفسير الميسر', detail: 'بانتظار إضافة طبعة موثقة ومراجعة ربط التفسير بالآيات.', icon: Icons.menu_book_outlined),
    (title: 'معاني كلمات القرآن', detail: 'بانتظار معجم قرآني موثق وربط الكلمات بمواضعها.', icon: Icons.translate_outlined),
    (title: 'الأذكار والأدعية', detail: 'بانتظار نصوص محققة مع تخريج الأدعية والأذكار.', icon: Icons.volunteer_activism_outlined),
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
