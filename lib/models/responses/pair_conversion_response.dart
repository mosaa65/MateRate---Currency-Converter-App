/// نموذج (Model) لنتيجة تحويل زوج عملات من exchangerate-api.
/// يفصل JSON عن UI ويعطي Types واضحة بدل dynamic.
///
/// لماذا هذا مهم؟
/// - يقلل الأخطاء في الواجهة
/// - يجعل تغيير API لاحقاً أسهل (تعدل هنا فقط)
class PairConversionResponse {
  /// "success" أو "error"
  final String result;

  /// نوع الخطأ إن وجد (مثلا: "invalid-key", "unsupported-code"... حسب API)
  final String? errorType;

  /// العملة الأساسية
  final String? baseCode;

  /// العملة المستهدفة
  final String? targetCode;

  /// سعر التحويل (base -> target)
  final double? conversionRate;

  /// نتيجة التحويل النهائية (عند وجود amount)
  final double? conversionResult;

  const PairConversionResponse({
    required this.result,
    this.errorType,
    this.baseCode,
    this.targetCode,
    this.conversionRate,
    this.conversionResult,
  });

  /// Factory لتحويل JSON إلى كائن Dart Typed.
  /// نعالج التحويلات بعناية لأن بعض الحقول قد تأتي int أو double.
  factory PairConversionResponse.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return PairConversionResponse(
      result: (json['result'] ?? 'error').toString(),
      errorType: json['error-type']?.toString(),
      baseCode: json['base_code']?.toString(),
      targetCode: json['target_code']?.toString(),
      conversionRate: _toDouble(json['conversion_rate']),
      conversionResult: _toDouble(json['conversion_result']),
    );
  }

  bool get isSuccess => result.toLowerCase() == 'success';

  @override
  String toString() {
    return 'PairConversionResponse(result: $result, base: $baseCode, target: $targetCode, rate: $conversionRate, resultAmount: $conversionResult, error: $errorType)';
  }
}
