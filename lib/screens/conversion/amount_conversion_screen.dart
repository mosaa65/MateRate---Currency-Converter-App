import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:re/widgets/universal_currency_picker.dart';
import 'package:re/core/constants/app_colors.dart';
import 'package:re/services/api/api_service.dart';
import 'package:re/models/responses/pair_conversion_response.dart';
import 'package:re/services/ads/ad_manager.dart';

class AmountConversionScreen extends StatefulWidget {
  const AmountConversionScreen({Key? key}) : super(key: key);

  @override
  State<AmountConversionScreen> createState() => _AmountConversionPageState();
}

class _AmountConversionPageState extends State<AmountConversionScreen> {
  final ApiService _api = ApiService();

  final TextEditingController _amountController = TextEditingController();

  /// Timer للـ debounce حتى لا نعمل request مع كل حرف
  Timer? _debounce;

  String _base = 'USD';
  String _target = 'EUR';

  double? _amount; // القيمة المدخلة بعد validation
  PairConversionResponse? _response;

  bool _loading = false;

  late final Future<List<List<String>>> _currenciesFuture;

  /// عداد للتحكم في interstitial ads
  int _conversionCounter = 0;

  @override
  void initState() {
    super.initState();

    _currenciesFuture = _api.getSupportedCurrencies();

    _loadSavedCurrencies();

    /// Listener تلقائي على TextField
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _base = prefs.getString('last_base') ?? _base;
      _target = prefs.getString('last_target') ?? _target;
    });
  }

  Future<void> _saveCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_base', _base);
    await prefs.setString('last_target', _target);
  }

  /// يتم استدعاؤها عند كل تغيير في TextField
  /// لكنها لا تطلب API مباشرة
  void _onAmountChanged() {
    // ألغِ المؤقت السابق
    _debounce?.cancel();

    // انتظر 400ms بعد آخر إدخال
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final parsed = _parseAmount(_amountController.text);

      if (parsed == null) {
        // مدخل غير صالح -> نمسح النتيجة
        if (!mounted) return;
        setState(() {
          _amount = null;
          _response = null;
        });
        return;
      }

      _amount = parsed;
      _convert();
    });
  }

  /// Parsing + validation للمبلغ
  ///
  /// لماذا هذا مهم؟
  /// - المستخدم قد يكتب فاصلة , بدل .
  /// - قد يكتب مسافات
  /// - قد يكتب قيمة سالبة
  double? _parseAmount(String raw) {
    final cleaned = raw.trim().replaceAll(',', '.');
    final value = double.tryParse(cleaned);

    if (value == null || value <= 0) return null;
    return value;
  }

  bool _validateSelection() {
    if (_base == _target) {
      _showSnack('اختر عملتين مختلفتين');
      return false;
    }
    if (_amount == null) return false;
    return true;
  }

  Future<void> _convert() async {
    if (!_validateSelection()) return;

    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    try {
      final res = await _api.convertPairWithAmount(
        base: _base,
        target: _target,
        amount: _amount!,
      );

      if (!mounted) return;
      setState(() {
        _response = res;
        _loading = false;
        _conversionCounter++;
      });

      await _saveCurrencies();

      // إعلان: بعد عدد معين من التحويلات فقط
      if (_conversionCounter % 3 == 0) {
        AdManager().maybeShowInterstitial();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('فشل التحويل. تحقق من الاتصال وحاول مرة أخرى');
    }
  }

  void _swapCurrencies() {
    if (!mounted) return;

    setState(() {
      final tmp = _base;
      _base = _target;
      _target = tmp;
    });

    // بعد swap نعيد التحويل تلقائيا إذا عندنا مبلغ
    if (_amount != null) {
      _convert();
    }
  }

  void _openCurrencyPicker({required bool isBase}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FutureBuilder<List<List<String>>>(
          future: _currenciesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return UniversalCurrencyPicker(
              currencies: snapshot.data!,
              isBase: isBase,
              currentBase: _base,
              currentTarget: _target,
              primaryColor: AppColors.primary,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              subtitleStyle: const TextStyle(fontSize: 13),
              onSelected: (code) {
                if (!mounted) return;
                setState(() {
                  if (isBase) {
                    _base = code;
                  } else {
                    _target = code;
                  }
                });

                // إعادة التحويل تلقائيا
                if (_amount != null) {
                  _convert();
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تحويل مبلغ'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // إدخال المبلغ
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'المبلغ',
                hintText: 'أدخل المبلغ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 16),

            // اختيار العملات
            Row(
              children: [
                Expanded(
                  child: _CurrencyCard(
                    title: 'من',
                    code: _base,
                    onTap: () => _openCurrencyPicker(isBase: true),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz, size: 32),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrencyCard(
                    title: 'إلى',
                    code: _target,
                    onTap: () => _openCurrencyPicker(isBase: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // النتيجة
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (_response != null && _response!.conversionResult != null)
              _ResultCard(
                base: _base,
                target: _target,
                amount: _amount!,
                result: _response!.conversionResult!,
                rate: _response!.conversionRate,
              )
            else
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('أدخل المبلغ لاستخدام التحويل التلقائي'),
              ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textDirection: TextDirection.rtl)),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String title;
  final String code;
  final VoidCallback onTap;

  const _CurrencyCard({
    required this.title,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const Spacer(),
            Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String base;
  final String target;
  final double amount;
  final double result;
  final double? rate;

  const _ResultCard({
    required this.base,
    required this.target,
    required this.amount,
    required this.result,
    this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$amount $base =',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            result.toStringAsFixed(4) + ' ' + target,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (rate != null) ...[
            const SizedBox(height: 12),
            Text(
              'سعر الصرف: 1 $base = ${rate!.toStringAsFixed(6)} $target',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
