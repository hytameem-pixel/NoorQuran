import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-only export/import for reading progress and memorization.
/// No network, accounts, or child-identifying information.
class LocalDataPage extends StatefulWidget {
  const LocalDataPage({super.key});
  @override
  State<LocalDataPage> createState() => _LocalDataPageState();
}

class _LocalDataPageState extends State<LocalDataPage> {
  static const keys = <String>[
    'bookmarks', 'memorized_verses', 'review_verses',
    'last_surah', 'last_ayah', 'font_size', 'dark_mode',
    'memorization_daily_goal', 'memorization_repeat_count',
  ];
  final input = TextEditingController();
  String message = '';

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  bool _validVerseKey(String key) {
    final parts = key.split(':');
    if (parts.length != 2) return false;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    return surah != null && surah >= 1 && surah <= 114 &&
        ayah != null && ayah >= 1 && ayah <= 286;
  }

  Future<void> _export() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in keys) {
      if (prefs.containsKey(key)) data[key] = prefs.get(key);
    }
    // Daily completion keys are stored by date.
    for (final key in prefs.getKeys()) {
      if (RegExp(r'^memorized_today_\d{4}-\d{2}-\d{2}$').hasMatch(key)) {
        data[key] = prefs.getStringList(key);
      }
    }
    final payload = jsonEncode({'schema': 1, 'data': data});
    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    setState(() => message = 'تم نسخ النسخة الاحتياطية. احفظها في مكان خاص وآمن.');
  }

  Future<void> _import() async {
    try {
      if (input.text.length > 500000) throw const FormatException('ملف كبير جدًا');
      final payload = jsonDecode(input.text);
      if (payload is! Map || payload['schema'] != 1 || payload['data'] is! Map) {
        throw const FormatException('صيغة النسخة الاحتياطية غير صحيحة');
      }
      final data = Map<String, dynamic>.from(payload['data'] as Map);
      final approved = <String, Object>{};
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        final isDaily = RegExp(r'^memorized_today_\d{4}-\d{2}-\d{2}$').hasMatch(key);
        if (!keys.contains(key) && !isDaily) continue;
        if (key == 'bookmarks' || key == 'memorized_verses' ||
            key == 'review_verses' || isDaily) {
          if (value is! List || value.length > 6236 ||
              value.any((v) => v is! String || !_validVerseKey(v))) {
            throw const FormatException('قائمة آيات غير صالحة');
          }
          approved[key] = List<String>.from(value);
        } else if (key == 'dark_mode') {
          if (value is! bool) throw const FormatException('إعداد غير صالح');
          approved[key] = value;
        } else if (key == 'font_size') {
          if (value is! num || value < 18 || value > 40) {
            throw const FormatException('حجم خط غير صالح');
          }
          approved[key] = value.toDouble();
        } else {
          if (value is! int) throw const FormatException('قيمة غير صالحة');
          final valid = switch (key) {
            'last_surah' => value >= 1 && value <= 114,
            'last_ayah' => value >= 1 && value <= 286,
            'memorization_daily_goal' => value >= 1 && value <= 20,
            'memorization_repeat_count' => value >= 1 && value <= 10,
            _ => false,
          };
          if (!valid) throw const FormatException('قيمة خارج النطاق');
          approved[key] = value;
        }
      }
      if (approved.isEmpty) throw const FormatException('لا توجد بيانات صالحة');
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('استعادة النسخة الاحتياطية'),
          content: const Text('سيتم استبدال البيانات المطابقة في هذا الجهاز. هل تريد المتابعة؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('استعادة')),
          ],
        ),
      );
      if (confirmed != true) return;
      final prefs = await SharedPreferences.getInstance();
      for (final entry in approved.entries) {
        final value = entry.value;
        if (value is List<String>) {
          await prefs.setStringList(entry.key, value);
        } else if (value is bool) {
          await prefs.setBool(entry.key, value);
        } else if (value is double) {
          await prefs.setDouble(entry.key, value);
        } else if (value is int) {
          await prefs.setInt(entry.key, value);
        }
      }
      if (!mounted) return;
      setState(() => message = 'تمت الاستعادة. أغلق التطبيق وافتحه لتحديث العرض.');
    } catch (_) {
      if (!mounted) return;
      setState(() => message = 'تعذر الاستعادة: تحقق من أن النص نسخة احتياطية سليمة من نور القرآن.');
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('النسخ الاحتياطي والاستعادة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('احفظ علامات القراءة والحفظ على جهازك. لا تُرسل البيانات إلى أي خادم.'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('نسخ بياناتي إلى الحافظة'),
        ),
        const SizedBox(height: 20),
        const Text('لاستعادة بياناتك: الصق النسخة الاحتياطية هنا.'),
        const SizedBox(height: 8),
        TextField(
          controller: input,
          minLines: 3,
          maxLines: 6,
          maxLength: 500000,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'الصق النص المنسوخ هنا',
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: _import,
          icon: const Icon(Icons.restore),
          label: const Text('استعادة البيانات'),
        ),
        if (message.isNotEmpty) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(message),
        ),
        const SizedBox(height: 12),
        const Text('تنبيه: النص المنسوخ يتضمن سجل القراءة والحفظ؛ لا تشاركه مع الآخرين. لا يُستعاد إلا المحتوى المعروف للتطبيق.'),
      ]),
    ),
  );
}
