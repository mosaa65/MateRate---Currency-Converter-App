import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:re/core/secrets/secrets.dart';
import 'package:re/models/responses/exchange_rate_response.dart';
import 'package:re/models/responses/pair_conversion_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://v6.exchangerate-api.com/v6/';
  final String apiKey = Secrets.exchangeRateApiKey;

  Uri _buildUrl(String path) => Uri.parse('$baseUrl$apiKey/$path');

  String _cacheKey(String base) => 'cached_rates_${base.toUpperCase()}';

  /// حساب نسبة التغير:
  /// %Δ = ((new-old)/old) * 100
  Map<String, double> _computePercentChanges({
    required Map<String, dynamic> newRates,
    required Map<String, dynamic> oldRates,
  }) {
    final out = <String, double>{};

    for (final e in newRates.entries) {
      final newV = e.value;
      final oldV = oldRates[e.key];

      if (newV is! num || oldV is! num) continue;
      if (oldV == 0) continue;

      final pct = ((newV.toDouble() - oldV.toDouble()) / oldV.toDouble()) * 100.0;
      out[e.key] = pct;
    }

    return out;
  }

  Future<ExchangeRateResponse?> getExchangeRates(String baseCurrency) async {
    final base = baseCurrency.toUpperCase().trim();
    final url = _buildUrl('latest/$base');

    try {
      final prefs = await SharedPreferences.getInstance();

      // اقرأ الكاش السابق (إذا موجود) لحساب changes
      final cachedBody = prefs.getString(_cacheKey(base));
      Map<String, dynamic> oldRates = {};

      if (cachedBody != null) {
        final cachedJson = jsonDecode(cachedBody) as Map<String, dynamic>;
        oldRates =
            (cachedJson['conversion_rates'] as Map?)?.cast<String, dynamic>() ?? {};
      }

      // اطلب من الشبكة
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return await _loadCachedRates(base);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // تأكد أن الاستجابة ناجحة
      if ((data['result'] ?? '').toString().toLowerCase() != 'success') {
        return await _loadCachedRates(base);
      }

      final newRates =
          (data['conversion_rates'] as Map?)?.cast<String, dynamic>() ?? {};

      final changes = (cachedBody == null)
          ? <String, double>{}
          : _computePercentChanges(newRates: newRates, oldRates: oldRates);

      // احقن changes داخل data
      data['changes'] = changes;

      // خزّن JSON المعدّل في الكاش
      await prefs.setString(_cacheKey(base), jsonEncode(data));

      return ExchangeRateResponse(data: data, fromCache: false);
    } catch (_) {
      return await _loadCachedRates(baseCurrency);
    }
  }

  Future<ExchangeRateResponse?> _loadCachedRates(String baseCurrency) async {
    final base = baseCurrency.toUpperCase().trim();
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey(base));

    if (cachedData != null) {
      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      return ExchangeRateResponse(data: data, fromCache: true);
    }

    return null;
  }

  Future<PairConversionResponse> convertPair({
    required String base,
    required String target,
  }) async {
    final b = base.toUpperCase().trim();
    final t = target.toUpperCase().trim();

    final url = _buildUrl('pair/$b/$t');
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PairConversionResponse.fromJson(data);
  }

  Future<PairConversionResponse> convertPairWithAmount({
    required String base,
    required String target,
    required double amount,
  }) async {
    final b = base.toUpperCase().trim();
    final t = target.toUpperCase().trim();

    final url = _buildUrl('pair/$b/$t/$amount');
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PairConversionResponse.fromJson(data);
  }

  Future<List<List<String>>> getSupportedCurrencies() async {
    final url = _buildUrl('codes');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success' && data['supported_codes'] != null) {
          return (data['supported_codes'] as List)
              .map<List<String>>((item) => List<String>.from(item))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
