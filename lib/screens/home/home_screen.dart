import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:re/widgets/universal_currency_picker.dart';
import 'package:re/screens/settings/about_app_screen.dart';
import 'package:re/screens/conversion/amount_conversion_screen.dart';
import 'package:re/screens/contact/contact_screen.dart';
import 'package:re/screens/settings/developer_info_screen.dart';
import 'package:re/screens/conversion/pair_conversion_screen.dart';
import 'package:re/screens/conversion/rate_details_screen.dart';
import 'package:re/core/constants/app_colors.dart';
import 'package:re/services/api/api_service.dart';
import 'package:re/models/responses/exchange_rate_response.dart';
import 'package:re/services/ads/ad_manager.dart';

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({Key? key}) : super(key: key);

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  final ApiService _api = ApiService();

  int _navIndex = 0;

  late Future<List<List<String>>> _currenciesFuture;

  // مهم: نهيئه مباشرة حتى ما يصير LateInitializationError
  late Future<ExchangeRateResponse?> _ratesFuture;

  String baseCurrency = 'USD';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    _currenciesFuture = _api.getSupportedCurrencies();

    // تهيئة أولية
    _ratesFuture = _api.getExchangeRates(baseCurrency);

    // بعدها اقرأ base المحفوظ وأعد تحميل
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadSavedBaseCurrency();
    _reloadRates();
  }

  Future<void> _loadSavedBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      baseCurrency = prefs.getString('last_base_currency') ?? baseCurrency;
    });
  }

  Future<void> _saveBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_base_currency', baseCurrency);
  }

  void _reloadRates() {
    setState(() {
      _ratesFuture = _api.getExchangeRates(baseCurrency);
    });
  }

  Future<void> _onBaseCurrencyChanged(String newCode) async {
    if (newCode == baseCurrency) return;

    setState(() => baseCurrency = newCode);

    _reloadRates();
    await _saveBaseCurrency();
  }

  Future<void> _handleRefresh() async {
    _reloadRates();
    try {
      await _ratesFuture;
    } catch (_) {}
  }

  String _flagEmoji(String currencyCode) {
    if (currencyCode.length < 2) return '🏳️';
    final countryCode = currencyCode.substring(0, 2).toUpperCase();
    final isValid = RegExp(r'^[A-Z]{2}$').hasMatch(countryCode);
    if (!isValid) return '🏳️';

    return countryCode.codeUnits
        .map((unit) => String.fromCharCode(unit + 0x1F1E6 - 65))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MateRate Is Friend',
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: 'PoetsenOne',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildSearchAndPicker(),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _buildCurrencyList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildElegantNavBar(),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'مرحبا بك!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر من القائمة',
                    style: TextStyle(color: Colors.white70),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول التطبيق', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('تواصل معنا', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('معلومات المطور', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeveloperInfoScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('إعدادات الإعلانات', textDirection: TextDirection.rtl),
              onTap: () async {
                Navigator.pop(context);
                await AdManager.openAdSettings(context);
                await AdManager().reloadSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('سياسة الخصوصية', textDirection: TextDirection.rtl),
              onTap: () async {
                Navigator.pop(context);
                await AdManager.launchPrivacyPolicy();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v.trim()),
              style: const TextStyle(color: AppColors.secondary, fontSize: 16),
              cursorColor: AppColors.secondary,
              decoration: InputDecoration(
                hintText: 'ابحث عن عملة (مثال: USD)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _showBaseCurrencyPicker,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: Text(
              baseCurrency,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showBaseCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FutureBuilder<List<List<String>>>(
          future: _currenciesFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return UniversalCurrencyPicker(
              currencies: snap.data!,
              isBase: true,
              currentBase: baseCurrency,
              currentTarget: '',
              primaryColor: AppColors.primary,
              titleStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              subtitleStyle: const TextStyle(fontSize: 13),
              onSelected: _onBaseCurrencyChanged,
            );
          },
        );
      },
    );
  }

  Widget _buildCurrencyList() {
    return FutureBuilder<ExchangeRateResponse?>(
      future: _ratesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data == null) {
          return const Center(child: Text('حدث خطأ في تحميل البيانات'));
        }

        final resp = snap.data!;
        final fromCache = resp.fromCache;

        final Map<String, dynamic> rates =
            (resp.data['conversion_rates'] as Map?)?.cast<String, dynamic>() ?? {};

        final Map<String, dynamic> changes =
            (resp.data['changes'] as Map?)?.cast<String, dynamic>() ?? {};

        final query = searchQuery.trim().toUpperCase();

        final entries = rates.entries
            .where((e) => query.isEmpty || e.key.toUpperCase().contains(query))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return Column(
          children: [
            if (fromCache)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.offline_bolt, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'البيانات من التخزين المؤقت (Cache)',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, idx) {
                  final code = entries[idx].key;

                  final rateRaw = entries[idx].value;
                  final rate = (rateRaw is num)
                      ? rateRaw.toDouble()
                      : double.tryParse(rateRaw.toString()) ?? 0.0;

                  final amountForHundred = (rate * 100).toStringAsFixed(2);

                  final changeRaw = changes[code];
                  final change = (changeRaw is num)
                      ? changeRaw.toDouble()
                      : double.tryParse(changeRaw?.toString() ?? '');

                  final hasChange = change != null;

                  IconData icon;
                  Color iconColor;
                  String changeText;

                  if (!hasChange) {
                    icon = Icons.remove;
                    iconColor = Colors.grey;
                    changeText = '--';
                  } else if (change == 0) {
                    icon = Icons.remove;
                    iconColor = Colors.grey;
                    changeText = '0.00%';
                  } else if (change! > 0) {
                    icon = Icons.arrow_drop_up;
                    iconColor = Colors.green;
                    changeText = '${change.toStringAsFixed(2)}%';
                  } else {
                    icon = Icons.arrow_drop_down;
                    iconColor = Colors.red;
                    changeText = '${change.toStringAsFixed(2)}%';
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RateDetailsScreen(
                            currencyName: code,
                            currentValue: rate.toStringAsFixed(6),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(_flagEmoji(code),
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 6),
                          Text(
                            code,
                            style: const TextStyle(
                              fontFamily: 'DMSerifText-Regular',
                              color: AppColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                rate.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontFamily: 'DMSerifText-Regular',
                                  color: AppColors.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '1 $baseCurrency/$code',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontFamily: 'DMSerifText-Regular',
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(icon, color: iconColor),
                                  Text(
                                    changeText,
                                    style: TextStyle(
                                      color: iconColor,
                                      fontFamily: 'DMSerifText-Regular',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '100 $baseCurrency/$code = $amountForHundred',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontFamily: 'DMSerifText-Regular',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElegantNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF28878B).withOpacity(0.9),
                const Color(0xFF166F8A).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _navIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedIconTheme:
            const IconThemeData(size: 30, color: Colors.white),
            unselectedIconTheme:
            const IconThemeData(size: 24, color: Colors.white70),
            onTap: (index) {
              setState(() => _navIndex = index);

              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AmountConversionScreen(),
                    ),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PairConversionScreen(),
                    ),
                  );
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(
                icon: Icon(Icons.compare_arrows),
                label: 'محول',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: 'الزوج',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
