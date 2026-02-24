import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:re/core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('تواصل معنا', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildContactCard(
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني',
              value: 'mousa.mc13@gmail.com',
              onTap: () => _launchMail('mousa.mc13@gmail.com'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.alternate_email,
              label: 'تويتر',
              value: '@yourhandle',
              onTap: () => _launchUrl('https://twitter.com/yourhandle'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.camera_alt_outlined,
              label: 'إنستغرام',
              value: '@2uq.y',
              onTap: () => _launchUrl('https://www.instagram.com/2uq.y?igsh=MTAzeXp4NDIweW40bA%3D%3D&utm_source=qr'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone_outlined,
              label: 'واتساب',
              value: '+97772217218',
              onTap: () => _launchUrl('https://wa.me/+97772217218'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: AppColors.primary, size: 28),
        title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}