import 'dart:async';

import 'package:flutter/cupertino.dart';


class Debounce {
  Timer? _timer;

  void call(VoidCallback action, {Duration delay = const Duration(milliseconds: 300)}) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}