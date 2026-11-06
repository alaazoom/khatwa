import 'dart:convert';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/network/api_client.dart';
import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/reports/data/models/child_report.dart';
import 'package:flutter/foundation.dart';

class ReportRepository {
  ReportRepository({
    required ApiClient api,
    required StorageService storage,
    required AuthRepository auth,
  })  : _api = api,
        _storage = storage,
        _auth = auth;

  final ApiClient _api;
  final StorageService _storage;
  final AuthRepository _auth;

Future<ChildReport> fetchReport(String childId) async {
  return const ChildReport(
    independentAreas: 0,
    cardsInUse: 0,
    routineCompletion: 0,
    progress: [],
    notes: [],
  );
}
  ChildReport? getCachedReport(String childId) {
    final raw = _storage.read<String>(StorageKeys.report(childId));
    if (raw == null) return null;
    try {
      return ChildReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, stack) {
      debugPrint('ReportRepository.getCachedReport failed: $e\n$stack');
      return null;
    }
  }
}