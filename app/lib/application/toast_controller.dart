import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// One queued toast; [id] makes repeated messages distinguishable.
class ToastMessage {
  const ToastMessage(this.id, this.text);
  final int id;
  final String text;
}

/// FIFO toast queue: one visible at a time, each for [duration].
class ToastController extends ChangeNotifier {
  ToastController({this.duration = const Duration(milliseconds: 2500)});

  final Duration duration;
  final Queue<ToastMessage> _queue = Queue<ToastMessage>();
  ToastMessage? _current;
  Timer? _timer;
  int _seq = 0;
  bool _disposed = false;

  ToastMessage? get current => _current;

  void show(String text) {
    _queue.add(ToastMessage(++_seq, text));
    if (_current == null) _advance();
  }

  /// Hides the visible toast and moves to the next one.
  void dismiss() {
    _timer?.cancel();
    _advance();
  }

  void _advance() {
    if (_disposed) return;
    _timer?.cancel();
    if (_queue.isEmpty) {
      _current = null;
      notifyListeners();
      return;
    }
    _current = _queue.removeFirst();
    notifyListeners();
    _timer = Timer(duration, _advance);
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
