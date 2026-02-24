import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:re/core/constants/app_colors.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('عن المبرمج', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/developer.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              'موسئ جميل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flutter Architect & UX Enthusiast',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
                fontFamily: 'PoetsenOne',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'أنا مطوّر متمكن بخبرة تمتد لأكثر من 5 سنوات في بناء تطبيقات Flutter احترافية. أؤمن بقوة تجربة المستخدم وأعمل على تصميم واجهات تجمع بين الجمال والأداء العالي. ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSkillItem('🎯 القيادة التقنية'),
            _buildSkillItem('⚡ الأداء العالي'),
            _buildSkillItem('🎨 تصميم واجهات جذابة'),
            _buildSkillItem('🔧 حل المشاكل بسرعة'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.link),
              label: const Text('زيارة حسابي على GitHub'),
              onPressed: () => _launchUrl('https://github.com/yourusername'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}