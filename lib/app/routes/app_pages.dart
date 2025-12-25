import 'package:get/get.dart';

import '../../features/home/home_page.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static const String initial = Routes.home;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(name: Routes.home, page: () => const HomePage()),
  ];
}
