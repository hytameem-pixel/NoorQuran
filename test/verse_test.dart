import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart';
void main(){test('Verse decoding',(){final v=Verse.fromJson({'surahId':1,'ayahNumber':1,'textUthmani':'نص'});expect(v.ayah,1);expect(v.text,'نص');});}
