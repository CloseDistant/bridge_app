import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/tokens/app_space.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    // 暖色渐变（轻/暗模式分别调参），并基于顶部颜色推导文字颜色。
    final warmTop = brightness == Brightness.dark
        ? const Color(0xFF2B1B14)
        : const Color(0xFFFFF3E6);
    final warmMid = brightness == Brightness.dark
        ? const Color(0xFF3A241A)
        : const Color(0xFFFFE6CC);
    final warmBottom = brightness == Brightness.dark
        ? const Color(0xFF1A1412)
        : const Color(0xFFFFD7B0);

    Color onColorFor(Color background) {
      return background.computeLuminance() < 0.45
          ? Colors.white
          : Colors.black87;
    }

    final titleColor = onColorFor(warmTop);
    final subtitleColor = titleColor.withValues(alpha: 0.82);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) {
                return ColoredBox(
                  color: scheme.surface,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 72,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    warmTop.withValues(alpha: 0.70),
                    warmMid.withValues(alpha: 0.45),
                    warmBottom.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.space16),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: AppSpace.space24),
                        Text(
                          'Fragments',
                          style: textStyle.headlineSmall?.copyWith(
                            color: titleColor,
                            shadows: const <Shadow>[
                              Shadow(
                                blurRadius: 10,
                                offset: Offset(0, 2),
                                color: Color(0x33000000),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpace.space12),
                        Text(
                          '记录美好 不留遗憾',
                          style: textStyle.bodyMedium?.copyWith(
                            color: subtitleColor,
                            shadows: const <Shadow>[
                              Shadow(
                                blurRadius: 10,
                                offset: Offset(0, 2),
                                color: Color(0x33000000),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.space24),
                      child: CircularProgressIndicator(
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
