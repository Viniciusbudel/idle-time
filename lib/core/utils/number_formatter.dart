import 'dart:math';

/// Utility class for formatting large numbers with suffixes
class NumberFormatter {
  NumberFormatter._();

  static final List<String> _suffixes = [
    '',
    'K', // Thousand
    'M', // Million
    'B', // Billion
    'T', // Trillion
    'Qa', // Quadrillion
    'Qi', // Quintillion
    'Sx', // Sextillion
    'Sp', // Septillion
    'Oc', // Octillion
    'No', // Nonillion
    'Dc', // Decillion
    'Ud', // Undecillion
    'Dd', // Duodecillion
    'Td', // Tredecillion
    'Qad', // Quattuordecillion
    'Qid', // Quindecillion
    'Sxd', // Sexdecillion
    'Spd', // Septendecillion
    'Ocd', // Octodecillion
    'Nod', // Novemdecillion
    'Vg', // Vigintillion
  ];

  /// Random generator for glitch effects
  static final _random = Random();

  /// Glitch characters for paradox effect
  static const _glitchChars = ['@', '#', '\$', '%', '&', '*', '!', '?'];

  /// Format a BigInt with suffix notation (e.g., 1.2M, 45.3B)
  static String format(BigInt number, {int decimals = 1}) {
    if (number < BigInt.zero) {
      return '-${format(-number, decimals: decimals)}';
    }

    if (number < BigInt.from(1000)) {
      return number.toString();
    }

    double value = number.toDouble();
    int suffixIndex = 0;

    while (value >= 1000 && suffixIndex < _suffixes.length - 1) {
      value /= 1000;
      suffixIndex++;
    }

    // If still too large for suffixes, use scientific notation
    if (suffixIndex >= _suffixes.length - 1 && value >= 1000) {
      return formatScientific(number);
    }

    return '${value.toStringAsFixed(decimals)}${_suffixes[suffixIndex]}';
  }

  /// Format Chrono-Energy specifically (alias for format)
  static String formatCE(BigInt amount, {int decimals = 1}) {
    return format(amount, decimals: decimals);
  }

  /// Format with a prefix symbol (e.g., ⚡ 1.2M)
  static String formatWithSymbol(BigInt amount, String symbol) {
    return '$symbol ${format(amount)}';
  }

  /// Format per second rate (e.g., 45.2K/sec)
  static String formatPerSecond(BigInt perSecond) {
    return '${format(perSecond)}/sec';
  }

  /// Format double rate with decimals (e.g. 1.5/sec)
  static String formatRate(double rate) {
    if (rate < 1000) {
      // Show decimals for small numbers to visualize tech bonuses
      return '${rate.toStringAsFixed(1)}/sec';
    } else {
      return formatPerSecond(BigInt.from(rate.toInt()));
    }
  }

  /// Format double without unit, showing decimals for small numbers
  static String formatCompactDouble(double value) {
    if (value < 1000) {
      return value.toStringAsFixed(1);
    } else {
      return format(BigInt.from(value.toInt()));
    }
  }

  /// Format BigInt compactly (alias for format)
  static String formatCompact(BigInt value) {
    return format(value);
  }

  /// Scientific notation for extreme numbers
  static String formatScientific(BigInt number) {
    if (number == BigInt.zero) return '0';
    if (number < BigInt.zero) {
      return '-${formatScientific(-number)}';
    }

    final str = number.toString();
    if (str.length <= 3) return str;

    final exponent = str.length - 1;
    final mantissa = '${str[0]}.${str.substring(1, min(3, str.length))}';
    return '${mantissa}e$exponent';
  }

  /// Format with commas for readability (e.g., 1,234,567)
  static String formatWithCommas(BigInt number) {
    if (number < BigInt.zero) {
      return '-${formatWithCommas(-number)}';
    }

    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format with glitch effect for high paradox levels
  /// [paradoxLevel] should be between 0.0 and 1.0
  static String formatWithGlitch(BigInt amount, double paradoxLevel) {
    final base = format(amount);

    // No glitch below 70% paradox
    if (paradoxLevel < 0.7) return base;

    // Corruption chance increases with paradox level
    final corruptionChance = (paradoxLevel - 0.7) * 2; // 0 to 0.6

    return base.split('').map((char) {
      if (_random.nextDouble() < corruptionChance) {
        return _glitchChars[_random.nextInt(_glitchChars.length)];
      }
      return char;
    }).join();
  }

  /// Format time duration for offline progress
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format percentage (e.g., 75.5%)
  static String formatPercent(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format multiplier (e.g., 2.5x)
  static String formatMultiplier(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}x';
  }
}
