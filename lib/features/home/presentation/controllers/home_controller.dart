import 'dart:async';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/communication/data/content_repository.dart';
import 'package:ajyal/features/communication/data/models/communication_card.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ChildRepository _children = Get.find<ChildRepository>();
  final AuthRepository _auth = Get.find<AuthRepository>();
  final ContentRepository _content = Get.find<ContentRepository>();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();
  final child = Rxn<ChildProfile>();
  final userName = ''.obs;
  final cardsCount = 0.obs;

  StreamSubscription<List<CommunicationCard>>? _cardsSub;

  String get userFirstName => userName.value.trim().split(' ').first;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    try {
      userName.value = _auth.currentUser?.name ?? '';
      final profile = _children.getProfile();
      child.value = profile;

      _cardsSub?.cancel();
      _cardsSub = null;

      if (profile == null) {
        status.value = ViewStatus.empty;
        return;
      }

      status.value = ViewStatus.success;
      _cardsSub = _content.watchCards(profile.id).listen(
        (list) => cardsCount.value = list.length,
        onError: (_) {},
      );
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
      status.value = ViewStatus.error;
    }
  }

  Future<void> refresh() async {
    await _children.syncPending();
    load();
  }

  void showUnavailable() => Get.snackbar(
        'app_name'.tr,
        'unavailable_screen'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

  @override
  void onClose() {
    _cardsSub?.cancel();
    super.onClose();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(HomeController.new);
}