import 'package:flutter/material.dart';

extension FormatMilliseconds on int {
  String toFormattedDuration() {
    String res = '';
    final duration = Duration(milliseconds: this);

    final hours = duration.inHours.toString();
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours != '0') {
      res += '${hours}h ';
    }

    res += ' ${minutes}m ';

    if (seconds != '00') {
      res += '${seconds}s';
    }

    return res;
  }

  String endsAt(BuildContext context) {
    final now = DateTime.now();
    final ends = now.add(Duration(milliseconds: this));

    final time = TimeOfDay.fromDateTime(ends);

    return time.format(context);
  }
}
