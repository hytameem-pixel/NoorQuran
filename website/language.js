/* Noor Quran interface language layer.
 * Religious source text stays as supplied by its cited source.
 * Add locales through register() without changing the UI renderer.
 */
(()=> {
  const dictionaries = {
    ar: {},
    en: {
      "الرئيسية":"Home","المصحف الشريف":"Holy Quran","فهرس القرآن":"Quran index","الفهرس":"Index","التلاوات الصوتية":"Recitations",
      "تحميل التطبيق":"Get the app","فهرس التنزيلات":"Downloads","فهرس المواد والتنزيلات":"Materials and downloads","المكتبة الإسلامية":"Islamic library",
      "نتعلم ونرتقي":"Learn and grow","أكاديمية الحفظ":"Memorization academy","براعم نور القرآن":"Noor Quran for children",
      "علاماتي المرجعية":"Bookmarks","التنزيلات والمساحة":"Downloads and storage","حماية بياناتي":"My data and privacy",
      "رحلتك مع القرآن":"Your Quran journey","بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ":"In the name of Allah, the Most Compassionate, the Most Merciful",
      "بلا إعلانات":"Ad-free","إعدادات القراءة":"Reading settings","كل يوم، أقرب إلى القرآن":"Closer to the Quran, every day",
      "اقرأ، واستمع، وراجع وردك من موضعك الأخير":"Read, listen, and continue from where you left off",
      "رفيقك في التلاوة والتدبّر":"Your companion for recitation and reflection","رحلة نور، وأثر يبقى":"A journey of light that leaves a lasting impact",
      "ابدأ بما يناسب وقتك. إنجازك محفوظ على هذا الجهاز، ويمكنك نسخه احتياطيًا.":"Start at your own pace. Your progress stays on this device and can be backed up.",
      "متابعة القراءة":"Continue reading","دليلك لأول زيارة":"A guide for your first visit","ابدأ بقراءة المصحف":"Start reading the Quran",
      "أو افتح فهرس السور والصفحات.":"or open the surah and page index.","استفد من":"Explore the",
      "والتفاسير والأذكار والقصص التفاعلية.":"with tafsir, adhkar, and interactive stories.",
      "اختر مادة محددة من":"Choose an item from the","واحفظ ما تحتاجه دون اتصال.":"and save what you need for offline use.",
      "العلامات والتقدم والملفات المحفوظة تبقى على هذا الجهاز والمتصفح؛ لا يلزم إنشاء حساب.":"Bookmarks, progress, and saved files stay on this device and browser. No account is required.",
      "متابعة الاستماع":"Continue listening","ورد اليوم":"Today's reading","أبواب نور القرآن":"Explore Noor Quran",
      "فهرس السور والأجزاء":"Surah and juz index","انتقل إلى السورة أو الجزء أو الصفحة.":"Go to a surah, juz, or page.",
      "مكتبة التلاوات":"Recitation library","٨ قراء، مع تنزيل اختياري للاستماع دون اتصال.":"Eight reciters, with optional downloads for offline listening.",
      "تفاسير وحديث وأذكار مع توثيق المصادر.":"Tafsir, hadith, and adhkar with source references.",
      "ملفات مستقلة، ومقاطع قصيرة، ومراجعة هادئة.":"Short, standalone lessons and calm review activities.",
      "تثبيت الموقع على الهاتف":"Install on your phone","المصادر والإصدارات":"Sources and versions","الخصوصية":"Privacy","نور القرآن على هاتفك":"Noor Quran on your phone","اختر نسخة واضحة الحالة، واحمِ بياناتك قبل الانتقال.":"Choose a clearly labeled build and protect your data before switching.","القراءة والحفظ والتنزيلات، في تجربة واحدة":"Reading, memorization, and downloads in one place","نسخة الموقع الحالية تدعم التثبيت والنسخ الاحتياطي وإدارة الملفات.":"The current website supports installation, backups, and file management.","هذه نسخة اختبار وليست إصدار متجر. لم أتحقق هنا من توقيعها ولم أختبر تثبيتها على هاتف فعلي. يطابق ملف APK بصمة SHA-256 المنشورة في الفهرس. حجمه نحو 24.3 ميجابايت ويُستضاف على Sites؛ ترخيص إعادة توزيعه خارج الاستضافة غير موثق، لذلك لم يُنسخ إلى مستودع GitHub.":"This is a test build, not a store release. Its signature and installation on a physical phone were not verified here. The APK matches the SHA-256 published in the catalog. It is about 24.3 MB and hosted on Sites; redistribution rights outside that host are undocumented, so it was not mirrored to GitHub.","آيفون · iOS":"iPhone · iOS","ملف IPA غير متاح":"IPA unavailable","حزمة المصدر ليست تطبيقًا قابلًا للتثبيت. يحتاج بناء iOS إلى Mac وXcode وإعداد توقيع Apple.":"The source archive is not an installable app. Building iOS requires a Mac, Xcode, and Apple signing setup.""ملاحظة على الموقع: h.y.tameem@gmail.com":"Site feedback: h.y.tameem@gmail.com",
      "الدعم والبلاغات":"Support and feedback","تثبيت الموقع":"Install site","تجاوز إلى المحتوى":"Skip to content",
      "ابحث عن مادة":"Search materials","اختر القارئ":"Choose a reciter","السورة":"Surah","جارٍ فحص فهرس المواد…":"Loading the materials index…",
      "التنقل":"Navigation","التطبيقات وملفات المشروع":"Apps and project files","تطبيق Android · 2.0":"Android app · 2.0","مشروع Android وiOS":"Android and iOS project","نسخة الموقع":"Website version","قبل التثبيت والاستخدام دون اتصال":"Before installation and offline use","تعليمات تثبيت الموقع":"Website installation instructions","المتاح الآن على آيفون: نسخة الموقع":"Available now on iPhone: the website","رابط APK المباشر":"Direct APK link","التطبيقات | نور القرآن":"Apps | Noor Quran",
      "فهرس التنزيلات | نور القرآن":"Downloads | Noor Quran","العودة إلى نور القرآن":"Back to Noor Quran",
      "انتقل إلى المواد":"Skip to materials","المواد المتاحة للتنزيل":"Available downloads",
      "تنزيل واضح قبل الضغط":"Clear information before downloading","اختر مادة محددة، راجع حجمها ومصدرها، ثم نزّلها. لا يبدأ تنزيل كبير تلقائيًا.":"Choose an item, review its size and source, then download it. Large downloads never start automatically.",
      "الملفات المحفوظة من داخل الموقع تبقى على هذا المتصفح وهذا الجهاز. امسح الملفات من «إدارة التنزيلات» عند الحاجة إلى مساحة.":"Files saved from the site stay on this device and browser. Remove them from Downloads when you need space.",
      "الروابط الموسومة بأنها خارجية تفتح على جهة الاستضافة؛ إذا ظهر خطأ أو تعذر التنزيل، استخدم رابط المصدر الرسمي أو أعد المحاولة لاحقًا.":"External links open on their host. If a download fails, use the official source link or try again later.",
      "إدارة التنزيلات ←":"Manage downloads ←","نسخة احتياطية ←":"Back up data ←","لا توجد نتائج":"No results found",
      "لم نعثر على نتائج. جرّب كلمة أخرى.":"No results found. Try another search."
    }
  };
  const originals = new WeakMap();
  const attrOriginals = new WeakMap();
  const localeKey="noor-language";
  let locale="ar", busy=false;
  window.NoorI18n = {
    register(code, entries){ if(!/^[a-z]{2,3}(-[A-Z]{2})?$/.test(code)) return false; dictionaries[code]={...(dictionaries[code]||{}),...entries}; return true; },
    get locale(){return locale;},
    setLocale(code){if(!dictionaries[code]) return false; locale=code; try{localStorage.setItem(localeKey,code)}catch{}; apply(); return true;}
  };
  function translated(s){return locale==="ar" ? s : (dictionaries[locale]?.[s] ?? s);}
  function apply(){
    if(busy)return; busy=true;
    const root=document.body;
    if(!root){busy=false;return}
    document.documentElement.lang=locale==="ar"?"ar":locale;
    document.documentElement.dir=locale==="ar"?"rtl":"ltr";
    const walker=document.createTreeWalker(root,NodeFilter.SHOW_TEXT);
    let node;
    while((node=walker.nextNode())){
      if(!originals.has(node)) originals.set(node,node.nodeValue);
      const original=originals.get(node), next=translated(original);
      if(node.nodeValue!==next) node.nodeValue=next;
    }
    for(const el of root.querySelectorAll("[aria-label],[placeholder],[title]")){
      let saved=attrOriginals.get(el); if(!saved){saved={};attrOriginals.set(el,saved)}
      for(const attr of ["aria-label","placeholder","title"]){
        const value=el.getAttribute(attr); if(value===null)continue;
        if(!(attr in saved)) saved[attr]=value;
        const next=translated(saved[attr]); if(value!==next)el.setAttribute(attr,next);
      }
    }
    const button=document.getElementById("language-toggle");
    if(button){button.textContent=locale==="ar"?"English":"العربية";button.setAttribute("aria-label",locale==="ar"?"Switch interface to English":"حوّل الواجهة إلى العربية")}
    busy=false;
  }
  function boot(){
    try{const stored=localStorage.getItem(localeKey);if(stored&&dictionaries[stored])locale=stored}catch{}
    const button=document.getElementById("language-toggle");
    if(button)button.addEventListener("click",()=>window.NoorI18n.setLocale(locale==="ar"?"en":"ar"));
    const observer=new MutationObserver(()=>{if(!busy)apply()});
    observer.observe(document.body,{childList:true,subtree:true,characterData:true});
    apply();
  }
  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",boot,{once:true});else boot();
})();
