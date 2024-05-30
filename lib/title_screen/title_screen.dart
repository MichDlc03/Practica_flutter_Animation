import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../assets.dart';
import '../orb_shader/orb_shader_config.dart';
import '../orb_shader/orb_shader_widget.dart';
import '../styles.dart';
import 'particle_overlay.dart';                          // Add this import
import 'title_screen_ui.dart';


class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: MouseRegion(
        onHover: _handleMouseMove,
        child: _AnimatedColors(
          orbColor: _orbColor,
          emitColor: _emitColor,
          builder: (_, orbColor, emitColor) {
            return Stack(
              children: [
                /// Bg-Base
                Image.asset(AssetPaths.titleBgBase),

                /// Bg-Receive
                _LitImage(
                  color: orbColor,
                  imgSrc: AssetPaths.titleBgReceive,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Orb
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Orb
                      OrbShaderWidget(
                        key: _orbKey,
                        mousePos: _mousePos,
                        minEnergy: _minOrbEnergy,
                        config: OrbShaderConfig(
                          ambientLightColor: orbColor,
                          materialColor: orbColor,
                          lightColor: orbColor,
                        ),
                        onUpdate: (energy) => setState(() {
                          _orbEnergy = energy;
                        }),
                      ),
                    ],
                  ),
                ),

                /// Mg-Base
                _LitImage(
                  imgSrc: AssetPaths.titleMgBase,
                  color: orbColor,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Mg-Receive
                _LitImage(
                  imgSrc: AssetPaths.titleMgReceive,
                  color: orbColor,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Mg-Emit
                _LitImage(
                  imgSrc: AssetPaths.titleMgEmit,
                  color: emitColor,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalEmitLightAmt,
                ),

                /// Particle Field
                Positioned.fill(                          // Add from here...
                  child: IgnorePointer(
                    child: ParticleOverlay(
                      color: orbColor,
                      energy: _orbEnergy,
                    ),
                  ),
                ),                                        // to here.

                /// Fg-Rocks
                Image.asset(AssetPaths.titleFgBase),

                /// Fg-Receive
                _LitImage(
                  imgSrc: AssetPaths.titleFgReceive,
                  color: orbColor,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Fg-Emit
                _LitImage(
                  imgSrc: AssetPaths.titleFgEmit,
                  color: emitColor,
                  pulseEffect: _pulseEffect,
                  lightAmt: _finalEmitLightAmt,
                ),

                /// UI
                Positioned.fill(
                  child: TitleScreenUi(
                    difficulty: _difficulty,
                    onDifficultyFocused: _handleDifficultyFocused,
                    onDifficultyPressed: _handleDifficultyPressed,
                    onStartPressed: _handleStartPressed,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 1.seconds, delay: .3.seconds);
          },
        ),
      ),
    ),
  );
}
class _LitImage extends StatelessWidget {
  const _LitImage({
    required this.color,
    required this.imgSrc,
    required this.pulseEffect,                            // Add this parameter
    required this.lightAmt,
  });
  final Color color;
  final String imgSrc;
  final AnimationController pulseEffect;                  // Add this attribute
  final double lightAmt;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    return ListenableBuilder(                             // Edit from here...
      listenable: pulseEffect,
      child: Image.asset(imgSrc),
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            hsl.withLightness(hsl.lightness * lightAmt).toColor(),
            BlendMode.modulate,
          ),
          child: child,
        );
      },
    );                                                    // to here.
  }
}
class _AnimatedColors extends StatelessWidget {
  const _AnimatedColors({
    required this.emitColor,
    required this.orbColor,
    required this.builder,
  });

  final Color emitColor;
  final Color orbColor;

  final Widget Function(BuildContext context, Color orbColor, Color emitColor)
      builder;

  @override
  Widget build(BuildContext context) {
    final duration = .5.seconds;
    return TweenAnimationBuilder(
      tween: ColorTween(begin: emitColor, end: emitColor),
      duration: duration,
      builder: (_, emitColor, __) {
        return TweenAnimationBuilder(
          tween: ColorTween(begin: orbColor, end: orbColor),
          duration: duration,
          builder: (context, orbColor, __) {
            return builder(context, orbColor!, emitColor!);
          },
        );
      },
    );
  }
}
