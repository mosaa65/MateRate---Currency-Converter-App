import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:re/services/ads/ad_manager.dart';

class AdSettingsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const AdSettingsScreen({required this.prefs});

  @override
  _AdSettingsPageState createState() => _AdSettingsPageState();
}

class _AdSettingsPageState extends State<AdSettingsScreen> {
  bool _adsEnabled = true;
  bool _bannerEnabled = true;
  bool _interstitialEnabled = true;
  bool _rewardedEnabled = true;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _adsEnabled = widget.prefs.getBool('adsEnabled') ?? true;
      _bannerEnabled = widget.prefs.getBool('bannerAdsEnabled') ?? true;
      _interstitialEnabled = widget.prefs.getBool('interstitialAdsEnabled') ?? true;
      _rewardedEnabled = widget.prefs.getBool('rewardedAdsEnabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    // نحفظ نفس الـ messenger علشان نضمن نفس الـ context
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text('جاري تحديث الإعدادات...'),
          ],
        ),
        duration: Duration(days: 1), // مدة طويلة فعلياً
      ),
    );

    try {
      // ننتظر كل setBool على حدة
      await widget.prefs.setBool(key, value);

      if (key == 'adsEnabled' && !value) {
        await widget.prefs.setBool('bannerAdsEnabled', false);
        await widget.prefs.setBool('interstitialAdsEnabled', false);
        await widget.prefs.setBool('rewardedAdsEnabled', false);
      }

      // نضمن إخفاء الـ SnackBar حتى لو حصل خطأ في reloadSettings
      await AdManager().reloadSettings();

      // نجاح الحفظ
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('تم الحفظ بنجاح'),
              ],
            ),
          ),
        );
    } catch (e) {
      // إذا صار خطأ
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإعلانات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('تفعيل الإعلانات'),
            value: _adsEnabled,
            onChanged: (v) {
              setState(() {
                _adsEnabled = v;
                if (!v) {
                  _bannerEnabled = false;
                  _interstitialEnabled = false;
                  _rewardedEnabled = false;
                }
              });
              _saveSetting('adsEnabled', v);
            },
          ),
          const Divider(height: 40, thickness: 1),
          SwitchListTile(
            title: const Text('إعلانات البانر'),
            value: _bannerEnabled,
            onChanged: _adsEnabled
                ? (v) {
              setState(() => _bannerEnabled = v);
              _saveSetting('bannerAdsEnabled', v);
            }
                : null,
          ),
          SwitchListTile(
            title: const Text('الإعلانات البينية'),
            value: _interstitialEnabled,
            onChanged: _adsEnabled
                ? (v) {
              setState(() => _interstitialEnabled = v);
              _saveSetting('interstitialAdsEnabled', v);
            }
                : null,
          ),
          SwitchListTile(
            title: const Text('إعلانات المكافأة'),
            value: _rewardedEnabled,
            onChanged: _adsEnabled
                ? (v) {
              setState(() => _rewardedEnabled = v);
              _saveSetting('rewardedAdsEnabled', v);
            }
                : null,
          ),
          const Divider(height: 40, thickness: 1),
          ListTile(
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final uri = Uri.parse(AdManager.privacyPolicyUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تعذر فتح الرابط')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
