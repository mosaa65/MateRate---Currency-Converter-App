class ExchangeRateResponse {
  /// جسم الاستجابة كامل (JSON) سواء من الشبكة أو الكاش
  final Map<String, dynamic> data;

  /// هل البيانات جاءت من SharedPreferences؟
  final bool fromCache;

  const ExchangeRateResponse({
    required this.data,
    required this.fromCache,
  });
}
