import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }
}

class CurrencyUtils {
  static String formatCurrency(double amount, {String? currencyCode}) {
    final formatter = NumberFormat.currency(
      symbol: currencyCode ?? '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCurrencyCompact(double amount, {String? currencyCode}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${currencyCode ?? '₹'}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ${currencyCode ?? '₹'}';
    } else {
      return formatCurrency(amount, currencyCode: currencyCode);
    }
  }

  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'SEK':
        return 'kr';
      case 'NZD':
        return 'NZ\$';
      case 'MXN':
        return '\$';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NOK':
        return 'kr';
      case 'KRW':
        return '₩';
      case 'TRY':
        return '₺';
      case 'RUB':
        return '₽';
      case 'BRL':
        return 'R\$';
      case 'ZAR':
        return 'R';
      case 'SAR':
        return '﷼';
      case 'AED':
        return 'د.إ';
      case 'EGP':
        return 'E£';
      case 'THB':
        return '฿';
      case 'IDR':
        return 'Rp';
      case 'PHP':
        return '₱';
      case 'MYR':
        return 'RM';
      case 'PKR':
        return '₨';
      case 'BDT':
        return '৳';
      case 'VND':
        return '₫';
      case 'UAH':
        return '₴';
      case 'ILS':
        return '₪';
      case 'CLP':
        return '\$';
      case 'COP':
        return '\$';
      case 'PEN':
        return 'S/';
      case 'ARS':
        return '\$';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'RON':
        return 'lei';
      case 'BGN':
        return 'лв';
      case 'HRK':
        return 'kn';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      default:
        return '₹';
    }
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(phone);
  }

  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (!isNotEmpty(value)) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (!isNotEmpty(value)) {
      return 'Amount is required';
    }
    if (!isValidAmount(value!)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (!isNotEmpty(value)) {
      return 'Date is required';
    }
    if (!isValidDate(value!)) {
      return 'Please enter a valid date';
    }
    return null;
  }
}

class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
