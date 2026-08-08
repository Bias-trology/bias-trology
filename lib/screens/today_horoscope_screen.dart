import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../astrology/daily_feature.dart';
import '../astrology/houses.dart';
import '../astrology/julian_day.dart';
import '../astrology/planetary_positions.dart';
import '../models/celestial_body.dart';
import '../models/icon_display_mode.dart';
import '../models/wheel_stage.dart';
import '../theme/celestial_theme.dart';
import '../widgets/celestial_data_table.dart';
import '../widgets/celestial_glyph_icon.dart';
import '../widgets/horoscope_wheel_painter.dart';
import '../widgets/live_clock.dart';
import '../widgets/mode_slider.dart';
import '../widgets/starfield.dart';
import 'oshi_fortune_stub_screen.dart';

/// 今日のホロスコープ画面(仕様書9.1節)。
class TodayHoroscopeScreen extends StatefulWidget {
  const TodayHoroscopeScreen({super.key});

  @override
  State<TodayHoroscopeScreen> createState() => _TodayHoroscopeScreenState();
}

class _TodayHoroscopeScreenState extends State<TodayHoroscopeScreen>
    with TickerProviderStateMixin {
  // TODO: ユーザーの現在地(User.currentLocation)が実装され次第差し替える。
  static const double _placeholderLatitude = 35.6812;
  static const double _placeholderLongitude = 139.7671;

  Map<CelestialBody, double> _longitudes = {};
  DailyFeature? _feature;
  double? _ascendantDeg;
  List<double>? _houseCusps;

  WheelStage _stage = WheelStage.trueLongitudeGlyph;
  double _rotationOffsetDeg = 0;

  late List<CelestialBody> _orderedBodies;
  late PageController _pageController;
  late CelestialBody _activeBody;

  late final AnimationController _glowController;
  late final AnimationController _decorController;
  late final AnimationController _starfieldController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _starfieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final utcNow = DateTime.now().toUtc();
    _longitudes = computeGeocentricLongitudes(utcNow);
    _feature = computeDailyFeature(utcNow);
    _activeBody = _feature!.featuredBody;
    _orderedBodies = _bodiesForStage(_stage);
    _pageController = PageController(
      initialPage: _orderedBodies.indexOf(_activeBody),
      viewportFraction: 0.6,
    );
  }

  List<CelestialBody> _bodiesForStage(WheelStage stage) {
    if (stage.isEvenlySpaced) {
      return CelestialBody.values.toList();
    }
    final list = CelestialBody.values.toList();
    list.sort((a, b) => _longitudes[a]!.compareTo(_longitudes[b]!));
    return list;
  }

  void _onClockTick(DateTime now) {
    final utc = now.toUtc();
    final jd = toJulianDay(utc);
    setState(() {
      _longitudes = computeGeocentricLongitudes(utc);
      _feature = computeDailyFeature(utc);
      _ascendantDeg = computeAscendantDeg(
        jd,
        _placeholderLongitude,
        _placeholderLatitude,
      );
      _houseCusps = computeEqualHouseCusps(_ascendantDeg!);
    });
  }

  void _handleStageChanged(WheelStage stage) {
    setState(() {
      _rotationOffsetDeg = 0;
      _stage = stage;
      _orderedBodies = _bodiesForStage(stage);
      final newIndex = _orderedBodies.indexOf(_activeBody);
      _pageController.dispose();
      _pageController = PageController(
        initialPage: newIndex,
        viewportFraction: 0.6,
      );
    });
  }

  void _jumpToBody(CelestialBody body) {
    final index = _orderedBodies.indexOf(body);
    if (index < 0) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _decorController.dispose();
    _starfieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feature = _feature;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBackgroundTop, kBackgroundBottom],
              ),
            ),
          ),
          Starfield(animation: _starfieldController),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '今日のホロスコープ',
                    style: TextStyle(color: kGoldAccent, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: LiveClock(onTick: _onClockTick),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ModeSlider(
                    stage: _stage,
                    onChanged: _handleStageChanged,
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: feature == null
                        ? const SizedBox.shrink()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final size = constraints.biggest;
                              return AnimatedBuilder(
                                animation: Listenable.merge(
                                    [_glowController, _decorController]),
                                builder: (context, _) {
                                  final painter = HoroscopeWheelPainter(
                                    bodies: CelestialBody.values,
                                    longitudes: _longitudes,
                                    layoutMode: _stage.isEvenlySpaced
                                        ? WheelLayoutMode.evenlySpaced
                                        : WheelLayoutMode.trueLongitude,
                                    activeBody: _activeBody,
                                    featuredBody: feature.featuredBody,
                                    featuredTier: feature.tier,
                                    rotationOffsetDeg: _rotationOffsetDeg,
                                    ascendantDeg: !_stage.isEvenlySpaced
                                        ? _ascendantDeg
                                        : null,
                                    houseCusps: !_stage.isEvenlySpaced
                                        ? _houseCusps
                                        : null,
                                    glowPhase: _glowController.value,
                                    displayMode: _stage.displayMode,
                                    starMode: _stage.isStarMode,
                                    decorRotationDeg:
                                        _decorController.value * 360,
                                  );
                                  return GestureDetector(
                                    onTapUp: (details) {
                                      final body = painter.hitTestBody(
                                          details.localPosition, size);
                                      if (body != null) _jumpToBody(body);
                                    },
                                    onPanUpdate: (details) {
                                      final center = Offset(
                                          size.width / 2, size.height / 2);
                                      final current = details.localPosition;
                                      final previous =
                                          current - details.delta;
                                      final angleCurrent = math.atan2(
                                          current.dy - center.dy,
                                          current.dx - center.dx);
                                      final anglePrevious = math.atan2(
                                          previous.dy - center.dy,
                                          previous.dx - center.dx);
                                      var deltaRad =
                                          angleCurrent - anglePrevious;
                                      if (deltaRad > math.pi) {
                                        deltaRad -= 2 * math.pi;
                                      }
                                      if (deltaRad < -math.pi) {
                                        deltaRad += 2 * math.pi;
                                      }
                                      setState(() {
                                        _rotationOffsetDeg +=
                                            deltaRad * 180 / math.pi;
                                      });
                                    },
                                    child: CustomPaint(
                                      size: size,
                                      painter: painter,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: feature == null
                      ? const SizedBox.shrink()
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.92, end: 1.0)
                                    .animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _stage.isStarMode
                              ? SingleChildScrollView(
                                  key: const ValueKey('table'),
                                  child: CelestialDataTable(
                                    longitudes: _longitudes,
                                    houseCusps: _houseCusps,
                                  ),
                                )
                              : PageView.builder(
                                  key: ValueKey(_stage),
                                  controller: _pageController,
                                  itemCount: _orderedBodies.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _activeBody = _orderedBodies[index];
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final body = _orderedBodies[index];
                                    final isActive = body == _activeBody;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OshiFortuneStubScreen(
                                                    body: body),
                                          ),
                                        );
                                      },
                                      child: AnimatedScale(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeOut,
                                        scale: isActive ? 1.0 : 0.85,
                                        child: _FeaturedCard(
                                          body: body,
                                          isActive: isActive,
                                          tier: body == feature.featuredBody
                                              ? feature.tier
                                              : null,
                                          displayMode: _stage.displayMode,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 拡大カルーセルの1枚のカード。
class _FeaturedCard extends StatelessWidget {
  final CelestialBody body;
  final bool isActive;
  final FeatureTier? tier;
  final IconDisplayMode displayMode;

  const _FeaturedCard({
    required this.body,
    required this.isActive,
    required this.displayMode,
    this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final color = kCelestialColors[body]!;
    final borderColor = isActive ? kGoldAccent : color.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: kBackgroundTop,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isActive ? 1.6 : 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CelestialGlyphIcon(
            body: body,
            size: 48,
            color: isActive ? kGoldAccent : color,
            displayMode: displayMode,
          ),
          const SizedBox(height: 8),
          Text(
            body.japaneseName,
            style: TextStyle(
              color: isActive ? kGoldAccent : color,
              fontSize: 16,
            ),
          ),
          if (tier != null) ...[
            const SizedBox(height: 4),
            Text(
              _tierLabel(tier!),
              style: const TextStyle(color: kGoldAccent, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _tierLabel(FeatureTier tier) {
    switch (tier) {
      case FeatureTier.regular:
        return '今日の一推し';
      case FeatureTier.notable:
        return '際立つ一推し';
      case FeatureTier.special:
        return '豪華演出';
    }
  }
}
