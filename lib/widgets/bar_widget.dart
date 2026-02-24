import 'package:flutter/material.dart';

/// Bar Widget بسيط لعرض عمود (مثل رسم بياني أسبوعي).
///
/// لماذا Stateless؟
/// لأنه لا يحمل حالة داخلية؛ كل شيء يأتي من الـ props.
///
/// ملاحظة حول height:
/// - الأفضل أن يكون كنسبة (0.0 إلى 1.0) بدل "بيكسل" لكي يتجاوب مع أحجام الشاشات.
/// - لذلك سمّيته [value] كنسبة. إذا تبي بيكسلات، قل لي وأعدّلها.
class Bar extends StatelessWidget {
  /// تسمية العمود (مثلا: Sat, Sun أو "السبت")
  final String label;

  /// قيمة العمود كنسبة بين 0 و 1
  final double value;

  /// لون العمود
  final Color color;

  /// ارتفاع المنطقة المخصصة للرسم (الحد الأعلى للعمود)
  final double maxBarHeight;

  /// هل نعرض القيمة نصيا فوق العمود
  final bool showValueText;

  /// تنسيق نص القيمة
  final TextStyle? valueTextStyle;

  const Bar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.maxBarHeight = 90,
    this.showValueText = false,
    this.valueTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // حماية من قيم خارج النطاق (تفادي UI غريب أو overflow)
    final clamped = value.clamp(0.0, 1.0);
    final barHeight = maxBarHeight * clamped;

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showValueText)
          Text(
            // عرض كنسبة مئوية مثلا
            '${(clamped * 100).toStringAsFixed(0)}%',
            style: valueTextStyle ??
                theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 6),

        // حاوية البار: الخلفية ثابتة والعمود يتحرك داخلها
        Container(
          height: maxBarHeight,
          width: 16,
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: barHeight,
            width: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
