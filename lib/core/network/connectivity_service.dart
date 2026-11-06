import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    final connectivity = Connectivity();
    isOnline.value = _hasConnection(await connectivity.checkConnectivity());
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _hasConnection(results);
    });
    return this;
  }

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}