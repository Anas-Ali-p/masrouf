class ArabicNumberToWords {
  ArabicNumberToWords._();

  static const List<String> _ones = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
    'عشرة',
    'أحد عشر',
    'اثنا عشر',
    'ثلاثة عشر',
    'أربعة عشر',
    'خمسة عشر',
    'ستة عشر',
    'سبعة عشر',
    'ثمانية عشر',
    'تسعة عشر',
  ];

  static const List<String> _tens = [
    '',
    '',
    'عشرون',
    'ثلاثون',
    'أربعون',
    'خمسون',
    'ستون',
    'سبعون',
    'ثمانون',
    'تسعون',
  ];

  static const List<String> _hundreds = [
    '',
    'مائة',
    'مائتان',
    'ثلاثمائة',
    'أربعمائة',
    'خمسمائة',
    'ستمائة',
    'سبعمائة',
    'ثمانمائة',
    'تسعمائة',
  ];

  static String convert(int n) {
    if (n == 0) return 'صفر';
    if (n < 0) return 'سالب ${convert(-n)}';

    final parts = <String>[];

    if (n >= 1000000000) {
      final v = n ~/ 1000000000;
      parts.add(
        v == 1
            ? 'مليار'
            : v == 2
            ? 'ملياران'
            : v <= 10
            ? '${_under1000(v)} مليارات'
            : '${_under1000(v)} مليار',
      );
      n %= 1000000000;
    }

    if (n >= 1000000) {
      final v = n ~/ 1000000;
      parts.add(
        v == 1
            ? 'مليون'
            : v == 2
            ? 'مليونان'
            : v <= 10
            ? '${_under1000(v)} ملايين'
            : '${_under1000(v)} مليون',
      );
      n %= 1000000;
    }

    if (n >= 1000) {
      final v = n ~/ 1000;
      parts.add(
        v == 1
            ? 'ألف'
            : v == 2
            ? 'ألفان'
            : v <= 10
            ? '${_under1000(v)} آلاف'
            : '${_under1000(v)} ألف',
      );
      n %= 1000;
    }

    if (n > 0) parts.add(_under1000(n));

    return parts.join(' و');
  }

  static String _under1000(int n) {
    if (n == 0) return '';
    if (n < 20) return _ones[n];

    if (n < 100) {
      final ones = n % 10;
      final tens = n ~/ 10;
      if (ones == 0) return _tens[tens];
      return '${_ones[ones]} و${_tens[tens]}';
    }

    final hundreds = n ~/ 100;
    final remainder = n % 100;
    if (remainder == 0) return _hundreds[hundreds];
    return '${_hundreds[hundreds]} و${_under1000(remainder)}';
  }

  // ─────────────────────────────────────────────────────────
  //  Currency-aware formatting
  // ─────────────────────────────────────────────────────────

  /// Formats [amount] as Arabic words with a currency suffix.
  ///
  /// Special grammar:
  /// - ends with **1** → drop "واحد", use the currency's singular form
  ///   `301` → "ثلاثمائة وريال"
  /// - ends with **2** → drop "اثنان", use the currency's dual form
  ///   `302` → "ثلاثمائة وريالان"
  /// - everything else → `<words> <singular>`
  static String currency(double amount, String currencyCode) {
    if (amount <= 0) return '';
    final intPart = amount.truncate();
    if (intPart == 0) return '';

    final singular = _currencyWord(currencyCode);
    final dual = _dualCurrencyWord(currencyCode);

    // Whole number is exactly 1 or 2
    if (intPart == 1) return singular;
    if (intPart == 2) return dual;

    final words = convert(intPart);
    final lastTwo = intPart % 100;

    // Number ends with 1 (but not 11): "ثلاثمائة وواحد" → "ثلاثمائة وريال"
    if (lastTwo == 1) {
      final trimmed = _stripTrailingWord(words, 'واحد');
      return trimmed.isEmpty ? singular : '$trimmed و$singular';
    }

    // Number ends with 2 (but not 12): "ثلاثمائة واثنان" → "ثلاثمائة وريالان"
    if (lastTwo == 2) {
      final trimmed = _stripTrailingWord(words, 'اثنان');
      return trimmed.isEmpty ? dual : '$trimmed و$dual';
    }

    return '$words $singular';
  }

  /// Removes the trailing " و<word>" from [text] if present.
  static String _stripTrailingWord(String text, String word) {
    final suffix = ' و$word';
    if (text.endsWith(suffix)) {
      return text.substring(0, text.length - suffix.length);
    }
    if (text == word) return '';
    return text;
  }

  // ─────────────────────────────────────────────────────────
  //  Currency word tables
  // ─────────────────────────────────────────────────────────

  static String _currencyWord(String code) {
    switch (code.toUpperCase()) {
      case 'SAR':
        return 'ريال';
      case 'USD':
        return 'دولار';
      case 'EUR':
        return 'يورو';
      case 'GBP':
        return 'جنيه إسترليني';
      case 'AED':
        return 'درهم';
      case 'KWD':
        return 'دينار';
      case 'EGP':
        return 'جنيه';
      case 'YER':
        return 'ريال';
      default:
        return code;
    }
  }

  static String _dualCurrencyWord(String code) {
    switch (code.toUpperCase()) {
      case 'SAR':
        return 'ريالان';
      case 'USD':
        return 'دولاران';
      case 'EUR':
        return 'يوروان';
      case 'GBP':
        return 'جنيهان';
      case 'AED':
        return 'درهمان';
      case 'KWD':
        return 'ديناران';
      case 'EGP':
        return 'جنيهان';
      case 'YER':
        return 'ريالان';
      default:
        return code;
    }
  }
}
