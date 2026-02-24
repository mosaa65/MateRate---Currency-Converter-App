# MateRate - Currency Converter App 💱

**MateRate** is a beautifully designed, fast, and reliable currency conversion application built with Flutter. It provides real-time exchange rates, local caching for offline use, and a seamless user experience.

## 🌟 الميزات (Features)
- 🚀 **أسعار العملات الحية (Real-time Rates):** تحديثات دقيقة للأسعار لكل عملات العالم تقريباً باستخدام API موثوق.
- 📴 **وضع عدم الاتصال (Offline Mode):** يتم حفظ آخر أسعار تم جلبها في الهاتف لتتمكن من استخدام التطبيق في حال عدم توفر شبكة إنترنت.
- 📊 **التغيير في الأسعار (Percentage Change):** يعرض التطبيق نسبة الصعود والهبوط في قيمة العملة مقابل العملة الأساسية بشكل مرئي واضح ومريح.
- 💱 **التحويل المزدوج (Pair Conversion):** شاشات خاصة مخصصة لتحويل مبالغ محددة بين أي عملتين بسرعة وسلاسة.
- 🎨 **تصميم عصري وجذاب (Elegant UI):** واجهة مستخدم مبنية بعناية باستخدام Material Design وخطوط مخصصة (مثل Cairo للغة العربية).
- 📱 **دعم الإعلانات (Ads Integration):** تطبيق مدمج به حزمة Google Mobile Ads بطريقة نظيفة (Clean Code).
- 🌍 **دعم كامل للغة العربية (RTL Support):** التطبيق موجه للمستخدمين العرب بواجهات عربية بشكل أساسي.

## 🛠️ التقنيات المستخدمة (Tech Stack)
- **إطار العمل (Framework):** Flutter (Dart)
- **مزود البيانات (API):** [ExchangeRate-API](https://www.exchangerate-api.com/)
- **أبرز حزم فلاتر (Flutter Packages):** 
  - `http` لجلب البيانات من الإنترنت.
  - `shared_preferences` لتخزين البيانات محلياً.
  - `google_mobile_ads` لإعلانات جوجل.
  - `connectivity_plus` للتحقق من الاتصال بالإنترنت.
  - `url_launcher` لفتح الروابط الخارجية.

## 📂 هيكلية المشروع (Folder Structure)
تم بناء المشروع وتقسيمه بشكل نظيف ومفهوم:
- `lib/core`: يحتوي على الثوابت (المقاسات)، الألوان، الأسرار والمفاتيح للإتصال الخارجي.
- `lib/models`: نماذج البيانات واستقبال الاستجابات من الخادم (Responses).
- `lib/screens`: شاشات العرض مقسمة إلى مجلدات فرعية لسهولة القراءة والصيانة (الرئيسية، شاشات التحويل، الإعدادات وغيرها).
- `lib/services`: الخدمات الخارجية مثل استدعاء الـ API وإدارة الإعلانات.
- `lib/widgets`: أجزاء الواجهة القابلة لإعادة الاستخدام (Reusable Widgets) لتقليل تكرار الأكواد.

## ⚙️ التثبيت والتشغيل المحلي (Setup & Installation)

### متطلبات النظام (Prerequisites)
- [تثبيت Flutter SDK](https://docs.flutter.dev/get-started/install) (الإصدار 3.7.2 فما فوق).
- محرر أكواد ذكي مثل Visual Studio Code أو Android Studio.

### خطوات التثبيت (Installation Steps)
1. **استنساخ المستودع (Clone the repo):**
   ```bash
   git clone https://github.com/YourUsername/MateRate-Currency-Converter.git
   cd MateRate-Currency-Converter
   ```
2. **تثبيت الحزم البرمجية (Install dependencies):**
   افتح الطرفية (Terminal) واكتب:
   ```bash
   flutter pub get
   ```
3. **إعداد مفتاح الـ API (Setup API Key):**
   - قم بالذهاب إلى موقع [ExchangeRate-API](https://www.exchangerate-api.com/) وقم بإنشاء حساب للحصول على مفتاح API مجاني.
   - اذهب إلى مسار `lib/core/secrets/secrets.dart` وقم بتعريف المفتاح بداخل المتغير المناسب. (بناءً على الكود الخاص بك):
     ```dart
     class Secrets {
       static const String exchangeRateApiKey = 'YOUR_API_KEY_HERE';
     }
     ```
4. **تشغيل التطبيق (Run the app):**
   تأكد من توصيل الجوال (أو محاكي) وقم بتشغيل الأمر:
   ```bash
   flutter run
   ```

---
> **ملاحظة للمطور (Note):** إذا واجهتك مشاكل في تشغيل الإعلانات محلياً، تأكد من استخدام الأرقام التعريفية للتجارب (Test Ad Units IDs) التي توفرها جوجل للمطورين.
