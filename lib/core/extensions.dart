import 'package:flutter/material.dart';

// DateTime Extensions
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    return year == DateTime.now().year;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1));
  }

  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6));
  }

  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }

  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  DateTime get endOfYear {
    return DateTime(year, 12, 31);
  }

  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  bool get isLeapYear {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String get shortMonthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String get dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String get shortDayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// String Extensions
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get removeSpecialCharacters {
    return replaceAll(RegExp(r'[^\w\s]'), '');
  }

  String get removeExtraSpaces {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get toSnakeCase {
    return toLowerCase().replaceAll(' ', '_');
  }

  String get toCamelCase {
    if (isEmpty) return this;
    final words = split(' ');
    return words[0].toLowerCase() +
        words.skip(1).map((word) => word.capitalize).join('');
  }

  String get toPascalCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join('');
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isPhoneNumber {
    return RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(this);
  }

  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  bool get isDecimal {
    return RegExp(r'^\d*\.?\d+$').hasMatch(this);
  }

  bool get isUrl {
    return RegExp(
      r'^https?:\/\/[\w\-\.]+(:\d+)?(\/[\w\-\.\/]*)?$',
    ).hasMatch(this);
  }

  String get initials {
    if (isEmpty) return '';
    final words = split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    }
    return '${words[0][0].toUpperCase()}${words.last[0].toUpperCase()}';
  }
}

// Double Extensions
extension DoubleExtension on double {
  String get toCurrency {
    return '\$${toStringAsFixed(2)}';
  }

  String get toCompactCurrency {
    if (this >= 1000000) {
      return '\$${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '\$${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toCurrency;
    }
  }

  String get toPercentage {
    return '${(this * 100).toStringAsFixed(1)}%';
  }

  bool get isInteger {
    return this == roundToDouble();
  }

  int get toInt {
    return round();
  }

  double get toPrecision2 {
    return double.parse(toStringAsFixed(2));
  }

  double get toPrecision3 {
    return double.parse(toStringAsFixed(3));
  }
}

// Int Extensions
extension IntExtension on int {
  String get toOrdinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }

    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  String get toWords {
    if (this == 0) return 'Zero';
    if (this < 0) return 'Negative ${(-this).toWords}';

    if (this < 20) {
      const words = [
        '',
        'One',
        'Two',
        'Three',
        'Four',
        'Five',
        'Six',
        'Seven',
        'Eight',
        'Nine',
        'Ten',
        'Eleven',
        'Twelve',
        'Thirteen',
        'Fourteen',
        'Fifteen',
        'Sixteen',
        'Seventeen',
        'Eighteen',
        'Nineteen',
      ];
      return words[this];
    }

    if (this < 100) {
      const tens = [
        '',
        '',
        'Twenty',
        'Thirty',
        'Forty',
        'Fifty',
        'Sixty',
        'Seventy',
        'Eighty',
        'Ninety',
      ];
      return '${tens[this ~/ 10]}${this % 10 > 0 ? ' ${(this % 10).toWords}' : ''}';
    }

    if (this < 1000) {
      return '${(this ~/ 100).toWords} Hundred${this % 100 > 0 ? ' ${(this % 100).toWords}' : ''}';
    }

    if (this < 1000000) {
      return '${(this ~/ 1000).toWords} Thousand${this % 1000 > 0 ? ' ${(this % 1000).toWords}' : ''}';
    }

    return '${(this ~/ 1000000).toWords} Million${this % 1000000 > 0 ? ' ${(this % 1000000).toWords}' : ''}';
  }

  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}

// List Extensions
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> get reversedList => reversed.toList();

  List<T> getDistinct() {
    return toSet().toList();
  }

  List<T> whereNotNull() {
    return where((element) => element != null).cast<T>().toList();
  }

  void addIfNotExists(T element) {
    if (!contains(element)) {
      add(element);
    }
  }

  void removeIfExists(T element) {
    if (contains(element)) {
      remove(element);
    }
  }

  List<T> takeFirst(int count) {
    return take(count).toList();
  }

  List<T> takeLast(int count) {
    return skip(length - count).toList();
  }

  List<T> shuffleList() {
    final shuffled = List<T>.from(this);
    shuffled.shuffle();
    return shuffled;
  }
}

// Color Extensions
extension ColorExtension on Color {
  Color get lighter {
    return withValues(
      red: ((r + (255 - r) * 0.3) / 255.0).clamp(0.0, 1.0),
      green: ((g + (255 - g) * 0.3) / 255.0).clamp(0.0, 1.0),
      blue: ((b + (255 - b) * 0.3) / 255.0).clamp(0.0, 1.0),
    );
  }

  Color get darker {
    return withValues(
      red: (r * 0.7).clamp(0.0, 1.0),
      green: (g * 0.7).clamp(0.0, 1.0),
      blue: (b * 0.7).clamp(0.0, 1.0),
    );
  }

  bool get isLight {
    return (r * 0.299 + g * 0.587 + b * 0.114) > 186;
  }

  bool get isDark {
    return !isLight;
  }

  Color get contrastingTextColor {
    return isLight ? Colors.black : Colors.white;
  }
}
