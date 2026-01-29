import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final nicknameController = TextEditingController();

  final phoneFocusNode = FocusNode();
  final codeFocusNode = FocusNode();
  final nicknameFocusNode = FocusNode();

  final RxString phone = ''.obs;
  final RxString code = ''.obs;
  final RxString nickname = ''.obs;

  final RxInt secondsRemaining = 0.obs;
  final RxBool requestingCode = false.obs;
  final RxBool registering = false.obs;
  final RxString errorText = ''.obs;

  Timer? _timer;

  List<TextInputFormatter> get phoneFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ];

  List<TextInputFormatter> get codeFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ];

  bool get isPhoneValid => phone.value.trim().length == 11;
  bool get isCodeValid => code.value.trim().length == 6;

  bool get canRequestCode =>
      isPhoneValid && secondsRemaining.value == 0 && !requestingCode.value;

  bool get canRegister => isPhoneValid && isCodeValid && !registering.value;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      final presetPhone = args['phone'];
      if (presetPhone is String && presetPhone.trim().isNotEmpty) {
        phoneController.text = presetPhone.trim();
        phone.value = presetPhone.trim();
      }
    }
  }

  @override
  void onClose() {
    _timer?.cancel();

    phoneController.dispose();
    codeController.dispose();
    nicknameController.dispose();

    phoneFocusNode.dispose();
    codeFocusNode.dispose();
    nicknameFocusNode.dispose();

    super.onClose();
  }

  void onPhoneChanged(String value) {
    phone.value = value;
    errorText.value = '';
  }

  void onCodeChanged(String value) {
    code.value = value;
    errorText.value = '';
  }

  void onNicknameChanged(String value) {
    nickname.value = value;
    errorText.value = '';
  }

  void clearPhone() {
    phoneController.clear();
    phone.value = '';
  }

  void clearCode() {
    codeController.clear();
    code.value = '';
  }

  Future<void> requestCode() async {
    if (!canRequestCode) return;

    requestingCode.value = true;
    errorText.value = '';

    try {
      await _auth.requestOtp(phone: phoneController.text.trim());
      _startCountdown(60);
      codeFocusNode.requestFocus();
    } catch (_) {
      errorText.value = '验证码发送失败，请稍后重试';
    } finally {
      requestingCode.value = false;
    }
  }

  Future<void> registerAndLogin() async {
    if (!canRegister) return;

    registering.value = true;
    errorText.value = '';

    try {
      final p = phoneController.text.trim();
      final c = codeController.text.trim();
      final n = nicknameController.text.trim();

      await _auth.registerBySms(
        phone: p,
        code: c,
        nickname: n.isEmpty ? null : n,
      );

      final ok = await _auth.loginWithOtp(phone: p, otp: c);
      if (ok) {
        Get.offAllNamed(Routes.home);
      } else {
        errorText.value = '注册成功，但登录失败，请改用登录页重试';
      }
    } catch (_) {
      errorText.value = '注册失败，请检查验证码或稍后重试';
    } finally {
      registering.value = false;
    }
  }

  void goToLogin() {
    Get.offAllNamed(
      Routes.login,
      arguments: <String, Object?>{'phone': phoneController.text.trim()},
    );
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();

    secondsRemaining.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final next = secondsRemaining.value - 1;
      secondsRemaining.value = next < 0 ? 0 : next;
      if (secondsRemaining.value == 0) timer.cancel();
    });
  }
}
