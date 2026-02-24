import 'package:flutter/material.dart';
import 'package:re/core/constants/app_colors.dart';
class RateDetailsScreen extends StatelessWidget {
  final String currencyName;
  final String currentValue;

  const RateDetailsScreen({
    Key? key,
    required this.currencyName,
    required this.currentValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with gradient from primary to secondary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 16, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                // Current rate value
                Text(
                  '$currentValue $currencyName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily: 'PoetsenOne',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle detail: rate for 100 units
                Text(
                  '100 ${_getBaseCurrency(context)} = ${_calculateHundred(context)} $currencyName',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Cairo-SemiBold',
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for chart
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.text,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Chart Placeholder',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem('Open', '668.42'),
                      _buildInfoItem('High', '672.10'),
                      _buildInfoItem('Chg', '+0.13%'),
                    ],
                  ),
                  const Spacer(),
                  // Source text
                  Center(
                    child: Text(
                      'Source: Yahoo xCurrency',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers to obtain base currency and calculate amount for 100 units
  String _getBaseCurrency(BuildContext context) {
    // Extract via ModalRoute or inherited widget as needed
    return 'USD';
  }

  String _calculateHundred(BuildContext context) {
    // Convert currentValue to double and multiply
    final rate = double.tryParse(currentValue) ?? 1.0;
    return (rate * 100).toStringAsFixed(2);
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}