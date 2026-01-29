import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../theme/tokens/app_radius.dart';
import '../../theme/tokens/app_space.dart';
import '../../ui/adaptive/adaptive_button.dart';
import '../../ui/adaptive/platform_style.dart';
import '../../app/routes/app_routes.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  static Future<void> _showTextDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    if (PlatformStyle.isCupertino(context)) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: AppSpace.space12),
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: scheme.onSurface),
                    child: Text(message),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('知道了'),
              ),
            ],
          );
        },
      );
    }

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: SingleChildScrollView(child: Text(message)),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final LoginController controller;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _bgController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    InputDecoration decoration({
      required String label,
      required String hint,
      Widget? prefixIcon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.70),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismissKeyboard,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (BuildContext context, Widget? child) {
                  // 使用正弦曲线让“呼吸/流动”更可见但不刺眼。
                  final raw = _bgController.value;
                  final breathe = 0.5 + 0.5 * math.sin(raw * math.pi);
                  final flow = 0.5 + 0.5 * math.sin(raw * math.pi * 2);

                  // 赛博暖风：暖色(琥珀/珊瑚)为主，带一点青色电流感点缀。
                  const warmA = Color(0xFFFFD9B0);
                  const warmB = Color(0xFFFFA37A);
                  const warmC = Color(0xFFFF6B8B);
                  const cyber = Color(0xFF35D4C7);
                  const neon = Color(0xFF8B5CFF);

                  Color mix(Color a, Color b, double v) => Color.lerp(a, b, v)!;

                  final c1 = mix(warmA, warmB, 0.30 + 0.45 * breathe)
                      .withValues(alpha: 0.40);
                  final c2 = mix(warmB, warmC, 0.20 + 0.55 * (1 - breathe))
                      .withValues(alpha: 0.30);
                  final c3 = mix(cyber, warmA, 0.55 + 0.35 * flow)
                      .withValues(alpha: 0.22);
                    final c4Glow = mix(neon, scheme.surface, 0.70)
                      .withValues(alpha: 0.12);

                  // 方向微动：轻微“呼吸流动”，不晃眼。
                  final begin = Alignment(-1.0 + 0.85 * flow, -1.0 + 0.20 * breathe);
                  final end = Alignment(1.0 - 0.35 * flow, 1.0 - 0.55 * breathe);

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: begin,
                        end: end,
                        colors: <Color>[c1, c2, c3, c4Glow, scheme.surface],
                        stops: <double>[
                          0.0,
                          0.30 + 0.05 * breathe,
                          0.62 + 0.06 * flow,
                          0.84,
                          1.0,
                        ],
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            ),
            // 霓虹光晕（两团轻微移动的 radial glow）
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, _) {
                    final raw = _bgController.value;
                    final a = 0.5 + 0.5 * math.sin(raw * math.pi);
                    final b = 0.5 + 0.5 * math.sin(raw * math.pi * 2);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.7 + 0.45 * a, -0.9 + 0.25 * b),
                          radius: 1.0,
                          colors: <Color>[
                            const Color(0xFF35D4C7).withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                          stops: const <double>[0.0, 0.65],
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0.9 - 0.40 * b, -0.2 + 0.35 * a),
                            radius: 1.1,
                            colors: <Color>[
                              const Color(0xFFFF6B8B).withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                            stops: const <double>[0.0, 0.70],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, _) {
                    final raw = _bgController.value;
                    final phase = raw * 26.0;
                    return CustomPaint(
                      painter: _DotGridPainter(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.11),
                        phase: phase,
                      ),
                    );
                  },
                ),
              ),
            ),
            // 扫描线（非常轻微）
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _WaveScanlinePainter(
                        // 更赛博：偏青的线条，但保持很淡
                        color: const Color(0xFF35D4C7)
                            .withValues(alpha: 0.10),
                        phase: _bgController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpace.space16),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: AppSpace.space24),
                            Column(
                              children: <Widget>[
                              ShaderMask(
                                shaderCallback: (Rect rect) {
                                  return LinearGradient(
                                    colors: <Color>[
                                      scheme.onSurface,
                                      scheme.primary,
                                      scheme.onSurface,
                                    ],
                                    stops: const <double>[0.0, 0.55, 1.0],
                                  ).createShader(rect);
                                },
                                child: Text(
                                  'Fragments',
                                  textAlign: TextAlign.center,
                                  style: textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpace.space12),
                              Text(
                                '使用手机号验证码登录/注册',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.space24),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: _GlassCard(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpace.space16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                      Obx(() {
                                        return TextField(
                                          controller: controller.phoneController,
                                          focusNode: controller.phoneFocusNode,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters:
                                              controller.phoneFormatters,
                                          onChanged: controller.onPhoneChanged,
                                          decoration: decoration(
                                            label: '手机号',
                                            hint: '请输入11位手机号',
                                            prefixIcon:
                                                const Icon(Icons.phone_iphone),
                                            suffixIcon:
                                                controller.phone.value.trim().isEmpty
                                                    ? null
                                                    : IconButton(
                                                        tooltip: '清空',
                                                        onPressed:
                                                            controller.clearPhone,
                                                        icon:
                                                            const Icon(Icons.clear),
                                                      ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: AppSpace.space12),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Obx(() {
                                              return TextField(
                                                controller:
                                                    controller.otpController,
                                                focusNode: controller.otpFocusNode,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.done,
                                                inputFormatters:
                                                    controller.otpFormatters,
                                                onChanged: controller.onOtpChanged,
                                                decoration: decoration(
                                                  label: '验证码',
                                                  hint: '6位数字',
                                                  prefixIcon:
                                                      const Icon(Icons.verified),
                                                  suffixIcon: controller.otp.value
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : IconButton(
                                                          tooltip: '清空',
                                                          onPressed:
                                                              controller.clearOtp,
                                                          icon: const Icon(
                                                              Icons.clear),
                                                        ),
                                                ),
                                                onSubmitted:
                                                    (_) => controller.login(),
                                              );
                                            }),
                                          ),
                                          const SizedBox(width: AppSpace.space12),
                                          Obx(() {
                                            final seconds =
                                                controller.secondsRemaining.value;
                                            final enabled =
                                                controller.canRequestOtp;

                                            return SizedBox(
                                              height: 48,
                                              child: AnimatedScale(
                                                duration: const Duration(
                                                    milliseconds: 160),
                                                scale: enabled ? 1.0 : 0.98,
                                                child: AdaptiveButton(
                                                  variant:
                                                      AdaptiveButtonVariant.tonal,
                                                  onPressed: enabled
                                                      ? () {
                                                          HapticFeedback
                                                              .selectionClick();
                                                          controller.requestOtp();
                                                        }
                                                      : null,
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 180),
                                                    child: controller
                                                            .requestingOtp.value
                                                        ? SizedBox(
                                                            key: const ValueKey(
                                                                'otp_loading'),
                                                            width: 92,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <Widget>[
                                                                SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth: 2,
                                                                    color: scheme
                                                                        .primary,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                const Text('发送中'),
                                                              ],
                                                            ),
                                                          )
                                                        : Text(
                                                            key: const ValueKey(
                                                                'otp_label'),
                                                            seconds > 0
                                                                ? '重发 ${seconds}s'
                                                                : '获取验证码',
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      Obx(() {
                                        final msg =
                                            controller.errorText.value.trim();
                                        return AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 180),
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          transitionBuilder:
                                              (Widget child, Animation<double> a) {
                                            return FadeTransition(
                                              opacity: a,
                                              child: SlideTransition(
                                                position: a.drive(
                                                  Tween<Offset>(
                                                    begin:
                                                        const Offset(0, -0.08),
                                                    end: Offset.zero,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: msg.isEmpty
                                              ? const SizedBox
                                                  .shrink(key: ValueKey('no_err'))
                                              : Padding(
                                                  key: const ValueKey('err'),
                                                  padding: const EdgeInsets.only(
                                                      top: AppSpace.space12),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.error_outline,
                                                          size: 16,
                                                          color: scheme.error),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          msg,
                                                          style: textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                  color:
                                                                      scheme.error),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        );
                                      }),
                                      const SizedBox(height: AppSpace.space16),
                                      Obx(() {
                                        final enabled = controller.canLogin;
                                        return SizedBox(
                                          height: 52,
                                          child: AnimatedScale(
                                            duration: const Duration(
                                                milliseconds: 160),
                                            scale: enabled ? 1.0 : 0.99,
                                            child: AdaptiveButton(
                                              onPressed: enabled
                                                  ? () {
                                                      HapticFeedback
                                                          .selectionClick();
                                                      controller.login();
                                                    }
                                                  : null,
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 180),
                                                child: controller.loggingIn.value
                                                    ? Row(
                                                        key: const ValueKey(
                                                            'login_loading'),
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  scheme.onPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          const Text('登录中...'),
                                                        ],
                                                      )
                                                    : const Text(
                                                        key: ValueKey('login_label'),
                                                        '登录',
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: AppSpace.space12),
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            final p = controller
                                                .phoneController.text
                                                .trim();
                                            Get.toNamed(
                                              Routes.register,
                                              arguments: <String, Object?>{
                                                'phone': p,
                                              },
                                            );
                                          },
                                          child: const Text('没有账号？去注册'),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpace.space4),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                          children: <InlineSpan>[
                                            const TextSpan(text: '登录即代表同意'),
                                            TextSpan(
                                              text: '《用户协议》',
                                              style:
                                                  TextStyle(color: scheme.primary),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  LoginPage._showTextDialog(
                                                    context,
                                                    title: '用户协议',
                                                    message:
                                                        '这里是用户协议占位内容。\n\n后续接入后台后，可在此展示完整协议文本或从远端加载。',
                                                  );
                                                },
                                            ),
                                            const TextSpan(text: '和'),
                                            TextSpan(
                                              text: '《隐私政策》',
                                              style:
                                                  TextStyle(color: scheme.primary),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  LoginPage._showTextDialog(
                                                    context,
                                                    title: '隐私政策',
                                                    message:
                                                        '这里是隐私政策占位内容。\n\n后续接入后台后，可在此展示完整隐私政策或从远端加载。',
                                                  );
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: AppSpace.space16),
                        ],
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 让卡片更贴合“赛博暖风”：暖色为底，青色做轻微高光。
    final panelA = const Color(0xFFFFE7CF).withValues(alpha: 0.60);
    final panelB = const Color(0xFFFFB08C).withValues(alpha: 0.22);
    final panelC = const Color(0xFF35D4C7).withValues(alpha: 0.10);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.65),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF35D4C7).withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: const Color(0xFFFF6B8B).withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 0),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                scheme.surface.withValues(alpha: 0.62),
                panelA,
                panelB,
                panelC,
              ],
              stops: const <double>[0.0, 0.45, 0.78, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 26.0;
    const radius = 1.1;

    // 轻微“漂移”让点阵有流动感。
    final dx = (phase % spacing);
    final dy = ((phase * 0.6) % spacing);

    for (double y = -spacing; y <= size.height + spacing; y += spacing) {
      for (double x = -spacing; x <= size.width + spacing; x += spacing) {
        final ox = x + dx;
        final oy = y + dy;
        canvas.drawCircle(Offset(ox, oy), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.phase != phase;
  }
}

class _WaveScanlinePainter extends CustomPainter {
  _WaveScanlinePainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    // 波浪扫描线：沿 Y 方向缓慢下移，同时线形起伏。
    final baseY = (size.height * phase) % size.height;
    final w = size.width;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.70).clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    Path makeWave(double y, double amp, double freq) {
      final path = Path();
      const samples = 64;
      for (int i = 0; i <= samples; i++) {
        final x = w * (i / samples);
        final wave = math.sin((i / samples) * math.pi * 2 * freq + phase * math.pi * 2);
        final yy = y + wave * amp;
        if (i == 0) {
          path.moveTo(x, yy);
        } else {
          path.lineTo(x, yy);
        }
      }
      return path;
    }

    final wave1 = makeWave(baseY, 6.0, 2.0);
    canvas.drawPath(wave1, glowPaint);
    canvas.drawPath(wave1, linePaint);

    // 两条更淡的“回波”线，增强层次但不抢眼。
    final echoPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.35).clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final wave2 = makeWave(baseY - 90, 3.5, 2.3);
    final wave3 = makeWave(baseY + 110, 4.0, 1.7);
    canvas.drawPath(wave2, echoPaint);
    canvas.drawPath(wave3, echoPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveScanlinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.phase != phase;
  }
}
