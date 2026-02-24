import 'package:flutter/material.dart';
import 'package:re/widgets/universal_currency_picker.dart';
import 'package:re/core/constants/app_colors.dart';
import 'package:re/services/api/api_service.dart';
import 'package:re/models/responses/pair_conversion_response.dart';
import 'package:re/services/ads/ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PairConversionScreen extends StatefulWidget {
  const PairConversionScreen({Key? key}) : super(key: key);

  @override
  State<PairConversionScreen> createState() => _PairConversionPageState();
}

class _PairConversionPageState extends State<PairConversionScreen> {
  static const double cardHeight = 140;
  static const double swapButtonSize = 60;

  final ApiService _api = ApiService();

  String _base = 'USD';
  String _target = 'EUR';

  PairConversionResponse? _response;
  bool _loading = false;

  late final Future<List<List<String>>> _currenciesFuture;

  /// عداد التحويلات (لاستراتيجية عرض الإعلان)
  int _conversionCounter = 0;

  @override
  void initState() {
    super.initState();

    // نحمل قائمة العملات مرة واحدة
    _currenciesFuture = _api.getSupportedCurrencies();

    // نحمّل آخر اختيار للمستخدم ثم نسوي تحويل مباشرة
    _loadSavedCurrencies().then((_) => _convert());
  }

  Future<void> _loadSavedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();

    // لا تستعمل setState بعد await بدون mounted
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

  /// منع طلب API غير منطقي (base == target)
  bool _validateSelection() {
    if (_base == _target) {
      _showSnack('اختر عملتين مختلفتين');
      return false;
    }
    return true;
  }

  Future<void> _convert() async {
    if (!_validateSelection()) return;

    if (!mounted) return;
    setState(() {
      _loading = true;
      _response = null;
    });

    try {
      final res = await _api.convertPair(base: _base, target: _target);

      if (!mounted) return;
      setState(() {
        _response = res;
        _conversionCounter++;
        _loading = false;
      });

      await _saveCurrencies();

      // إعلان: عندك في AdManager showInterstitialAd
      // الأفضل أن يكون قرار التكرار داخل AdManager، لكن نلتزم بمنطقك الحالي
      if (_conversionCounter % 2 == 0) {
        await AdManager().maybeShowInterstitial();
      }

    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('حدث خطأ أثناء التحويل. حاول مرة أخرى');
    }
  }

  void _swapCurrencies() {
    if (!mounted) return;
    setState(() {
      final tmp = _base;
      _base = _target;
      _target = tmp;
    });

    // بعد swap نسوي convert مباشرة
    _convert();
  }

  void _showCurrencyPicker({required bool isBase}) {
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

            final list = snapshot.data!;

            return UniversalCurrencyPicker(
              currencies: list,
              isBase: isBase,
              currentBase: _base,
              currentTarget: _target,
              primaryColor: AppColors.primary,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              subtitleStyle: const TextStyle(fontSize: 13),
              onSelected: (code) {
                // picker يغلق نفسه في نسختي، لكن لو نسختك لا تغلق:
                // Navigator.pop(context);

                if (!mounted) return;
                setState(() {
                  if (isBase) {
                    _base = code;
                  } else {
                    _target = code;
                  }
                });

                _convert();
              },
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      centerTitle: true,
      elevation: 0,
      title: const Text(
        'تحويل زوج العملات',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ملاحظة: خليت هيكل الصفحة بسيط.
    // أنت عندك UI غني (Cards/Bar Widget). تقدر تلصق نفس عناصر UI فوق هذا المنطق مباشرة.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // اختيار العملات
            Row(
              children: [
                Expanded(
                  child: _CurrencyCard(
                    title: 'من',
                    code: _base,
                    onTap: () => _showCurrencyPicker(isBase: true),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: swapButtonSize,
                  height: swapButtonSize,
                  child: ElevatedButton(
                    onPressed: _swapCurrencies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrencyCard(
                    title: 'إلى',
                    code: _target,
                    onTap: () => _showCurrencyPicker(isBase: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // نتيجة التحويل
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              )
            else if (_response != null && _response!.conversionRate != null)
              _ResultCard(
                base: _base,
                target: _target,
                rate: _response!.conversionRate!,
              )
            else
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text('اختر عملتين ثم اضغط تحويل'),
              ),

            const Spacer(),

            // زر التحويل
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('تحويل', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
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
        height: 72,
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
  final double rate;

  const _ResultCard({
    required this.base,
    required this.target,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('سعر الصرف', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text(
            '1 $base = ${rate.toStringAsFixed(6)} $target',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
