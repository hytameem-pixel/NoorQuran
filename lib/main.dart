import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'memorization.dart';
import 'islamic_library.dart';
import 'local_data.dart';
import 'mushaf_pages.dart';
import 'quranic_duas.dart';
import 'quran_diagnostics.dart';

void main() => runApp(const NoorApp());

const surahNames = <String>[
'الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس','هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه','الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء','النمل','القصص','العنكبوت','الروم','لقمان','السجدة','الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر','فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف','محمد','الفتح','الحجرات','ق','الذاريات','الطور','النجم','القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر','الممتحنة','الصف','الجمعة','المنافقون','التغابن','الطلاق','التحريم','الملك','القلم','الحاقة','المعارج','نوح','الجن','المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ','النازعات','عبس','التكوير','الانفطار','المطففين','الانشقاق','البروج','الطارق','الأعلى','الغاشية','الفجر','البلد','الشمس','الليل','الضحى','الشرح','التين','العلق','القدر','البينة','الزلزلة','العاديات','القارعة','التكاثر','العصر','الهمزة','الفيل','قريش','الماعون','الكوثر','الكافرون','النصر','المسد','الإخلاص','الفلق','الناس'];

String normalizedArabic(String s) => s
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ـ', '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class Verse {
  final int surah;
  final int ayah;
  final String text;
  const Verse(this.surah, this.ayah, this.text);
  factory Verse.fromJson(Map<String, dynamic> x) => Verse(
    x['surahId'] as int,
    x['ayahNumber'] as int,
    x['textUthmani'] as String,
  );
  String get key => '$surah:$ayah';
}

class QuranRepository {
  static Future<List<Verse>> load() async {
    final raw = await rootBundle.loadString('assets/content/quran/quran.json');
    final doc = jsonDecode(raw) as Map<String, dynamic>;
    final verses = (doc['verses'] as List<dynamic>)
        .map((v) => Verse.fromJson(v as Map<String, dynamic>))
        .toList(growable: false);
    if (doc['source'] != 'Tanzil Project' ||
        doc['surah_count'] != 114 ||
        doc['verse_count'] != 6236 ||
        verses.length != 6236 ||
        surahNames.length != 114) {
      throw const FormatException('Incomplete Quran data');
    }
    // Fail closed if any verse is missing, duplicated, or out of order.
    var previousSurah = 1;
    var previousAyah = 0;
    for (final verse in verses) {
      if (verse.surah < 1 || verse.surah > 114 ||
          verse.ayah < 1 || verse.text.trim().isEmpty ||
          verse.surah < previousSurah ||
          verse.surah > previousSurah + 1 ||
          (verse.surah == previousSurah && verse.ayah != previousAyah + 1) ||
          (verse.surah == previousSurah + 1 && verse.ayah != 1)) {
        throw const FormatException('Quran verse sequence failed validation');
      }
      previousSurah = verse.surah;
      previousAyah = verse.ayah;
    }
    if (previousSurah != 114) {
      throw const FormatException('Incomplete final surah');
    }
    return verses;
  }
}

class NoorApp extends StatefulWidget {
  const NoorApp({super.key});
  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> {
  ThemeMode themeMode = ThemeMode.system;
  double fontSize = 25;
  late final Future<List<Verse>> versesFuture = QuranRepository.load();
  Set<String> bookmarks = <String>{};
  String? lastRead;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      themeMode = p.getBool('dark_mode') == true ? ThemeMode.dark : ThemeMode.light;
      fontSize = (p.getDouble('font_size') ?? 25).clamp(18.0, 40.0);
      bookmarks = (p.getStringList('bookmarks') ?? []).where((key) =>
        key.contains(':') && key.split(':').length == 2 &&
        int.tryParse(key.split(':')[0]) != null &&
        int.tryParse(key.split(':')[1]) != null).toSet();
      final s = p.getInt('last_surah');
      final a = p.getInt('last_ayah');
      lastRead = (s != null && a != null && s >= 1 && s <= 114 &&
          a >= 1 && a <= 286) ? '$s:$a' : null;
    });
    } catch (e) {
      debugPrint('Could not restore local reading preferences: $e');
    }
  }

  Future<void> _bookmark(Verse v) async {
    setState(() {
      if (!bookmarks.add(v.key)) bookmarks.remove(v.key);
    });
    await (await SharedPreferences.getInstance()).setStringList('bookmarks', bookmarks.toList());
  }

  Future<void> _remember(Verse v) async {
    setState(() => lastRead = v.key);
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_surah', v.surah);
    await p.setInt('last_ayah', v.ayah);
  }

  void _openReader(List<Verse> verses, {int? surah, String? jumpTo}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReaderPage(
        verses: verses,
        surah: surah,
        jumpTo: jumpTo,
        fontSize: fontSize,
        bookmarked: (v) => bookmarks.contains(v.key),
        onBookmark: _bookmark,
        onRead: _remember,
      ),
    )).then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'نور القرآن',
    debugShowCheckedModeBanner: false,
    themeMode: themeMode,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF126C57), scaffoldBackgroundColor: const Color(0xFFF8F7F0)),
    darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: const Color(0xFF68C2A2)),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نور القرآن'), actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => StatefulBuilder(builder: (ctx, localSetState) =>
                SafeArea(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('إعدادات القراءة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text('الوضع الليلي'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (v) async {
                        setState(() => themeMode = v ? ThemeMode.dark : ThemeMode.light);
                        localSetState(() {});
                        await (await SharedPreferences.getInstance()).setBool('dark_mode', v);
                      },
                    ),
                    Text('حجم خط القرآن: ${fontSize.round()}'),
                    Slider(
                      min: 18, max: 40, divisions: 22, value: fontSize,
                      onChanged: (v) async {
                        setState(() => fontSize = v);
                        localSetState(() {});
                        await (await SharedPreferences.getInstance()).setDouble('font_size', v);
                      },
                    ),
                    const ListTile(title: Text('مصدر النص القرآني: Tanzil Project'), subtitle: Text('نص عثماني، يُعرض كما ورد من المصدر دون تعديل')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('تم')),
                  ]),
                )),
              ),
            ),
          ),
        ]),
        body: FutureBuilder<List<Verse>>(
          future: versesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('تعذر فتح نص المصحف. يمكن فحص ملفات التطبيق لمعرفة السبب.', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
                    builder: (_) => const QuranDiagnosticsPage())),
                  icon: const Icon(Icons.build_outlined),
                  label: const Text('فحص ملفات المصحف'),
                ),
              ]),
            ));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final verses = snapshot.data!;
            switch (tab) {
              case 0:
                return ListView(padding: const EdgeInsets.all(16), children: [
                  const Text('اقرأ وتدبّر', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('المصحف الشريف متاح دون إنترنت أو تسجيل دخول.'),
                  const SizedBox(height: 16),
                  Card(child: ListTile(
                    leading: const Icon(Icons.build_circle_outlined),
                    title: const Text('فحص المصحف والصوتيات'),
                    subtitle: const Text('تحقق من ملفات المصحف واعرض أسباب الأعطال'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const QuranDiagnosticsPage())),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.chrome_reader_mode_outlined),
                    title: const Text('فهرس صفحات مصحف المدينة'),
                    subtitle: const Text('604 موضع صفحة • عرض الآيات كاملة • الوضع الليلي'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MushafPagesPage(
                        verses: verses,
                        bookmarked: (v) => bookmarks.contains(v.key),
                        onBookmark: _bookmark,
                        onRead: _remember,
                      ))).then((_) { if (mounted) setState(() {}); }),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined),
                    title: const Text('أدعية من القرآن الكريم'),
                    subtitle: const Text('20 موضعًا من آيات الدعاء مع الإحالة إلى السورة والآية'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => QuranicDuasPage(verses: verses))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: const Text('المصحف الشريف'),
                    subtitle: const Text('١١٤ سورة • النص العثماني'),
                    trailing: const Icon(Icons.arrow_back_ios_new),
                    onTap: () => _openReader(verses),
                  )),
                  if (lastRead != null)
                    Card(child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('متابعة آخر قراءة'),
                      subtitle: Text('سورة ${surahNames[int.parse(lastRead!.split(':')[0])-1]} — آية ${lastRead!.split(':')[1]}'),
                      onTap: () => _openReader(verses, jumpTo: lastRead),
                    )),
                  const SizedBox(height: 12),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text('حفظ القرآن ومراجعته'),
                    subtitle: const Text('تسميع ذاتي وتسجيل تقدم الحفظ'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MemorizationPage(verses: verses))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.child_care),
                    title: const Text('براعم نور القرآن'),
                    subtitle: const Text('قسم حفظ القرآن للصغار بإشراف ولي الأمر'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MemorizationPage(verses: verses, kidsMode: true))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('نسخ بيانات الحفظ والقراءة واستعادتها'),
                    subtitle: const Text('احتفظ بعلاماتك وتقدم الحفظ عند تغيير الهاتف'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const LocalDataPage())),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.local_library_outlined),
                    title: const Text('المكتبة الإسلامية'),
                    subtitle: const Text('التفسير • معاني الكلمات • الأذكار • كتب الحديث'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const IslamicLibraryPage())),
                  )),
                  const SizedBox(height: 12),
                  const Text('سور القرآن الكريم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(114, (i) => ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text('سورة ${surahNames[i]}'),
                    subtitle: Text('${verses.where((v) => v.surah == i + 1).length} آية'),
                    onTap: () => _openReader(verses, surah: i + 1),
                  )),
                ]);
              case 1:
                return SearchPage(verses: verses, onSelect: (v) => _openReader(verses, jumpTo: v.key));
              case 2:
                final saved = verses.where((v) => bookmarks.contains(v.key)).toList();
                return saved.isEmpty
                    ? const Center(child: Text('لا توجد علامات مرجعية حتى الآن.'))
                    : ListView(children: saved.map((v) => ListTile(
                        title: Text(v.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${surahNames[v.surah - 1]} — ${v.ayah}'),
                        onTap: () => _openReader(verses, jumpTo: v.key),
                      )).toList());
              default:
                return const AboutPage();
            }
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
            NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.info_outline), label: 'حول'),
          ],
        ),
      ),
    ),
  );
}

class ReaderPage extends StatefulWidget {
  final List<Verse> verses;
  final int? surah;
  final String? jumpTo;
  final double fontSize;
  final bool Function(Verse) bookmarked;
  final Future<void> Function(Verse) onBookmark;
  final Future<void> Function(Verse) onRead;
  const ReaderPage({
    super.key, required this.verses, required this.fontSize,
    required this.bookmarked, required this.onBookmark, required this.onRead,
    this.surah, this.jumpTo,
  });
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final List<Verse> items = widget.verses
      .where((v) => widget.surah == null || v.surah == widget.surah)
      .toList(growable: false);
  final ItemScrollController controller = ItemScrollController();
  late final int initialIndex = widget.jumpTo == null ? 0 : (() {
    final index = items.indexWhere((v) => v.key == widget.jumpTo);
    return index < 0 ? 0 : index;
  })();
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.surah == null
          ? 'المصحف الشريف' : 'سورة ${surahNames[widget.surah! - 1]}'),
        actions: [
          IconButton(
            tooltip: 'الانتقال إلى آية',
            icon: const Icon(Icons.pin_drop_outlined),
            onPressed: () async {
              final input = TextEditingController();
              final target = await showDialog<int>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('الانتقال إلى رقم الآية'),
                  content: TextField(
                    controller: input,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'رقم الآية في السورة الحالية'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(input.text)),
                      child: const Text('انتقال')),
                  ],
                ),
              );
              input.dispose();
              if (!context.mounted || target == null || target < 1) return;
              final index = items.indexWhere((v) =>
                v.ayah == target && (widget.surah == null || v.surah == widget.surah));
              if (index < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رقم الآية غير موجود')));
              } else {
                controller.scrollTo(index: index,
                  duration: const Duration(milliseconds: 350));
              }
            },
          ),
          IconButton(
            tooltip: 'معلومات الحفظ',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('العلامات المرجعية'),
                content: const Text('اضغط رمز العلامة بجانب أي آية لحفظها. يمكنك فتح العلامات من تبويب المفضلة في الصفحة الرئيسية.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
              ),
            ),
          ),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: controller,
        initialScrollIndex: initialIndex,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final v = items[i];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(v.text, textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: widget.fontSize, height: 2)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text('${surahNames[v.surah - 1]} • آية ${v.ayah}')),
                  IconButton(
                    tooltip: 'حفظ موضع القراءة',
                    icon: const Icon(Icons.history),
                    onPressed: () => widget.onRead(v),
                  ),
                  IconButton(
                    tooltip: 'إضافة أو إزالة علامة مرجعية',
                    icon: Icon(widget.bookmarked(v) ? Icons.bookmark : Icons.bookmark_outline),
                    onPressed: () async {
                      await widget.onBookmark(v);
                      if (mounted) setState(() {});
                    },
                  ),
                ]),
              ],
            )));
        },
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  final List<Verse> verses;
  final void Function(Verse) onSelect;
  const SearchPage({super.key, required this.verses, required this.onSelect});
  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final term = normalizedArabic(query);
    final matches = term.isEmpty ? <Verse>[] : widget.verses
        .where((v) => normalizedArabic(v.text).contains(term)).take(100).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'ابحث في القرآن دون تشكيل', prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder()),
          onChanged: (value) => setState(() => query = value),
        )),
      if (term.isNotEmpty) Padding(padding: const EdgeInsets.all(8),
        child: Text('أول ${matches.length} نتيجة (بحد أقصى 100)')),
      Expanded(child: ListView.builder(itemCount: matches.length,
        itemBuilder: (context, i) {
          final v = matches[i];
          return ListTile(
            title: Text(v.text, maxLines: 3, overflow: TextOverflow.ellipsis),
            subtitle: Text('سورة ${surahNames[v.surah - 1]}، الآية ${v.ayah}'),
            onTap: () => widget.onSelect(v),
          );
        })),
    ]);
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24),
    children: const [
      Icon(Icons.menu_book, size: 72),
      SizedBox(height: 14),
      Text('نور القرآن', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      Text('تطبيق مجاني للقرآن الكريم، صدقة جارية على روح الوالد وعلى روح يحيى يحيى راجح تميم.'),
      SizedBox(height: 16),
      Text('المصدر: Tanzil Project — Quran Uthmani Text v1.1'),
      Text('النص القرآني من مشروع Tanzil؛ النص محفوظ دون تعديل.'),
      SelectableText('https://tanzil.net/'),
      SizedBox(height: 12),
      Text('ترخيص النص: Creative Commons Attribution 3.0. النص من Tanzil Project، حقوق النشر © 2007–2021 Tanzil Project. يُسمح بتوزيع نسخ مطابقة للنص، ولا يُسمح بتغيير النص القرآني. يجب ذكر المصدر وإرفاق الرابط https://tanzil.net/ وإشعار الحقوق في النسخ الموزعة.'),
      SizedBox(height: 16),
      Text('نور القرآن تطبيق مستقل، غير تابع لمشروع Quran.tv.'),
      Text('لا يلزم إنشاء حساب لاستخدام التطبيق؛ التفضيلات والعلامات المرجعية تُحفظ على الجهاز فقط. لا يطلب هذا الإصدار اسمًا أو هاتفًا أو بريدًا إلكترونيًا.'),
    ]);
}
).hasMatch(key)).toSet();
      final s = p.getInt('last_surah');
      final a = p.getInt('last_ayah');
      lastRead = (s != null && a != null && s >= 1 && s <= 114 &&
          a >= 1 && a <= 286) ? '$s:$a' : null;
    });
  }

  Future<void> _bookmark(Verse v) async {
    setState(() {
      if (!bookmarks.add(v.key)) bookmarks.remove(v.key);
    });
    await (await SharedPreferences.getInstance()).setStringList('bookmarks', bookmarks.toList());
  }

  Future<void> _remember(Verse v) async {
    setState(() => lastRead = v.key);
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_surah', v.surah);
    await p.setInt('last_ayah', v.ayah);
  }

  void _openReader(List<Verse> verses, {int? surah, String? jumpTo}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReaderPage(
        verses: verses,
        surah: surah,
        jumpTo: jumpTo,
        fontSize: fontSize,
        bookmarked: (v) => bookmarks.contains(v.key),
        onBookmark: _bookmark,
        onRead: _remember,
      ),
    )).then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'نور القرآن',
    debugShowCheckedModeBanner: false,
    themeMode: themeMode,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF126C57), scaffoldBackgroundColor: const Color(0xFFF8F7F0)),
    darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: const Color(0xFF68C2A2)),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نور القرآن'), actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => StatefulBuilder(builder: (ctx, localSetState) =>
                SafeArea(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('إعدادات القراءة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text('الوضع الليلي'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (v) async {
                        setState(() => themeMode = v ? ThemeMode.dark : ThemeMode.light);
                        localSetState(() {});
                        await (await SharedPreferences.getInstance()).setBool('dark_mode', v);
                      },
                    ),
                    Text('حجم خط القرآن: ${fontSize.round()}'),
                    Slider(
                      min: 18, max: 40, divisions: 22, value: fontSize,
                      onChanged: (v) async {
                        setState(() => fontSize = v);
                        localSetState(() {});
                        await (await SharedPreferences.getInstance()).setDouble('font_size', v);
                      },
                    ),
                    const ListTile(title: Text('مصدر النص القرآني: Tanzil Project'), subtitle: Text('نص عثماني، يُعرض كما ورد من المصدر دون تعديل')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('تم')),
                  ]),
                )),
              ),
            ),
          ),
        ]),
        body: FutureBuilder<List<Verse>>(
          future: versesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('تعذر التحقق من النص القرآني في هذه النسخة.'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final verses = snapshot.data!;
            switch (tab) {
              case 0:
                return ListView(padding: const EdgeInsets.all(16), children: [
                  const Text('اقرأ وتدبّر', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('المصحف الشريف متاح دون إنترنت أو تسجيل دخول.'),
                  const SizedBox(height: 16),
                  Card(child: ListTile(
                    leading: const Icon(Icons.build_circle_outlined),
                    title: const Text('فحص المصحف والصوتيات'),
                    subtitle: const Text('تحقق من ملفات المصحف واعرض أسباب الأعطال'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const QuranDiagnosticsPage())),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.chrome_reader_mode_outlined),
                    title: const Text('فهرس صفحات مصحف المدينة'),
                    subtitle: const Text('604 موضع صفحة • عرض الآيات كاملة • الوضع الليلي'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MushafPagesPage(
                        verses: verses,
                        bookmarked: (v) => bookmarks.contains(v.key),
                        onBookmark: _bookmark,
                        onRead: _remember,
                      ))).then((_) { if (mounted) setState(() {}); }),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined),
                    title: const Text('أدعية من القرآن الكريم'),
                    subtitle: const Text('20 موضعًا من آيات الدعاء مع الإحالة إلى السورة والآية'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => QuranicDuasPage(verses: verses))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: const Text('المصحف الشريف'),
                    subtitle: const Text('١١٤ سورة • النص العثماني'),
                    trailing: const Icon(Icons.arrow_back_ios_new),
                    onTap: () => _openReader(verses),
                  )),
                  if (lastRead != null)
                    Card(child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('متابعة آخر قراءة'),
                      subtitle: Text('سورة ${surahNames[int.parse(lastRead!.split(':')[0])-1]} — آية ${lastRead!.split(':')[1]}'),
                      onTap: () => _openReader(verses, jumpTo: lastRead),
                    )),
                  const SizedBox(height: 12),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text('حفظ القرآن ومراجعته'),
                    subtitle: const Text('تسميع ذاتي وتسجيل تقدم الحفظ'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MemorizationPage(verses: verses))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.child_care),
                    title: const Text('براعم نور القرآن'),
                    subtitle: const Text('قسم حفظ القرآن للصغار بإشراف ولي الأمر'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => MemorizationPage(verses: verses, kidsMode: true))),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('نسخ بيانات الحفظ والقراءة واستعادتها'),
                    subtitle: const Text('احتفظ بعلاماتك وتقدم الحفظ عند تغيير الهاتف'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const LocalDataPage())),
                  )),
                  Card.filled(child: ListTile(
                    leading: const Icon(Icons.local_library_outlined),
                    title: const Text('المكتبة الإسلامية'),
                    subtitle: const Text('التفسير • معاني الكلمات • الأذكار • كتب الحديث'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const IslamicLibraryPage())),
                  )),
                  const SizedBox(height: 12),
                  const Text('سور القرآن الكريم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(114, (i) => ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text('سورة ${surahNames[i]}'),
                    subtitle: Text('${verses.where((v) => v.surah == i + 1).length} آية'),
                    onTap: () => _openReader(verses, surah: i + 1),
                  )),
                ]);
              case 1:
                return SearchPage(verses: verses, onSelect: (v) => _openReader(verses, jumpTo: v.key));
              case 2:
                final saved = verses.where((v) => bookmarks.contains(v.key)).toList();
                return saved.isEmpty
                    ? const Center(child: Text('لا توجد علامات مرجعية حتى الآن.'))
                    : ListView(children: saved.map((v) => ListTile(
                        title: Text(v.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${surahNames[v.surah - 1]} — ${v.ayah}'),
                        onTap: () => _openReader(verses, jumpTo: v.key),
                      )).toList());
              default:
                return const AboutPage();
            }
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
            NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.info_outline), label: 'حول'),
          ],
        ),
      ),
    ),
  );
}

class ReaderPage extends StatefulWidget {
  final List<Verse> verses;
  final int? surah;
  final String? jumpTo;
  final double fontSize;
  final bool Function(Verse) bookmarked;
  final Future<void> Function(Verse) onBookmark;
  final Future<void> Function(Verse) onRead;
  const ReaderPage({
    super.key, required this.verses, required this.fontSize,
    required this.bookmarked, required this.onBookmark, required this.onRead,
    this.surah, this.jumpTo,
  });
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final List<Verse> items = widget.verses
      .where((v) => widget.surah == null || v.surah == widget.surah)
      .toList(growable: false);
  final ItemScrollController controller = ItemScrollController();
  late final int initialIndex = widget.jumpTo == null ? 0 : (() {
    final index = items.indexWhere((v) => v.key == widget.jumpTo);
    return index < 0 ? 0 : index;
  })();
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.surah == null
          ? 'المصحف الشريف' : 'سورة ${surahNames[widget.surah! - 1]}'),
        actions: [
          IconButton(
            tooltip: 'الانتقال إلى آية',
            icon: const Icon(Icons.pin_drop_outlined),
            onPressed: () async {
              final input = TextEditingController();
              final target = await showDialog<int>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('الانتقال إلى رقم الآية'),
                  content: TextField(
                    controller: input,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'رقم الآية في السورة الحالية'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(input.text)),
                      child: const Text('انتقال')),
                  ],
                ),
              );
              input.dispose();
              if (!context.mounted || target == null || target < 1) return;
              final index = items.indexWhere((v) =>
                v.ayah == target && (widget.surah == null || v.surah == widget.surah));
              if (index < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رقم الآية غير موجود')));
              } else {
                controller.scrollTo(index: index,
                  duration: const Duration(milliseconds: 350));
              }
            },
          ),
          IconButton(
            tooltip: 'معلومات الحفظ',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('العلامات المرجعية'),
                content: const Text('اضغط رمز العلامة بجانب أي آية لحفظها. يمكنك فتح العلامات من تبويب المفضلة في الصفحة الرئيسية.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
              ),
            ),
          ),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: controller,
        initialScrollIndex: initialIndex,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final v = items[i];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(v.text, textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: widget.fontSize, height: 2)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text('${surahNames[v.surah - 1]} • آية ${v.ayah}')),
                  IconButton(
                    tooltip: 'حفظ موضع القراءة',
                    icon: const Icon(Icons.history),
                    onPressed: () => widget.onRead(v),
                  ),
                  IconButton(
                    tooltip: 'إضافة أو إزالة علامة مرجعية',
                    icon: Icon(widget.bookmarked(v) ? Icons.bookmark : Icons.bookmark_outline),
                    onPressed: () async {
                      await widget.onBookmark(v);
                      if (mounted) setState(() {});
                    },
                  ),
                ]),
              ],
            )));
        },
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  final List<Verse> verses;
  final void Function(Verse) onSelect;
  const SearchPage({super.key, required this.verses, required this.onSelect});
  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final term = normalizedArabic(query);
    final matches = term.isEmpty ? <Verse>[] : widget.verses
        .where((v) => normalizedArabic(v.text).contains(term)).take(100).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'ابحث في القرآن دون تشكيل', prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder()),
          onChanged: (value) => setState(() => query = value),
        )),
      if (term.isNotEmpty) Padding(padding: const EdgeInsets.all(8),
        child: Text('أول ${matches.length} نتيجة (بحد أقصى 100)')),
      Expanded(child: ListView.builder(itemCount: matches.length,
        itemBuilder: (context, i) {
          final v = matches[i];
          return ListTile(
            title: Text(v.text, maxLines: 3, overflow: TextOverflow.ellipsis),
            subtitle: Text('سورة ${surahNames[v.surah - 1]}، الآية ${v.ayah}'),
            onTap: () => widget.onSelect(v),
          );
        })),
    ]);
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24),
    children: const [
      Icon(Icons.menu_book, size: 72),
      SizedBox(height: 14),
      Text('نور القرآن', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      Text('تطبيق مجاني للقرآن الكريم، صدقة جارية على روح الوالد وعلى روح يحيى يحيى راجح تميم.'),
      SizedBox(height: 16),
      Text('المصدر: Tanzil Project — Quran Uthmani Text v1.1'),
      Text('النص القرآني من مشروع Tanzil؛ النص محفوظ دون تعديل.'),
      SelectableText('https://tanzil.net/'),
      SizedBox(height: 12),
      Text('ترخيص النص: Creative Commons Attribution 3.0. النص من Tanzil Project، حقوق النشر © 2007–2021 Tanzil Project. يُسمح بتوزيع نسخ مطابقة للنص، ولا يُسمح بتغيير النص القرآني. يجب ذكر المصدر وإرفاق الرابط https://tanzil.net/ وإشعار الحقوق في النسخ الموزعة.'),
      SizedBox(height: 16),
      Text('نور القرآن تطبيق مستقل، غير تابع لمشروع Quran.tv.'),
      Text('لا يلزم إنشاء حساب لاستخدام التطبيق؛ التفضيلات والعلامات المرجعية تُحفظ على الجهاز فقط. لا يطلب هذا الإصدار اسمًا أو هاتفًا أو بريدًا إلكترونيًا.'),
    ]);
}
