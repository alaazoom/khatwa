import 'dart:async';
import 'dart:convert';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/sharing/data/share_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// الأطفال يُحفظون في Firestore ضمن مجموعة `children`،
/// ويُحتفظ بنسخة محلية للعمل بدون اتصال وللتحقق السريع عند فتح التطبيق.
class ChildRepository {
  ChildRepository({required StorageService storage})
      : _storage = storage,
        _auth = FirebaseAuth.instance,
        _db = FirebaseFirestore.instance;

  static const String childrenCollection = 'children';

  final StorageService _storage;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
    final ShareRepository _share = ShareRepository();

  CollectionReference<Map<String, dynamic>> get _childrenRef =>
      _db.collection(childrenCollection);

  String? get _uid => _auth.currentUser?.uid;

  // ---------- النسخة المحلية ----------

  List<ChildProfile> getChildren() {
    final raw = _storage.read<String>(StorageKeys.children);
    if (raw == null) return <ChildProfile>[];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('ChildRepository.getChildren failed: $e\n$stack');
      return <ChildProfile>[];
    }
  }

  ChildProfile? getChild(String id) {
    for (final child in getChildren()) {
      if (child.id == id) return child;
    }
    return null;
  }

  /// الطفل النشط الذي تعرض الرئيسية بياناته. يعود للأول إن لم يُحدَّد.
  ChildProfile? getProfile() {
    final children = getChildren();
    if (children.isEmpty) return null;
    final active = activeChildId;
    for (final child in children) {
      if (child.id == active) return child;
    }
    return children.first;
  }

  String? get activeChildId => _storage.read<String>(StorageKeys.activeChildId);

  Future<void> setActiveChild(String id) =>
      _storage.write(StorageKeys.activeChildId, id);

  Future<void> _writeAll(List<ChildProfile> children) => _storage.write(
        StorageKeys.children,
        jsonEncode(children.map((c) => c.toJson()).toList()),
      );

  // ---------- Firestore ----------

  /// يجلب أطفال ولي الأمر الحالي من Firestore ويحدّث النسخة المحلية.
  /// يعيد true إذا كان لدى ولي الأمر طفل واحد على الأقل.
  Future<bool> refreshFromServer() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final snapshot =
          await _childrenRef.where('parentId', isEqualTo: uid).get();
      final children = snapshot.docs
          .map((doc) => ChildProfile.fromJson({
                ...doc.data(),
                'id': doc.id,
                'pendingSync': doc.metadata.hasPendingWrites,
              }))
          .toList();
      await _writeAll(children);
      return children.isNotEmpty;
    } catch (e) {
      // بدون اتصال: نعتمد على النسخة المحلية.
      debugPrint('ChildRepository.refreshFromServer failed: $e');
      return getChildren().isNotEmpty;
    }
  }

  /// للتوافق مع الشاشات التي تستدعي هذه الدالة عند السحب للتحديث أو عند عودة الاتصال.
  Future<void> syncPending() async {
    await refreshFromServer();
  }

  /// يحفظ الطفل محلياً فوراً، ثم يرسله إلى Firestore.
  /// إن كان الجهاز بدون اتصال، يبقى الطفل بحالة "بانتظار المزامنة" حتى يصل الإرسال.
  Future<void> saveProfile(ChildProfile profile) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppException(AppErrorType.unauthorized, 'err_unauthorized');
    }

    final children = getChildren();
    final index = children.indexWhere((c) => c.id == profile.id);
    final isNew = index == -1;
    final pending = profile.copyWith(pendingSync: true);
    if (isNew) {
      children.add(pending);
    } else {
      children[index] = pending;
    }
    await _writeAll(children);
    if (isNew || activeChildId == null) {
      await setActiveChild(profile.id);
    }

    final data = profile.toJson()
      ..remove('pendingSync')
      ..['parentId'] = uid
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (isNew) data['createdAt'] = FieldValue.serverTimestamp();

    unawaited(
      _childrenRef
          .doc(profile.id)
          .set(data, SetOptions(merge: true))
          .then<void>(
            (_) => _markSynced(profile.id),
            onError: (Object e) => debugPrint('Child save postponed: $e'),
          ),
    );
        unawaited(_share.publishProfile(
      childId: profile.id,
      name: profile.name,
      level: profile.level,
    ));
  }

  Future<void> _markSynced(String id) async {
    final children = getChildren();
    final index = children.indexWhere((c) => c.id == id);
    if (index == -1) return;
    children[index] = children[index].copyWith(pendingSync: false);
    await _writeAll(children);
  }

  Future<void> clearLocal() async {
    for (final child in getChildren()) {
      await _storage.remove(StorageKeys.cards(child.id));
      await _storage.remove(StorageKeys.routine(child.id));
    }
    await _storage.remove(StorageKeys.children);
    await _storage.remove(StorageKeys.activeChildId);
  }
}