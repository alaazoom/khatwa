import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/reports/data/models/child_report.dart';
import 'package:ajyal/features/reports/data/report_repository.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController {
  final ReportRepository _repo = Get.find<ReportRepository>();
  final ChildRepository _children = Get.find<ChildRepository>();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();
  final children = <ChildProfile>[].obs;
  final selectedId = RxnString();
  final report = Rxn<ChildReport>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? childId}) async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    final all = _children.getChildren();
    children.assignAll(all);
    if (all.isEmpty) {
      status.value = ViewStatus.empty;
      return;
    }
    final target = childId == null
        ? (_children.getProfile() ?? all.first)
        : all.firstWhere((c) => c.id == childId, orElse: () => all.first);
    selectedId.value = target.id;
    try {
      report.value = await _repo.fetchReport(target.id);
      status.value = ViewStatus.success;
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
      status.value = ViewStatus.error;
    }
  }
}

class ReportsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(ReportsController.new);
}