import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/device_link/data/device_link_repository.dart';
import 'package:ajyal/features/device_link/data/models/device_link_models.dart';
import 'package:get/get.dart';

class DeviceLinkController extends GetxController {
  final DeviceLinkRepository _repo = Get.find<DeviceLinkRepository>();
  final ChildRepository _children = Get.find<ChildRepository>();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();
  final child = Rxn<ChildProfile>();
  final pairing = Rxn<PairingCode>();
  final isShared = false.obs;
  final isBusy = false.obs;

  String? _childId;

  @override
  void onInit() {
    super.onInit();
    _childId = Get.parameters['id'];
    load();
  }

  Future<void> load() async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    final id = _childId;
    final profile = id == null ? null : _children.getChild(id);
    child.value = profile;
    if (profile == null) {
      status.value = ViewStatus.empty;
      return;
    }
    status.value = ViewStatus.success;
    await _fetchCode(regenerate: false);
  }

  /// يُستدعى من زر "إنشاء رمز جديد" فقط.
  Future<void> refreshCode() => _fetchCode(regenerate: true);

  Future<void> _fetchCode({required bool regenerate}) async {
    final profile = child.value;
    if (profile == null) return;
    isBusy.value = true;
    try {
      pairing.value = await _repo.getPairingCode(
        profile.id,
        regenerate: regenerate,
      );
      isShared.value = true;
    } catch (e) {
      pairing.value = null;
      _showError(e);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> unlinkAll() async {
    final profile = child.value;
    if (profile == null) return;
    isBusy.value = true;
    try {
      await _repo.unlinkAll(profile.id);
      isShared.value = false;
      pairing.value = null;
    } catch (e) {
      _showError(e);
    } finally {
      isBusy.value = false;
    }
  }

  void _showError(Object error) => Get.snackbar(
        'app_name'.tr,
        resolveErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
}

class DeviceLinkBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(DeviceLinkController.new);
}