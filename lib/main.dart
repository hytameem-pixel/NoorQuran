import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const NoorApp());
class Verse {
 final int surah,ayah;final String text;
 Verse(this.surah,this.ayah,this.text);
 factory Verse.fromJson(Map<String,dynamic> x)=>Verse(x['surahId'] as int,x['ayahNumber'] as int,x['textUthmani'] as String);
}
class NoorApp extends StatelessWidget{
 const NoorApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'نور القرآن',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.teal),home:Directionality(textDirection:TextDirection.rtl,child:const QuranPage()));
}
class QuranPage extends StatefulWidget{const QuranPage({super.key});@override State<QuranPage> createState()=>_QuranState();}
class _QuranState extends State<QuranPage>{
 late final Future<List<Verse>> data=_load();int? selected;String search='';
 Future<List<Verse>> _load()async{
  final raw=await rootBundle.loadString('assets/content/quran/quran.json');
  final j=jsonDecode(raw) as Map<String,dynamic>;
  final list=(j['verses'] as List).map((v)=>Verse.fromJson(v as Map<String,dynamic>)).toList();
  if(j['surah_count']!=114||list.length!=6236)throw const FormatException('Incomplete Quran');
  return list;
 }
 @override Widget build(BuildContext context)=>Scaffold(
 appBar:AppBar(title:const Text('نور القرآن'),actions:[IconButton(icon:const Icon(Icons.person_outline),tooltip:'الملف الاختياري',onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ProfilePage())))]),
 body:FutureBuilder<List<Verse>>(future:data,builder:(context,s){
  if(s.hasError)return const Center(child:Text('القرآن الموثق غير متاح في هذه النسخة؛ تم منع عرض محتوى ناقص.'));
  if(!s.hasData)return const Center(child:CircularProgressIndicator());
  final list=s.data!.where((v)=>(selected==null||v.surah==selected)&&(search.isEmpty||v.text.contains(search))).toList();
  return Column(children:[
   Padding(padding:const EdgeInsets.all(12),child:Column(children:[
    DropdownButtonFormField<int>(initialValue:selected,decoration:const InputDecoration(labelText:'اختر السورة'),items:[
      const DropdownMenuItem<int>(value:null,child:Text('كل السور')),
      ...List.generate(114,(i)=>DropdownMenuItem<int>(value:i+1,child:Text('السورة ${i+1}')))],
      onChanged:(v)=>setState(()=>selected=v)),
    TextField(decoration:const InputDecoration(labelText:'بحث في القرآن',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState(()=>search=v.trim())),
   ])),
   Expanded(child:ListView.builder(itemCount:list.length,itemBuilder:(context,i){final v=list[i];return Card(child:ListTile(
    title:SelectableText(v.text,style:const TextStyle(fontSize:25,height:1.8)),
    subtitle:Text('سورة ${v.surah} — آية ${v.ayah}'),
    trailing:IconButton(icon:const Icon(Icons.bookmark_add_outlined),onPressed:()async{
     final p=await SharedPreferences.getInstance();await p.setInt('last_surah',v.surah);await p.setInt('last_ayah',v.ayah);
    })));})),
  ]);
 }));
}
class ProfilePage extends StatefulWidget{const ProfilePage({super.key});@override State<ProfilePage> createState()=>_ProfileState();}
class _ProfileState extends State<ProfilePage>{
 final form=GlobalKey<FormState>();final name=TextEditingController(),phone=TextEditingController(),email=TextEditingController();bool consent=false;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();if(mounted)setState((){name.text=p.getString('profile_name')??'';phone.text=p.getString('profile_phone')??'';email.text=p.getString('profile_email')??'';consent=p.getBool('profile_consent')??false;});}
 Future<void> _save()async{
  if(!consent||!form.currentState!.validate())return;
  final p=await SharedPreferences.getInstance();await p.setString('profile_name',name.text.trim());await p.setString('profile_phone',phone.text.trim());await p.setString('profile_email',email.text.trim());await p.setBool('profile_consent',true);
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم الحفظ على هذا الجهاز فقط')));
 }
 Future<void> _erase()async{
  final p=await SharedPreferences.getInstance();for(final k in ['profile_name','profile_phone','profile_email','profile_consent']){await p.remove(k);}
  if(mounted)setState((){name.clear();phone.clear();email.clear();consent=false;});
 }
 @override void dispose(){name.dispose();phone.dispose();email.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('ملفي الاختياري')),body:Form(key:form,child:ListView(padding:const EdgeInsets.all(20),children:[
 const Text('الاسم والهاتف والبريد اختيارية. يمكنك استخدام القرآن دون حساب. البيانات محلية فقط ولا تُرسل إلى خادم.'),
 TextFormField(controller:name,maxLength:100,decoration:const InputDecoration(labelText:'الاسم (اختياري)')),
 TextFormField(controller:phone,maxLength:25,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'الهاتف (اختياري)')),
 TextFormField(controller:email,maxLength:254,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'البريد (اختياري)'),validator:(v)=>v==null||v.isEmpty||RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)?null:'البريد غير صحيح'),
 CheckboxListTile(value:consent,onChanged:(v)=>setState(()=>consent=v??false),title:const Text('أوافق على الحفظ المحلي')),
 FilledButton(onPressed:consent?_save:null,child:const Text('حفظ اختياري')),
 TextButton(onPressed:_erase,child:const Text('حذف بياناتي')),
 ])));
}