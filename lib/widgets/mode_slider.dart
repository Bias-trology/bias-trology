import 'package:flutter/material.dart';

import '../models/wheel_stage.dart';
import '../theme/celestial_theme.dart';

/// 「推しモード」⇄「星モード」を結ぶ4段階のスライダー。
/// トラック内を、選択中の段階を示す箱がスナップして移動する。
class ModeSlider extends StatelessWidget {
  final WheelStage stage;
  final ValueChanged<WheelStage> onChanged;

  const ModeSlider({super.key, required this.stage, required this.onChanged});

  static const _stages = WheelStage.values;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 220.0;
    const boxWidth = 50.0;
    final index = _stages.indexOf(stage);
    final step = (trackWidth - boxWidth) / (_stages.length - 1);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final ratio = (local.dx / trackWidth).clamp(0.0, 1.0);
        final nearest =
            (ratio * (_stages.length - 1)).round().clamp(0, _stages.length - 1);
        if (_stages[nearest] != stage) onChanged(_stages[nearest]);
      },
      child: Column(
        children: [
          SizedBox(
            width: trackWidth,
            height: 28,
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: kGoldAccent.withValues(alpha: 0.25),
                  ),
                ),
                for (var i = 0; i < _stages.length; i++)
                  Positioned(
                    left: i * step + boxWidth / 2 - 1,
                    top: 8,
                    child: Container(
                      width: 2,
                      height: 10,
                      color: kGoldAccent.withValues(alpha: 0.3),
                    ),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: index * step,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      final next =
                          _stages[(index + 1) % _stages.length];
                      onChanged(next);
                    },
                    child: Container(
                      width: boxWidth,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kBackgroundTop,
                        border: Border.all(color: kGoldAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stage.label,
                        style: const TextStyle(
                          color: kGoldAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const SizedBox(
            width: trackWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('推しモード',
                    style: TextStyle(color: Color(0xFF6a6a78), fontSize: 10)),
                Text('星モード',
                    style: TextStyle(color: Color(0xFF6a6a78), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
