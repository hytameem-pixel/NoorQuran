import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' show Verse, surahNames;

class MemorizationPage extends StatefulWidget {
  final List<Verse> verses;
  final bool kidsMode;
  const MemorizationPage({super.key, required this.verses, this.kidsMode = false});
  @override
  State<MemorizationPage> createState() => _MemorizationPageState();
}

class _MemorizationPageState extends State<MemorizationPage> {
  int selectedSurah = 114;
  int currentIndex = 0;
  bool showText = true;
  Set<String> memorized = {};
  Set<String> review = {};
  bool loaded = false;
  int dailyGoal = 3;
  int repeats = 3;
  Set<String> completedToday = {};
  String get todayKey => DateTime.now().toIso8601String().substring(0, 10);
  String get dayStorageKey => 'memorized_today_$todayKey';

  List<Verse> get currentVerses =>
      widget.verses.where((v) => v.surah == selectedSurah).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      memorized = (prefs.getStringList('memorized_verses') ?? []).toSet();
      review = (prefs.getStringList('review_verses') ?? []).toSet();
      dailyGoal = (prefs.getInt('memorization_daily_goal') ?? 3).clamp(1, 20);
      repeats = (prefs.getInt('memorization_repeat_count') ?? 3).clamp(1, 10);
      completedToday = (prefs.getStringList(dayStorageKey) ?? []).toSet();
      loaded = true;
    });
  }

  Future<void> _mark(Verse verse, {required bool mastered}) async {
    setState(() {
      if (mastered) {
        memorized.add(verse.key);
        completedToday.add(verse.key);
        review.remove(verse.key);
      } else {
        memorized.remove(verse.key);
        review.add(verse.key);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('memorized_verses', memorized.toList());
    await prefs.setStringList('review_verses', review.toList());
    await prefs.setStringList(dayStorageKey, completedToday.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mastered ? 'أحسنت! تم تسجيل الآية محفوظة' : 'أضيفت الآية إلى قائمة المراجعة'),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final verses = currentVerses;
    final savedCount = verses.where((v) => memorized.contains(v.key)).length;
    final progress = verses.isEmpty ? 0.0 : savedCount / verses.length;
    if (!loaded) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: Text(widget.kidsMode ? 'حفظ القرآن للصغار' : 'الحفظ والمراجعة')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        Card.filled(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.kidsMode ? '🌟 رحلتي مع القرآن' : 'خطة حفظ القرآن',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.kidsMode
              ? 'اقرأ الآية، أخفِ النص، ثم سمّعها لولي أمرك أو معلمك.'
              : 'احفظ الآيات، واختبر نفسك، وحدد ما يحتاج إلى مراجعة.'),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedSurah,
              decoration: const InputDecoration(labelText: 'اختر السورة', border: OutlineInputBorder()),
              isExpanded: true,
              items: List.generate(114, (i) => DropdownMenuItem(
                value: i + 1, child: Text('سورة ${surahNames[i]}'),
              )),
              onChanged: (value) {
                if (value != null) { setState(() {
                  selectedSurah = value;
                  currentIndex = 0;
                  showText = true;
                }); }
              },
            ),
            const SizedBox(height: 12),
            Text('الهدف اليومي: $dailyGoal آيات • المنجز اليوم: ${completedToday.length}'),
            LinearProgressIndicator(value: (completedToday.length / dailyGoal).clamp(0.0, 1.0),
              minHeight: 8, borderRadius: BorderRadius.circular(8)),
            Row(children: [
              const Expanded(child: Text('عدد الآيات المستهدف يوميًا')),
              DropdownButton<int>(
                value: dailyGoal,
                items: [1, 2, 3, 5, 7, 10, 15, 20]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  setState(() => dailyGoal = v);
                  await (await SharedPreferences.getInstance()).setInt('memorization_daily_goal', v);
                },
              ),
            ]),
            const Text('الاستماع والتكرار الصوتي يحتاجان إلى تسجيلات معتمدة وحقوق استخدام واضحة. لم تُضف تسجيلات غير مرخصة.'),
            Row(children: [
              const Expanded(child: Text('التكرارات الصوتية عند تفعيل المصدر')),
              DropdownButton<int>(
                value: repeats,
                items: [1, 2, 3, 5, 7, 10]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  setState(() => repeats = v);
                  await (await SharedPreferences.getInstance()).setInt('memorization_repeat_count', v);
                },
              ),
            ]),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 6),
            Text('تم حفظ $savedCount من ${verses.length} آية — ${(progress * 100).round()}٪'),
          ],
        ))),
        const SizedBox(height: 12),
        if (verses.isNotEmpty) ...[
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
            Text('الآية ${verses[currentIndex].ayah} من سورة ${surahNames[selectedSurah - 1]}',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            if (showText)
              SelectableText(verses[currentIndex].text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 27, height: 2.1))
            else
              const Padding(padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('ردد الآية من حفظك ثم اكشفها للمراجعة',
                  textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => setState(() => showText = !showText),
              icon: Icon(showText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              label: Text(showText ? 'إخفاء الآية للتسميع' : 'إظهار الآية للتحقق'),
            ),
            const SizedBox(height: 12),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                onPressed: () => _mark(verses[currentIndex], mastered: true),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('حفظتها'),
              ),
              OutlinedButton.icon(
                onPressed: () => _mark(verses[currentIndex], mastered: false),
                icon: const Icon(Icons.refresh),
                label: const Text('أحتاج مراجعة'),
              ),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton.icon(
                onPressed: currentIndex == 0 ? null : () => setState(() {
                  currentIndex--;
                  showText = true;
                }),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('السابقة'),
              ),
              Text('${currentIndex + 1} / ${verses.length}'),
              TextButton.icon(
                onPressed: currentIndex >= verses.length - 1 ? null : () => setState(() {
                  currentIndex++;
                  showText = true;
                }),
                icon: const Icon(Icons.arrow_back),
                label: const Text('التالية'),
              ),
            ]),
          ]))),
          const SizedBox(height: 12),
          Text('آيات تحتاج إلى مراجعة: ${verses.where((v) => review.contains(v.key)).length}'),
          const SizedBox(height: 8),
          if (widget.kidsMode)
            const Text('ملاحظة لولي الأمر: هذه أداة متابعة ذاتية وليست تقييمًا آليًا لصحة التلاوة. لا يُطلب من الطفل إدخال اسمه أو أي معلومات شخصية.'),
        ],
      ])),
    );
  }
}
