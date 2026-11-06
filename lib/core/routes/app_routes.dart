import 'package:ajyal/features/auth/presentation/controllers/child_setup_controller.dart';
import 'package:ajyal/features/auth/presentation/views/child_setup_page.dart';
import 'package:ajyal/features/communication/presentation/controllers/cards_controller.dart';
import 'package:ajyal/features/communication/presentation/views/cards_page.dart';
import 'package:ajyal/features/device_link/presentation/controllers/device_link_controller.dart';
import 'package:ajyal/features/device_link/presentation/views/device_link_page.dart';
import 'package:ajyal/features/reports/presentation/controllers/reports_controller.dart';
import 'package:ajyal/features/reports/presentation/views/reports_page.dart';
import 'package:ajyal/features/routine/presentation/controllers/routine_controller.dart';
import 'package:ajyal/features/routine/presentation/views/routine_page.dart';
import 'package:ajyal/features/settings/presentation/controllers/settings_controller.dart';
import 'package:ajyal/features/settings/presentation/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/auth/presentation/controllers/login_controller.dart';
import 'package:ajyal/features/auth/presentation/controllers/register_controller.dart';
import 'package:ajyal/features/auth/presentation/views/login_page.dart';
import 'package:ajyal/features/auth/presentation/views/register_page.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/children/presentation/controllers/children_controller.dart';
import 'package:ajyal/features/children/presentation/views/children_page.dart';

import 'package:ajyal/features/home/presentation/controllers/home_controller.dart';
import 'package:ajyal/features/home/presentation/views/home_page.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String childSetup = '/child-setup';
  static const String home = '/home';
  static const String children = '/children';
  static const String cards = '/cards';
  static const String routine = '/routine';
  static const String deviceLink = '/device-link';
  static const String reports = '/reports';
    static const String settings = '/settings';

  static String get initial =>
      Get.find<AuthRepository>().isLoggedIn ? home : login;
// static String get initial => home;
  static final pages = <GetPage>[
    

    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: childSetup,
      page: () => const ChildSetupPage(),
      binding: ChildSetupBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthGuard(), ChildProfileGuard()],
    ),
    GetPage(
      name: children,
      page: () => const ChildrenPage(),
      binding: ChildrenBinding(),
      middlewares: [AuthGuard()],
    ),
        GetPage(
      name: children,
      page: () => const ChildrenPage(),
      binding: ChildrenBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: cards,
      page: () => const CardsPage(),
      binding: CardsBinding(),
      middlewares: [AuthGuard(), ChildProfileGuard()],
    ),
    GetPage(
      name: routine,
      page: () => const RoutinePage(),
      binding: RoutineBinding(),
      middlewares: [AuthGuard(), ChildProfileGuard()],
    ),
        GetPage(
      name: deviceLink,
      page: () => const DeviceLinkPage(),
      binding: DeviceLinkBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: reports,
      page: () => const ReportsPage(),
      binding: ReportsBinding(),
      middlewares: [AuthGuard(), ChildProfileGuard()],
    ),
        GetPage(
      name: settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      middlewares: [AuthGuard(), ChildProfileGuard()],
    ),
  ];
}

// /// يمنع الدخول للشاشات المحمية دون جلسة، ويمنع الجلسة من العودة لشاشات الدخول.
// class AuthGuard extends GetMiddleware {
//   @override
//   RouteSettings? redirect(String? route) {
//     final loggedIn = Get.find<AuthRepository>().isLoggedIn;
//     final isPublic = route == AppRoutes.login || route == AppRoutes.register;
//     if (!loggedIn && !isPublic) return const RouteSettings(name: AppRoutes.login);
//     if (loggedIn && isPublic) return const RouteSettings(name: AppRoutes.home);
//     return null;
//   }
// }


class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => null; // للتجربة فقط
}

/// يوجّه إلى إعداد الملف إذا لم يكن الطفل مُعداً بعد.
class ChildProfileGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<ChildRepository>().getProfile() == null
          ? const RouteSettings(name: AppRoutes.childSetup)
          : null;
}