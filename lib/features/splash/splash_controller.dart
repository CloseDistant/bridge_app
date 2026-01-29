import 'package:bridge_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../core/services/session_service.dart';

class SplashController extends GetxController {
  final SessionService _session = Get.find<SessionService>();

  @override
  void onReady() {
    super.onReady();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    await _session.ensureLoaded();

    if (_session.isSessionValid) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}
