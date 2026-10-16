# سياسة الخصوصية — تطبيق المؤمن (AlMomin Privacy Policy)

**تاريخ السريان**: 16 أكتوبر 2026  
**الإصدار**: 1.2.0  
**الغرض**: صدقة جارية عن روح المرحوم بإذن الله تعالى: **مؤمن إبراهيم رحمه الله**  
**المستودع الرسمي**: [https://github.com/ahmdnmrahmednamer-pixel/almomin-..git](https://github.com/ahmdnmrahmednamer-pixel/almomin-..git)

---

## 1. التزام الخصوصية والشفافية التامة (Zero-Tracking Commitment)
تطبيق **المؤمن (AlMomin)** هو تطبيق إسلامي مفتوح المصدر تم تطويره ابتغاء الأجر والثواب كصدقة جارية، وهو مجاني بالكامل وخالٍ تماماً من أي شكل من أشكال الربح المادي.
* **خالٍ تماماً من الإعلانات (Zero Ads)**: لا يحتوي التطبيق على أي شبكات إعلانية أو إعلانات تجارية بأي شكل.
* **خالٍ تماماً من التتبع والتحليلات (Zero Analytics / Zero Telemetry)**: لا نستخدم أي حزم تتبع، أو أدوات تحليل سلوك المستخدم (مثل Google Firebase Analytics, Mixpanel, AppsFlyer)، ولا نجمع أي معرفات فريدة للهاتف (Advertising ID).
* **يعمل 100% بدون خوادم خارجية (Serverless & Offline-First)**: تتم كافة الحسابات (مواقيت الصلاة، القبلة، البحث القرآني، حفظ التدبرات والختمات) محلياً داخل جهازك دون إرسال أي معلومة إلى أي خادم خارجي.

---

## 2. الأذونات المستخدمة والغرض الهندسي منها (Permissions & Usage)

### أ. إذن الموقع الجغرافي (`ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`)
* **الغرض**: يُستخدم لمرة واحدة فقط لتحديد إحداثيات خطوط الطول والعرض لمدينتك بهدف الحساب الفلكي الدقيق لمواقيت الصلوات الخمس واتجاه الكعبة المشرفة بدقة البوصلة.
* **الخصوصية**: تُعالج الإحداثيات محلياً على هاتفك فقط، ولا يتم إرسالها أو حفظها في أي قاعدة بيانات خارجية. كما يتيح التطبيق إمكانية اختيار المدينة يدوياً من قائمة المدن دون منح إذن الموقع إطلاقاً.

### ب. إذن المنبهات الدقيقة والإشعارات (`SCHEDULE_EXACT_ALARM` / `POST_NOTIFICATIONS`)
* **الغرض**: جدولة تنبيهات الأذان والصلوات الخمس بدقة متناهية في وقتها الشرعي، وعرض إشعارات الأذكار المسائية والصباحية.
* **الخصوصية**: تتم الجدولة محلياً عبر نظام أندرويد الداخلي دون أي اتصال خارجي.

### ج. إذن تشغيل التلاوات في الخلفية (`FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MEDIA_PLAYBACK`)
* **الغرض**: استمرار الاستماع لتلاوات القرآن الكريم وسور القارئ المفضل عند إغلاق الشاشة أو تصفح تطبيقات أخرى.

### د. إذن التخزين والملفات (`WRITE_EXTERNAL_STORAGE` / App-Specific Storage)
* **الغرض**: حفظ السور المحملة للاستماع دون إنترنت في مجلد التطبيق المخصص (`quran_audio`)، وتصدير ملف النسخة الاحتياطية `almomin_backup.json` عندما يطلب المستخدم حفظ بياناته.

---

## 3. حفظ البيانات وسيطرة المستخدم الكاملة (Data Ownership & Retention)
* كافة بياناتك الشخصية (العلامات المرجعية، سجل الصلوات والسنن، خطط الختمة، عداد السبحة، وخواطر التدبر القرآني) تُحفظ حصرياً داخل الذاكرة المحلية لجهازك (`SharedPreferences`).
* يمكنك في أي وقت:
  1. **تصدير نسختك الاحتياطية**: عبر شاشة النسخ الاحتياطي وحفظها أينما تشاء.
  2. **حذف أو تصفير البيانات**: بحذف التطبيق أو مسح بيانات التخزين المؤقت من إعدادات الهاتف، وسيتم مسح كافة البيانات نهائياً دون بقاء أي أثر لها.

---

## 4. خصوصية الأطفال والأسرة (Family & Children Privacy)
التطبيق مناسب لجميع أفراد الأسرة وللأطفال من كافة الفئات العمرية. ونظراً لعدم جمعنا لأي بيانات من الأساس، فإن التطبيق متوافق تماماً مع متطلبات **قانون حماية خصوصية الأطفال على الإنترنت (COPPA)** وقوانين حماية البيانات العامة (**GDPR**).

---

## 5. التواصل والإبلاغ عن أخطاء المحتوى (Contact & Content Corrections)
إن وجدت أي ملاحظة في النصوص أو رغبت في الاستفسار عن سياسة الخصوصية، يسعدنا تواصلكم عبر المستودع الرسمي للمشروع على GitHub:
- **صفحة الإبلاغ عن المسائل**: [https://github.com/ahmdnmrahmednamer-pixel/almomin-..git/issues](https://github.com/ahmdnmrahmednamer-pixel/almomin-..git/issues)

---

# English Summary (Google Play Data Safety Compliance)
**AlMomin App** is a completely free, open-source Islamic application created as an ongoing charity (Sadaqa Jariya) in loving memory of **Momin Ibrahim رحمه الله**.
* **Data Collection**: NONE. We do not collect, share, or sell any personal information, location data, or device identifiers.
* **Advertisements**: NONE. The app contains zero ads and zero third-party monetization.
* **Location Usage**: Location is accessed only on-device to compute local prayer times and the Qibla compass bearing. It is never transmitted off your device.
* **Data Security**: All user records (bookmarks, reflections, prayer habits) are stored in the device's sandboxed local storage with zero cloud dependencies.
