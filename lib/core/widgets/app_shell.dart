import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/settings/app_settings_controller.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  void _onTap(int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.home);
      case 1:
        Get.offNamed(AppRoutes.children);
      case 2:
        Get.offNamed(AppRoutes.reports);
      case 3:
        Get.offNamed(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: _onTap,
      destinations: [
        _navDestination('🏠', 'nav_home'),
        _navDestination('📚', 'nav_content'),
        _navDestination('📊', 'nav_progress'),
        _navDestination('⚙️', 'nav_settings'),
      ],
    );
  }
}

NavigationDestination _navDestination(String emoji, String labelKey) =>
    NavigationDestination(
      icon: _NavEmoji(emoji: emoji),
      selectedIcon: _NavEmoji(emoji: emoji),
      label: labelKey.tr,
    );

/// نفس الحجم للحالتين، حتى لا يتغير شكل الشريط عند التبديل.
class _NavEmoji extends StatelessWidget {
  const _NavEmoji({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 22, height: 1)),
      ),
    );
  }
}
IconButton appProfileButton() => IconButton(
      tooltip: 'profile'.tr,
      icon: const Icon(Icons.person_outline_rounded),
      onPressed: showProfileSheet,
    );

IconButton appNotificationsButton() => IconButton(
      tooltip: 'notifications_title'.tr,
      icon: const Icon(Icons.notifications_none_rounded),
      onPressed: showNotificationsSheet,
    );

class CenteredStatus extends StatelessWidget {
  const CenteredStatus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

void showNotificationsSheet() {
  Get.bottomSheet(
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StatusMessage(
          icon: Icons.notifications_none_rounded,
          title: 'notifications_empty'.tr,
        ),
      ),
    ),
  );
}

void showProfileSheet() {
  final settings = Get.find<AppSettingsController>();
  final textTheme = Get.theme.textTheme;
  Get.bottomSheet(
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('theme_title'.tr, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() => SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('theme_system'.tr),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('theme_light'.tr),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('theme_dark'.tr),
                    ),
                  ],
                  selected: {settings.themeMode.value},
                  onSelectionChanged: (s) => settings.setThemeMode(s.first),
                )),
            const SizedBox(height: 16),
            Obx(() => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.translate_rounded),
                  title: Text('language_title'.tr),
                  trailing: Text(settings.isArabic ? 'English' : 'العربية'),
                  onTap: settings.toggleLanguage,
                )),
            const Divider(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: Text('logout'.tr),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _logout() async {
  if (Get.isBottomSheetOpen == true) Get.back();
  await Get.find<AuthRepository>().logout();
  await Get.find<ChildRepository>().clearLocal();
  Get.offAllNamed(AppRoutes.login);
}