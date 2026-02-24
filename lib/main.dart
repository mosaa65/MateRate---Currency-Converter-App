import 'package:flutter/material.dart';
import 'package:re/screens/conversion/amount_conversion_screen.dart';
import 'package:re/screens/conversion/pair_conversion_screen.dart';
import 'package:re/screens/home/home_screen.dart';

// Screens (UI pages)

// Services / Utilities

import 'package:re/services/ads/ad_manager.dart';

import 'core/constants/app_colors.dart';

/// نقطة الدخول للتطبيق.
///
/// لماذا async؟
/// لأننا نحتاج تهيئة خدمات قبل تشغيل الواجهة:
/// - تهيئة الإعلانات (Ad SDK)
/// - أي خدمات مستقبلية: Firebase, SharedPreferences, Remote Config... إلخ
Future<void> main() async {
  /// ضروري قبل أي عمليات async أو استدعاء Plugins (مثل الإعلانات).
  /// بدون هذا قد تحصل مشاكل مثل:
  /// "Binding has not yet been initialized"
  WidgetsFlutterBinding.ensureInitialized();

  /// تهيئة الإعلانات قبل تشغيل التطبيق.
  /// الأفضل أن تكون في try/catch حتى لا يمنع فشل الإعلانات تشغيل التطبيق.
  try {
    await AdManager().initialize();
  } catch (e) {
    // في الإنتاج يمكنك تسجيل الخطأ عبر Crashlytics/Sentry بدل print
    debugPrint('AdManager initialization failed: $e');
  }

  /// تشغيل التطبيق.
  runApp(const MyApp());
}

/// الجذر الرئيسي للتطبيق (Root Widget).
///
/// جعلناه Stateless لأن:
/// - لا يوجد state داخلي هنا
/// - إعداد MaterialApp ثابت غالباً
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// اسم يظهر في مهام النظام وبعض الأماكن.
      title: 'تطبيق أسعار العملات',

      /// لإخفاء شريط DEBUG.
      debugShowCheckedModeBanner: false,

      /// الثيم العام للتطبيق.
      ///
      /// ملاحظات مهمة:
      /// - أنت تستخدم ColorScheme + primaryColor + primarySwatch
      /// - في Material 3 يفضّل الاعتماد على ColorScheme أكثر
      theme: ThemeData(
        /// لون أساسي قد يستخدم في Widgets قديمة.
        primaryColor: AppColors.primary,

        /// مخطط ألوان حديث لتوحيد ألوان الواجهة.
        colorScheme: ColorScheme.light(
          primary: AppColors.secondary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),

        /// ملاحظة: primarySwatch يتعارض أحياناً مع colorScheme.
        /// الأفضل تحديد واحد كمرجع للألوان لتجنب اختلافات غير متوقعة.
        primarySwatch: Colors.teal,

        /// خط افتراضي للتطبيق.
        /// تأكد من تعريفه في pubspec.yaml بشكل صحيح
        fontFamily: 'Cairo-SemiBold',
      ),

      /// الصفحة الرئيسية عند فتح التطبيق.
      home: CurrencyHomePage(),

      /// Routes للتنقل بالأسماء:
      /// Navigator.pushNamed(context, '/pair');
      routes: {
        '/pair': (_) => PairConversionScreen(),
        '/amount': (_) => AmountConversionScreen(),
      },
    );
  }
}
