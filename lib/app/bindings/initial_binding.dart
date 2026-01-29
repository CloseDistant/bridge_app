import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/token_store.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://localhost:7088',
    );

    Get.put<ApiConfig>(ApiConfig(baseUrl: apiBaseUrl), permanent: true);

    Get.put<TokenStore>(TokenStore(), permanent: true);
    Get.put<SessionService>(
      SessionService(Get.find<TokenStore>()),
      permanent: true,
    );

    Get.put<ApiClient>(
      ApiClient(
        config: Get.find<ApiConfig>(),
        accessTokenProvider: () =>
            Get.find<SessionService>().token?.accessToken,
        tokenRefreshHandler: () async {
          await Get.find<AuthRepository>().refreshToken();
        },
      ),
      permanent: true,
    );

    Get.put<AuthApi>(AuthApi(Get.find<ApiClient>()), permanent: true);
    Get.put<AuthRepository>(
      AuthRepository(
        api: Get.find<AuthApi>(),
        session: Get.find<SessionService>(),
      ),
      permanent: true,
    );

    Get.put<AuthService>(
      AuthService(Get.find<AuthRepository>(), Get.find<SessionService>()),
      permanent: true,
    );
  }
}
