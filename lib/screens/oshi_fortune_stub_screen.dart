import 'package:flutter/material.dart';

import '../models/celestial_body.dart';
import '../theme/celestial_theme.dart';

/// 「推しとの運勢」ページの仮実装。
/// カードタップの導線だけ先に用意し、中身は後日実装する想定。
class OshiFortuneStubScreen extends StatelessWidget {
  final CelestialBody body;

  const OshiFortuneStubScreen({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundTop, kBackgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: kGoldAccent),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      '${body.japaneseName}との運勢(準備中)',
                      style: const TextStyle(color: kGoldAccent, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'ここに推しとの運勢が表示される予定です',
                    style: TextStyle(color: Color(0xFF8a8a99)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
