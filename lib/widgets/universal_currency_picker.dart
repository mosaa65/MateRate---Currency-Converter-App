import 'package:flutter/material.dart';

/// UniversalCurrencyPicker
/// منتقي عملات عام يدعم:
/// - بحث بالرمز (USD) أو الاسم (United States Dollar)
/// - تمييز العملة الحالية
/// - منع اختيار نفس العملة في base/target (اختياري عبر enableValidation)
///
/// currencies متوقعة بالشكل:
/// [ ["USD","United States Dollar"], ["EUR","Euro"], ... ]
class UniversalCurrencyPicker extends StatefulWidget {
  final List<List<String>> currencies;

  /// هل هذا المنتقي لاختيار Base currency؟
  /// إذا false يعتبر Target picker
  final bool isBase;

  /// القيم الحالية لتطبيق validation ومنع التكرار
  final String currentBase;
  final String currentTarget;

  /// Callback عند اختيار عملة (يرجع code فقط مثل "USD")
  final ValueChanged<String> onSelected;

  /// ألوان/ستايل
  final Color primaryColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  /// منع اختيار base=target
  final bool enableValidation;

  /// نصوص واجهة
  final String searchHint;
  final String emptyMessage;

  const UniversalCurrencyPicker({
    super.key,
    required this.currencies,
    required this.isBase,
    required this.currentBase,
    required this.currentTarget,
    required this.onSelected,
    required this.primaryColor,
    required this.titleStyle,
    required this.subtitleStyle,
    this.enableValidation = true,
    this.searchHint = 'ابحث عن عملة (USD أو Dollar)...',
    this.emptyMessage = 'لا توجد نتائج مطابقة',
  });

  @override
  State<UniversalCurrencyPicker> createState() => _UniversalCurrencyPickerState();
}

class _UniversalCurrencyPickerState extends State<UniversalCurrencyPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    // تحديث query عند الكتابة
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<List<String>> get _filteredCurrencies {
    if (_query.isEmpty) return widget.currencies;

    return widget.currencies.where((currency) {
      if (currency.length < 2) return false;
      final code = currency[0].toLowerCase();
      final name = currency[1].toLowerCase();
      return code.contains(_query) || name.contains(_query);
    }).toList();
  }

  /// تحويل أول حرفين من كود العملة إلى "علم" (Regional Indicator Symbols).
  ///
  /// ملاحظة: هذه الطريقة ليست دقيقة 100% لأن:
  /// - "EUR" ليس دولة
  /// - "XAU" ذهب، "XAG" فضة...
  /// لكنها تعطي شكل جميل سريع.
  ///
  /// تحسين ممكن: خريطة ثابتة Currency->Flag أو استثناءات معروفة.
  String _flagEmoji(String currencyCode) {
    if (currencyCode.length < 2) return '🏳️';
    final countryCode = currencyCode.substring(0, 2).toUpperCase();

    // تأكد أنه A-Z فقط
    final isValid = RegExp(r'^[A-Z]{2}$').hasMatch(countryCode);
    if (!isValid) return '🏳️';

    return countryCode.codeUnits
        .map((unit) => String.fromCharCode(unit + 0x1F1E6 - 65))
        .join();
  }

  bool _isCurrentCurrency(String code) {
    return widget.isBase ? code == widget.currentBase : code == widget.currentTarget;
  }

  void _handleSelection(String code) {
    // Validation: منع اختيار نفس العملة في base/target
    if (widget.enableValidation) {
      final base = widget.currentBase;
      final target = widget.currentTarget;

      if (widget.isBase && code == target) {
        _showSnack('لا يمكن اختيار نفس عملة التحويل والعملة المستهدفة');
        return;
      }
      if (!widget.isBase && code == base) {
        _showSnack('لا يمكن اختيار نفس عملة التحويل والعملة الأساسية');
        return;
      }
    }

    widget.onSelected(code);

    // عادة نغلق الـ bottom sheet / الصفحة بعد الاختيار
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCurrencies;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header + Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isBase ? 'اختر العملة الأساسية' : 'اختر العملة المستهدفة',
                  style: widget.titleStyle,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: widget.primaryColor, width: 1.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // List
          Flexible(
            child: list.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                widget.emptyMessage,
                style: widget.subtitleStyle,
                textDirection: TextDirection.rtl,
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final currency = list[index];
                final code = currency[0];
                final name = currency.length > 1 ? currency[1] : '';

                final isCurrent = _isCurrentCurrency(code);

                return ListTile(
                  onTap: () => _handleSelection(code),
                  leading: Text(
                    _flagEmoji(code),
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    code,
                    style: widget.titleStyle.copyWith(
                      color: isCurrent ? widget.primaryColor : widget.titleStyle.color,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    name,
                    style: widget.subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isCurrent
                      ? Icon(Icons.check_circle, color: widget.primaryColor)
                      : const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
