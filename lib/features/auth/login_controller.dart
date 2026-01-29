import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final otpFocusNode = FocusNode();

  final RxString phone = ''.obs;
  final RxString otp = ''.obs;

  final RxInt secondsRemaining = 0.obs;
  final RxBool requestingOtp = false.obs;
  final RxBool loggingIn = false.obs;
  final RxString errorText = ''.obs;

  Timer? _timer;

  List<TextInputFormatter> get phoneFormatters => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ];

  List<TextInputFormatter> get otpFormatters => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  bool get isPhoneValid {
    final value = phone.value.trim();
    return value.length == 11;
  }

  bool get isOtpValid {
    final value = otp.value.trim();
    return value.length == 6;
  }

  bool get canRequestOtp {
    return isPhoneValid && secondsRemaining.value == 0 && !requestingOtp.value;
  }

  bool get canLogin {
    return isPhoneValid && isOtpValid && !loggingIn.value;
  }

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
    otpController.dispose();
    phoneFocusNode.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }

  void onPhoneChanged(String value) {
    phone.value = value;
    errorText.value = '';
  }

  void onOtpChanged(String value) {
    otp.value = value;
    errorText.value = '';
  }

  void clearPhone() {
    phoneController.clear();
    phone.value = '';
  }

  void clearOtp() {
    otpController.clear();
    otp.value = '';
  }

  Future<void> requestOtp() async {
    if (!canRequestOtp) return;

    requestingOtp.value = true;
    errorText.value = '';

    try {
      await _auth.requestOtp(phone: phoneController.text.trim());
      _startCountdown(60);
      otpFocusNode.requestFocus();
    } catch (_) {
      errorText.value = '验证码发送失败，请稍后重试';
    } finally {
      requestingOtp.value = false;
    }
  }

  Future<void> login() async {
    //先跳过验证
    Get.offAllNamed(Routes.home);
    if (!canLogin) return;

    loggingIn.value = true;
    errorText.value = '';

    try {
      final ok = await _auth.loginWithOtp(
        phone: phoneController.text.trim(),
        otp: otpController.text.trim(),
      );

      if (ok) {
        Get.offAllNamed(Routes.home);
      } else {
        errorText.value = '验证码不正确，请重试';
      }
    } catch (_) {
      errorText.value = '登录失败，请稍后重试';
    } finally {
      loggingIn.value = false;
    }
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
