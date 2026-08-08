import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/celestial_theme.dart';

/// 秒単位で切れ目なく更新される日時表示。単体のデジタル時計としても使える。
/// [onTick]が渡された場合、1秒ごとの現在時刻を呼び出し元にも通知する
/// (ホロスコープ側の再計算のトリガーに使う)。
class LiveClock extends StatefulWidget {
  final void Function(DateTime now)? onTick;
  final TextStyle? style;

  const LiveClock({super.key, this.onTick, this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = DateTime.now();
      setState(() => _now = next);
      widget.onTick?.call(next);
    });
    // 初回のonTickは、現在のビルドが完了した直後のフレームで発火させる
    // (initState中に親のsetStateを直接呼ぶと「ビルド中にsetState」エラーになるため)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onTick?.call(_now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final label =
        '${_now.year}年${_now.month}月${_now.day}日(${weekdays[_now.weekday - 1]}) '
        '${_twoDigits(_now.hour)}:${_twoDigits(_now.minute)}:${_twoDigits(_now.second)}';

    return Text(
      label,
      style: widget.style ?? const TextStyle(color: kGoldAccent, fontSize: 12),
    );
  }
}