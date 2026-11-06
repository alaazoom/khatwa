import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ChildSetupController extends GetxController {
  final ChildRepository _repo = Get.find<ChildRepository>();

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final communication = Rxn<CommunicationMethod>();
  final sensory = Rx<Set<SensoryPreference>>(<SensoryPreference>{});
  final goals = Rx<Set<DailyGoal>>(<DailyGoal>{});
  final lessonUnit = LessonUnit.communication.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  ChildProfile? _existing;

  @override
  void onInit() {
    super.onInit();
        final id = Get.parameters['id'];
    _existing = id == null ? null : _repo.getChild(id);
    final existing = _existing;
    if (existing == null) return;
    nameCtrl.text = existing.name;
    communication.value = existing.communicationMethod;
    sensory.value = {...existing.sensoryPreferences};
    goals.value = {...existing.goals};
    lessonUnit.value = existing.lessonUnit;
  }

  void selectCommunication(CommunicationMethod method) =>
      communication.value = method;

  void selectUnit(LessonUnit unit) => lessonUnit.value = unit;

  void toggleSensory(SensoryPreference preference) =>
      sensory.value = _toggle(sensory.value, preference);

  void toggleGoal(DailyGoal goal) => goals.value = _toggle(goals.value, goal);

  static Set<T> _toggle<T>(Set<T> source, T item) {
    final next = Set<T>.of(source);
    if (!next.remove(item)) next.add(item);
    return next;
  }

  Future<void> save() async {
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    final method = communication.value;
    if (method == null) {
      errorMessage.value = 'select_comm_required'.tr;
      return;
    }
    if (goals.value.isEmpty) {
      errorMessage.value = 'select_goal_required'.tr;
      return;
    }

    isSaving.value = true;
    try {
      final profile = ChildProfile(
        id: _existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameCtrl.text.trim(),
        communicationMethod: method,
        sensoryPreferences: sensory.value,
        goals: goals.value,
        lessonUnit: lessonUnit.value,
        level: _existing?.level ?? 1,
        progressPercent: _existing?.progressPercent ?? 0,
        communicationFilesCount: _existing?.communicationFilesCount ?? 0,
      );
      await _repo.saveProfile(profile);
      if (Get.key.currentState?.canPop() == true) {
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }
}

class ChildSetupBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(ChildSetupController.new);
}