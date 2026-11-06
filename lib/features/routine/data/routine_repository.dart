import 'dart:async';
import 'dart:convert';

import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/features/routine/data/models/routine_item.dart';
import 'package:ajyal/features/sharing/data/share_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// الروتين يُحفظ محلياً للعمل بدون إنترنت، ويُرفع إلى `routines/{childId}`،
/// ثم يُنسخ إلى `child_public/{childId}` ليقرأه تطبيق الطفل.
class RoutineRepository {
  RoutineRepository({required StorageService storage})
      : _storage = storage,
        _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  static const String routinesCollection = 'routines';

  static const List<RoutineItem> defaultItems = [
    RoutineItem(
      id: 'default_wake',
      title: 'routine_wake',
      time: '07:00',
      iconName: 'sun',
    ),
    RoutineItem(
      id: 'default_wash',
      title: 'routine_wash',
      time: '07:20',
      iconName: 'water',
    ),
    RoutineItem(
      id: 'default_teeth',
      title: 'routine_teeth',
      time: '07:30',
      iconName: 'clean',
    ),
    RoutineItem(
      id: 'default_breakfast',
      title: 'routine_breakfast',
      time: '07:50',
      iconName: 'food',
    ),
    RoutineItem(
      id: 'default_leave',
      title: 'routine_leave',
      time: '08:10',
      iconName: 'walk',
    ),
  ];

  final StorageService _storage;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final ShareRepository _share = ShareRepository();

  /// القراءة المحلية الفورية.
  List<RoutineItem> getRoutine(String childId) {
    final raw = _storage.read<String>(StorageKeys.routine(childId));
    if (raw == null) return List<RoutineItem>.of(defaultItems);
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('RoutineRepository.getRoutine failed: $e\n$stack');
      return List<RoutineItem>.of(defaultItems);
    }
  }

  /// يجلب الروتين من Firestore ويحدّث النسخة المحلية.
  /// عند انقطاع الإنترنت يعيد النسخة المحلية.
  Future<List<RoutineItem>> fetchFromServer(String childId) async {
    try {
      final snap =
          await _db.collection(routinesCollection).doc(childId).get();
      final data = snap.data();
      if (data == null) return getRoutine(childId);

      final items = (data['items'] as List<dynamic>? ?? const [])
          .map((e) =>
              RoutineItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      await _writeLocal(childId, items);
      return items;
    } catch (e) {
      debugPrint('RoutineRepository.fetchFromServer failed: $e');
      return getRoutine(childId);
    }
  }

  /// يحفظ محلياً فوراً، ثم يرفع إلى Firestore ويحدّث child_public بعد نجاح الرفع.
  Future<void> saveRoutine(String childId, List<RoutineItem> items) async {
    await _writeLocal(childId, items);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    unawaited(
      _db.collection(routinesCollection).doc(childId).set({
        'parentId': uid,
        'childId': childId,
        'items': items.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).then<void>(
        (_) => _share.refreshContent(childId),
        onError: (Object e) => debugPrint('Routine save postponed: $e'),
      ),
    );
  }

  Future<void> _writeLocal(String childId, List<RoutineItem> items) =>
      _storage.write(
        StorageKeys.routine(childId),
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
}