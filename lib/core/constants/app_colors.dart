import 'package:flutter/material.dart';

/// مركزية الألوان: تمنع التكرار وتوحد الهوية البصرية.
/// الميزة: أي تغيير بالهوية يتم من ملف واحد.
/// العيب: إذا ما استُخدم ColorScheme بالكامل قد تصير تناقضات بسيطة في الثيم.
class AppColors {
  static const Color primary = Color(0xFF28878B);    // أخضر-أزرق داكن
  static const Color secondary = Color(0xFF124C5D);  // أزرق غامق
  static const Color accent = Color(0xFF166F8A);     // أزرق فاتح
  static const Color text = Color(0xFFF0EEE2);       // بيج فاتح
  static const Color background = Color(0xFFF5F5F5); // خلفية فاتحة
}
