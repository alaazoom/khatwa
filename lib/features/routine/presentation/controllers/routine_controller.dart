import 'dart:async';
import 'dart:convert';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/routine/data/models/routine_item.dart';
import 'package:ajyal/features/routine/data/routine_repository.dart';
import 'package:get/get.dart';

class RoutineController extends GetxController {
  final RoutineRepository _routine = Get.find<RoutineRepository>();
  final ChildRepository _children = Get.find<ChildRepository>();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();
  final child = Rxn<ChildProfile>();
  final items = <RoutineItem>[].obs;
  final isSaving = false.obs;
  final isDirty = false.obs;

  List<RoutineItem> _saved = <RoutineItem>[];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    try {
      final profile = _children.getProfile();
      child.value = profile;
      if (profile == null) {
        status.value = ViewStatus.empty;
        return;
      }
      _setItems(_routine.getRoutine(profile.id));
      status.value = ViewStatus.success;
      unawaited(_refreshFromServer(profile.id));
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
      status.value = ViewStatus.error;
    }
  }

  Future<void> _refreshFromServer(String childId) async {
    final remote = await _routine.fetchFromServer(childId);
    // لا نكتب فوق تعديلات لم تُحفظ بعد.
    if (isDirty.value) return;
    _setItems(remote);
  }

  void _setItems(List<RoutineItem> list) {
    final sorted = list.toList()..sort((a, b) => a.time.compareTo(b.time));
    items.assignAll(sorted);
    _saved = List<RoutineItem>.of(sorted);
    isDirty.value = false;
  }

  void toggleItem(String id, bool enabled) {
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(enabled: enabled);
    _markDirty();
  }

  void upsertItem(RoutineItem item) {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    _sort();
    _markDirty();
  }

  void removeItem(String id) {
    items.removeWhere((e) => e.id == id);
    _markDirty();
  }

  Future<void> save() async {
    final profile = child.value;
    if (profile == null) return;
    isSaving.value = true;
    try {
      final snapshot = items.toList();
      await _routine.saveRoutine(profile.id, snapshot);
      _saved = snapshot;
      isDirty.value = false;
      Get.snackbar(
        'app_name'.tr,
        'routine_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    } finally {
      isSaving.value = false;
    }
  }

  void _sort() {
    final sorted = items.toList()..sort((a, b) => a.time.compareTo(b.time));
    items.assignAll(sorted);
  }

  void _markDirty() {
    final current = jsonEncode(items.map((e) => e.toJson()).toList());
    final saved = jsonEncode(_saved.map((e) => e.toJson()).toList());
    isDirty.value = current != saved;
  }

  void _showError(Object error) => Get.snackbar(
        'app_name'.tr,
        resolveErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
}

class RoutineBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(RoutineController.new);
}