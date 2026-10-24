import 'package:flutter/material.dart';

void main() => runApp(const NoorQuranApp());

class NoorQuranApp extends StatelessWidget {
  const NoorQuranApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'نور القرآن',
    locale: const Locale('ar'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نور القرآن')),
        body: const Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('صدقة جارية على روح الوالد وعلى روح يحيى يحيى راجح تميم\n\nيُستكمل المحتوى القرآني الموثّق قبل النشر.', textAlign: TextAlign.center),
        )),
      ),
    ),
  );
}
