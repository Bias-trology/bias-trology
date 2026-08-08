import 'package:flutter/material.dart';

import '../models/celestial_body.dart';

/// デザインシステム(仕様書、SVGモックアップ)で決めた配色をコードに落とし込んだもの。
const Color kBackgroundTop = Color(0xFF14162A);
const Color kBackgroundBottom = Color(0xFF06060D);
const Color kGoldAccent = Color(0xFFC9A876);
const Color kNatalRingColor = Color(0xFF9FB3C8);

const Map<CelestialBody, Color> kCelestialColors = {
  CelestialBody.sun: Color(0xFFE8B94E),
  CelestialBody.moon: Color(0xFFC9D6E3),
  CelestialBody.mercury: Color(0xFFB7A8D9),
  CelestialBody.venus: Color(0xFFE3A9A0),
  CelestialBody.mars: Color(0xFFC0495A),
  CelestialBody.jupiter: Color(0xFF6B7FD1),
  CelestialBody.saturn: Color(0xFFA98A54),
};
