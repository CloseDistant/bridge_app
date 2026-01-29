import 'package:get/get.dart';

import '../../app/bindings/login_binding.dart';
import '../../app/bindings/register_binding.dart';
import '../../app/bindings/splash_binding.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/home/home_page.dart';
import '../../features/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static const String initial = Routes.splash;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage<dynamic>(name: Routes.home, page: () => const HomePage()),
  ];
}
