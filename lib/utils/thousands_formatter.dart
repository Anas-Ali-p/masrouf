import 'package:flutter/services.dart';

class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDecimals = 2});

  final int maxDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip existing separators to get raw input
    final raw = newValue.text.replaceAll(',', '');

    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Split integer / decimal parts
    final dotIndex = raw.indexOf('.');
    var intPart = dotIndex == -1 ? raw : raw.substring(0, dotIndex);
    var decPart = dotIndex == -1 ? '' : raw.substring(dotIndex + 1);

    // Keep only digits
    intPart = intPart.replaceAll(RegExp(r'[^\d]'), '');
    decPart = decPart.replaceAll(RegExp(r'[^\d]'), '');

    // Trim to max decimals
    if (decPart.length > maxDecimals) {
      decPart = decPart.substring(0, maxDecimals);
    }

    // Group integer digits with commas
    final formattedInt = _withCommas(intPart);
    final hasDot = dotIndex != -1;
    final result = hasDot ? '$formattedInt.$decPart' : formattedInt;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _withCommas(String digits) {
    if (digits.isEmpty) return '0';
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

/// Strip the commas and parse. Returns 0 on failure.
double parseFormattedAmount(String input) =>
    double.tryParse(input.replaceAll(',', '')) ?? 0;
