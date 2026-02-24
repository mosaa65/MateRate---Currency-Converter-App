import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/settings/ad_settings_screen.dart';


/// مدير الإعلانات Singleton:
/// - يهيئ Google Mobile Ads مرة واحدة
/// - يحمل Banner / Interstitial / Rewarded
/// - يحترم تفضيلات المستخدم (تعطيل الإعلانات، معدل الظهور ...)
///
/// لماذا Singleton؟
/// لأن الإعلانات موارد ثقيلة، ولا تريد تهيئة SDK أكثر من مرة.
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  /// وضع الاختبار: استخدم IDs التجريبية الرسمية.
  /// مهم أثناء التطوير لتجنب حظر الحساب.
  static const bool testMode = true;

  /// رابط سياسة الخصوصية (عدّلها لرابطك الحقيقي)
  static const String privacyPolicyUrl = 'https://example.com/privacy';

  /// مفاتيح تفضيلات المستخدم في SharedPreferences
  static const String _kAdsEnabled = 'ads_enabled';
  static const String _kInterstitialEvery = 'interstitial_every'; // يظهر كل كم مرة
  static const String _kRewardedEnabled = 'rewarded_enabled';

  /// حالة الإعلانات في التطبيق
  bool _initialized = false;
  bool _adsEnabled = true;
  bool _rewardedEnabled = true;

  /// كل كم حدث نعرض interstitial (مثلا كل 3 مرات)
  int _interstitialEvery = 3;

  /// عداد لاستخدامه كـ frequency cap بسيط
  int _interstitialCounter = 0;

  BannerAd? _topBanner;
  BannerAd? _bottomBanner;

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;

  RewardedAd? _rewarded;
  bool _rewardedLoading = false;

  bool get adsEnabled => _adsEnabled;
  bool get rewardedEnabled => _rewardedEnabled;

  /// IDs حسب المنصة والوضع
  static bool get _isAndroid => Platform.isAndroid;
  static bool get _isIOS => Platform.isIOS;

  // Banner (اختبر/عدّل IDs الإنتاج)
  static String get topBannerId => testMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : _isAndroid
      ? 'ca-app-pub-1544047732487982/7486225851'
      : 'ca-app-pub-1544047732487982/3546980841';

  static String get bottomBannerId => testMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : _isAndroid
      ? 'ca-app-pub-YOUR-ANDROID-ID/BOTTOM-BANNER'
      : 'ca-app-pub-YOUR-IOS-ID/BOTTOM-BANNER';

  static String get interstitialId => testMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : _isAndroid
      ? 'ca-app-pub-YOUR-ANDROID-ID/INTERSTITIAL'
      : 'ca-app-pub-YOUR-IOS-ID/INTERSTITIAL';

  static String get rewardedId => testMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : _isAndroid
      ? 'ca-app-pub-YOUR-ANDROID-ID/REWARDED'
      : 'ca-app-pub-YOUR-IOS-ID/REWARDED';

  /// تهيئة الإعلانات.
  /// ملاحظة: حتى لو فشل الإنترنت، لا نكسر التطبيق.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await MobileAds.instance.initialize();
      final prefs = await SharedPreferences.getInstance();
      await _loadUserPreferences(prefs);

      _initialized = true;

      if (_adsEnabled) {
        _loadBanners();
        _loadInterstitial();
        if (_rewardedEnabled) _loadRewarded();
      }
    } catch (e) {
      // لا تجعل فشل الإعلانات يمنع تشغيل التطبيق
      debugPrint('Ads init failed: $e');
    }
  }

  /// إعادة تحميل التفضيلات (لو تغيّرت من صفحة الإعدادات)
  Future<void> reloadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _loadUserPreferences(prefs);

    // إذا المستخدم عطّل الإعلانات: تخلص من الإعلانات الحالية
    if (!_adsEnabled) {
      _disposeAds();
      return;
    }

    // إذا فعّلها: تأكد أن الإعلانات جاهزة
    _loadBanners();
    _loadInterstitial();
    if (_rewardedEnabled) _loadRewarded();
  }

  Future<void> _loadUserPreferences(SharedPreferences prefs) async {
    _adsEnabled = prefs.getBool(_kAdsEnabled) ?? true;
    _rewardedEnabled = prefs.getBool(_kRewardedEnabled) ?? true;
    _interstitialEvery = prefs.getInt(_kInterstitialEvery) ?? 3;

    // حماية من قيم غير منطقية
    if (_interstitialEvery < 1) _interstitialEvery = 1;
  }

  void _loadBanners() {
    // Top Banner
    _topBanner?.dispose();
    _topBanner = BannerAd(
      adUnitId: topBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();

    // Bottom Banner
    _bottomBanner?.dispose();
    _bottomBanner = BannerAd(
      adUnitId: bottomBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    if (_interstitialLoading) return;
    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitial = ad;

          // مهم: التخلص بعد الإغلاق وإعادة التحميل
          _interstitial?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _interstitial = null;
        },
      ),
    );
  }

  void _loadRewarded() {
    if (_rewardedLoading) return;
    _rewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          _rewarded = ad;

          _rewarded?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewarded = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewarded = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          _rewarded = null;
        },
      ),
    );
  }

  /// ويدجت Banner جاهز للاستخدام في UI.
  /// في الصفحات: AdWidget(ad: AdManager().topBanner!)
  BannerAd? get topBanner => (_adsEnabled ? _topBanner : null);
  BannerAd? get bottomBanner => (_adsEnabled ? _bottomBanner : null);

  /// مناداة هذه عند “حدث” معين (مثلا عند انتقال صفحة أو ضغط زر تحويل)
  /// لتطبيق frequency cap بسيط.
  Future<void> maybeShowInterstitial() async {
    if (!_adsEnabled) return;

    _interstitialCounter++;

    // إذا لم نصل للعدد المطلوب لا نعرض
    if (_interstitialCounter % _interstitialEvery != 0) return;

    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }

    ad.show();
  }

  /// عرض Rewarded Ad.
  /// تستخدمه لو عندك ميزة “فتح خاصية إضافية” أو “إزالة إعلان مؤقتا” أو “تحويلات أكثر”.
  Future<void> showRewarded({
    required VoidCallback onUserEarnedReward,
  }) async {
    if (!_adsEnabled || !_rewardedEnabled) return;

    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return;
    }

    ad.show(onUserEarnedReward: (_, __) {
      onUserEarnedReward();
    });
  }

  void _disposeAds() {
    _topBanner?.dispose();
    _topBanner = null;

    _bottomBanner?.dispose();
    _bottomBanner = null;

    _interstitial?.dispose();
    _interstitial = null;

    _rewarded?.dispose();
    _rewarded = null;
  }

  /// فتح صفحة إعدادات الإعلانات.
  /// أنت عندك AdSettingsPage(prefs: prefs) وهذا جيد.
  static Future<void> openAdSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdSettingsScreen(prefs: prefs),
      ),
    );
  }

  static Future<void> launchPrivacyPolicy() async {
    final url = Uri.parse(privacyPolicyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

}
