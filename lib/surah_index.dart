import 'package:flutter/material.dart';
import 'main.dart' show Verse, surahNames;

class SurahIndexPage extends StatefulWidget {
  final List<Verse> verses;
  final void Function(int surah) onOpen;
  const SurahIndexPage({super.key, required this.verses, required this.onOpen});
  @override
  State<SurahIndexPage> createState() => _SurahIndexPageState();
}

class _SurahIndexPageState extends State<SurahIndexPage> {
  String search = '';
  late final List<int> counts = List.generate(114, (i) =>
      widget.verses.where((v) => v.surah == i + 1).length);
  @override
  Widget build(BuildContext context) {
    final filtered = List.generate(114, (i) => i + 1).where((n) =>
      search.trim().isEmpty ||
      surahNames[n - 1].contains(search.trim()) ||
      n.toString().contains(search.trim())).toList();
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('فهرس سور القرآن الكريم')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'ابحث باسم السورة أو رقمها',
            border: OutlineInputBorder()),
          onChanged: (v) => setState(() => search = v),
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('١١٤ سورة • ٦٢٣٦ آية • النص العثماني متاح دون اتصال')),
        Expanded(child: filtered.isEmpty
          ? const Center(child: Text('لم يُعثر على سورة بهذا الاسم'))
          : ListView.builder(itemCount: filtered.length, itemBuilder: (context, i) {
            final n = filtered[i];
            return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ListTile(
                leading: CircleAvatar(child: Text('$n')),
                title: Text('سورة ${surahNames[n - 1]}'),
                subtitle: Text('${counts[n - 1]} آية'),
                trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                onTap: () => widget.onOpen(n),
              ));
          })),
      ]),
    ));
  }
}
