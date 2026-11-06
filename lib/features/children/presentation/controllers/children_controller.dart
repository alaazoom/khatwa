import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:get/get.dart';

class ChildrenController extends GetxController {
  final ChildRepository _children = Get.find<ChildRepository>();
  final AuthRepository _auth = Get.find<AuthRepository>();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();

  /// كل أطفال ولي الأمر الحالي.
  final children = <ChildProfile>[].obs;
  final activeChildId = RxnString();

  String get userName => _auth.currentUser?.name ?? '';

  String get userEmail => _auth.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    try {
      final list = _children.getChildren();
      children.assignAll(list);
      activeChildId.value = _children.activeChildId;
      status.value = list.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
      status.value = ViewStatus.error;
    }
  }

  Future<void> refresh() async {
    await _children.syncPending();
    load();
  }

  /// يفتح إعداد طفل جديد، ويُضاف إلى نفس ولي الأمر.
  Future<void> openSetup() async {
    await Get.toNamed(AppRoutes.childSetup);
    load();
  }

  /// يفتح إعداد الطفل المحدد للتعديل.
  Future<void> editChild(ChildProfile profile) async {
    await Get.toNamed(AppRoutes.childSetup, parameters: {'id': profile.id});
    load();
  }

  /// يجعل الطفل نشطاً ويفتح الرئيسية بملفه.
  Future<void> selectChild(ChildProfile profile) async {
    await _children.setActiveChild(profile.id);
    activeChildId.value = profile.id;
    Get.offAllNamed(AppRoutes.home);
  }

  void goHome() => Get.offAllNamed(AppRoutes.home);

  Future<void> logout() async {
    if (Get.isBottomSheetOpen == true) Get.back();
    await _auth.logout();
    await _children.clearLocal();
    Get.offAllNamed(AppRoutes.login);
  }
}

class ChildrenBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(ChildrenController.new);
}