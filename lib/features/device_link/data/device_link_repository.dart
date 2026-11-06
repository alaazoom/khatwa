import 'dart:math';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/device_link/data/models/device_link_models.dart';
import 'package:ajyal/features/sharing/data/share_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceLinkRepository {
  DeviceLinkRepository()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  static const String codesCollection = 'child_codes';
  static const int _maxAttempts = 20;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final ShareRepository _share = ShareRepository();

  CollectionReference<Map<String, dynamic>> get _codes =>
      _db.collection(codesCollection);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AppException(AppErrorType.unauthorized, 'err_unauthorized');
    }
    return uid;
  }

  /// يعيد الكود الحالي للطفل. ينشئ كوداً جديداً فقط إذا لم يوجد، أو عند regenerate.
  Future<PairingCode> getPairingCode(
    String childId, {
    bool regenerate = false,
  }) async {
    final uid = _uid;
    try {
      if (!regenerate) {
        final existing = await _codes
            .where('parentId', isEqualTo: uid)
            .where('childId', isEqualTo: childId)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          return PairingCode(
            code: existing.docs.first.id,
            childId: childId,
          );
        }
      }
      return await _createNewCode(childId, uid);
    } on FirebaseException catch (e) {
      throw _map(e);
    }
  }

  Future<PairingCode> _createNewCode(String childId, String uid) async {
    final random = Random.secure();
    await _share.setShared(childId, true);
    await _deleteOldCodes(childId, uid);

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final code = (100000 + random.nextInt(900000)).toString();
      final ref = _codes.doc(code);
      if ((await ref.get()).exists) continue;

      await ref.set({
        'code': code,
        'childId': childId,
        'parentId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return PairingCode(code: code, childId: childId);
    }
    throw const AppException(AppErrorType.server, 'err_server');
  }

  /// يلغي المشاركة: تُفرَّغ البطاقات والقصص، وتُحذف الأكواد النشطة.
  Future<void> unlinkAll(String childId) async {
    try {
      await _share.setShared(childId, false);
      await _deleteOldCodes(childId, _uid);
    } on FirebaseException catch (e) {
      throw _map(e);
    }
  }

  Future<void> _deleteOldCodes(String childId, String uid) async {
    final old = await _codes
        .where('parentId', isEqualTo: uid)
        .where('childId', isEqualTo: childId)
        .get();
    if (old.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in old.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  AppException _map(FirebaseException e) => switch (e.code) {
        'unavailable' => const AppException(AppErrorType.network, 'err_network'),
        'permission-denied' =>
          const AppException(AppErrorType.unauthorized, 'err_unauthorized'),
        _ => const AppException(AppErrorType.server, 'err_server'),
      };
}