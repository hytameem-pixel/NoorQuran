import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart' show Verse, surahNames;

class MushafNavigation {
  final List<int> pages;
  final List<int> juz;
  final List<int> quarters;
  const MushafNavigation(this.pages, this.juz, this.quarters);

  static Future<MushafNavigation> load() async {
    final raw = await rootBundle.loadString('assets/content/quran/hafs_navigation.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    List<int> list(String key) => (data[key] as List<dynamic>).cast<int>();
    final p = list('pages'), j = list('juz'), q = list('quarters');
    bool valid(List<int> values, int expected) =>
      values.length == expected && values.first == 1 &&
      values.last <= 6236 && values.asMap().entries.skip(1)
        .every((entry) => entry.value > values[entry.key - 1]);
    if (data['riwaya'] != 'Hafs' ||
        !valid(p, 604) || !valid(j, 30) || !valid(q, 240)) {
      throw const FormatException('Invalid mushaf navigation metadata');
    }
    return MushafNavigation(p, j, q);
  }

  int _section(List<int> starts, int verseId) {
    var low = 0, high = starts.length - 1;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (starts[mid] <= verseId) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return high + 1;
  }

  int pageOf(int globalVerseId) => _section(pages, globalVerseId);
  int juzOf(int globalVerseId) => _section(juz, globalVerseId);
  int quarterOf(int globalVerseId) => _section(quarters, globalVerseId);
}

class MushafPagesPage extends StatefulWidget {
  final List<Verse> verses;
  final bool Function(Verse) bookmarked;
  final Future<void> Function(Verse) onBookmark;
  final Future<void> Function(Verse) onRead;
  const MushafPagesPage({
    super.key, required this.verses, required this.bookmarked,
    required this.onBookmark, required this.onRead,
  });
  @override
  State<MushafPagesPage> createState() => _MushafPagesPageState();
}

class _MushafPagesPageState extends State<MushafPagesPage> {
  late final Future<MushafNavigation> navigation = MushafNavigation.load();
  int page = 1;
  bool night = false;

  void _go(int target) {
    if (target >= 1 && target <= 604) setState(() => page = target);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<MushafNavigation>(
    future: navigation,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(body: Center(child: Text('تعذر التحقق من فهرس صفحات المصحف')));
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final nav = snapshot.data!;
      final start = nav.pages[page - 1] - 1;
      final end = page == 604 ? widget.verses.length : nav.pages[page] - 1;
      final current = widget.verses.sublist(start, end);
      final first = current.first;
      final ink = night ? const Color(0xFFF5EED9) : const Color(0xFF302419);
      final paper = night ? const Color(0xFF24221F) : const Color(0xFFFFF9E9);
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('المصحف • صفحة $page'),
            actions: [
              IconButton(
                tooltip: night ? 'الوضع النهاري' : 'الوضع الليلي',
                icon: Icon(night ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () => setState(() => night = !night),
              ),
              IconButton(
                tooltip: 'الفهرس والانتقال إلى الصفحة',
                icon: const Icon(Icons.list_alt_outlined),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => SafeArea(child: SizedBox(
                    height: MediaQuery.sizeOf(ctx).height * .7,
                    child: ListView.builder(
                      itemCount: 604,
                      itemBuilder: (ctx, i) {
                        final v = widget.verses[nav.pages[i] - 1];
                        return ListTile(
                          title: Text('صفحة ${i + 1} • سورة ${surahNames[v.surah - 1]}'),
                          subtitle: Text('الجزء ${nav.juzOf(nav.pages[i])} • الآية ${v.ayah}'),
                          onTap: () { Navigator.pop(ctx); _go(i + 1); },
                        );
                      },
                    ),
                  )),
                ),
              ),
            ],
          ),
          body: Column(children: [
            Expanded(child: Container(
              color: paper,
              child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), children: [
                Text('سورة ${surahNames[first.surah - 1]} • الجزء ${nav.juzOf(start + 1)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, color: ink, fontWeight: FontWeight.bold)),
                const Divider(),
                for (final verse in current)
                  Column(children: [
                    SelectableText(verse.text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 25, height: 2.1, color: ink)),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('۞ ${verse.ayah}', style: TextStyle(color: ink)),
                      IconButton(
                        tooltip: 'حفظ موضع القراءة',
                        color: ink,
                        icon: const Icon(Icons.history),
                        onPressed: () => widget.onRead(verse),
                      ),
                      IconButton(
                        tooltip: 'حفظ العلامة',
                        color: ink,
                        icon: Icon(widget.bookmarked(verse) ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () async {
                          await widget.onBookmark(verse);
                          if (mounted) setState(() {});
                        },
                      ),
                    ]),
                  ]),
                const SizedBox(height: 8),
                Text('صفحة $page من 604', textAlign: TextAlign.center,
                  style: TextStyle(color: ink)),
              ]),
            )),
            SafeArea(top: false, child: Row(children: [
              IconButton(
                tooltip: 'الصفحة السابقة',
                onPressed: page > 1 ? () => _go(page - 1) : null,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
              Expanded(child: Slider(
                value: page.toDouble(), min: 1, max: 604, divisions: 603,
                label: '$page', onChanged: (v) => _go(v.round()),
              )),
              IconButton(
                tooltip: 'الصفحة التالية',
                onPressed: page < 604 ? () => _go(page + 1) : null,
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ])),
          ]),
        ),
      );
    },
  );
}
