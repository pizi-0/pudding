import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension FormatMilliseconds on int {
  String toFormattedDuration() {
    String res = '';
    final duration = Duration(milliseconds: this);

    final hours = duration.inHours.toString();
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    if (hours != '0') {
      res += '${hours}h ';
    }

    res += '${minutes}m';

    return res;
  }

  String endsAt(BuildContext context) {
    final now = DateTime.now();
    final ends = now.add(Duration(milliseconds: this));

    final time = TimeOfDay.fromDateTime(ends);

    return time.format(context);
  }
}

extension LocalizedFileSize on int {
  String toLocalizedSize() {
    if (this <= 0) return '0 B';

    final base = 1024;
    final suffixes = ["B", "KB", "MB", "GB", "TB"];

    int i = (log(this) / log(base)).floor();
    i = min(i, suffixes.length - 1);

    double size = this / pow(base, i);

    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;

    return "${formatter.format(size)} ${suffixes[i]}";
  }
}
