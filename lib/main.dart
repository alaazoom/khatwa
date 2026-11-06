import 'package:ajyal/core/localization/app_translations.dart';
import 'package:ajyal/core/network/api_client.dart';
import 'package:ajyal/core/network/connectivity_service.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/settings/app_settings_controller.dart';
import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/core/theme/app_theme.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/communication/data/communication_card_repository.dart';
import 'package:ajyal/features/communication/data/content_repository.dart';
import 'package:ajyal/features/device_link/data/device_link_repository.dart';
import 'package:ajyal/features/reports/data/report_repository.dart';
import 'package:ajyal/features/routine/data/routine_repository.dart';
import 'package:ajyal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storage = Get.put<StorageService>(StorageService(), permanent: true);
  Get.put<AppSettingsController>(AppSettingsController(), permanent: true);
  final api = Get.put<ApiClient>(ApiClient(), permanent: true);
  final auth = Get.put<AuthRepository>(
    AuthRepository(storage: storage),
    permanent: true,
  );
   final children = Get.put<ChildRepository>(
    ChildRepository(storage: storage),
    permanent: true,
  );
   Get.put<ContentRepository>(
    ContentRepository(),
    permanent: true,
  );
  Get.put<RoutineRepository>(
    RoutineRepository(storage: storage),
    permanent: true,
  );
   Get.put<DeviceLinkRepository>(
    DeviceLinkRepository(),
    permanent: true,
  );
  Get.put<ReportRepository>(
    ReportRepository(api: api, storage: storage, auth: auth),
    permanent: true,
  );

  final connectivity = await Get.putAsync<ConnectivityService>(
    () => ConnectivityService().init(),
    permanent: true,
  );

  // Offline-first: push pending child data as soon as the connection returns.
  ever<bool>(connectivity.isOnline, (online) {
    if (online) children.syncPending();
  });

  runApp(const KhuwaApp());
}

class KhuwaApp extends StatelessWidget {
  const KhuwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    return Obx(
      () => GetMaterialApp(
        title: 'خطوة',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: settings.locale.value,
        fallbackLocale: AppSettingsController.arabicLocale,
        supportedLocales: const [
          AppSettingsController.arabicLocale,
          AppSettingsController.englishLocale,
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode.value,
        initialRoute: AppRoutes.initial,
        getPages: AppRoutes.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}