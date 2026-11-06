import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// النسخة العامة التي يقرأها تطبيق الطفل بمعرّف الطفل مباشرة، دون تسجيل دخول.
class ShareRepository {
  ShareRepository()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  static const String publicCollection = 'child_public';
  static const String routinesCollection = 'routines';

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _doc(String childId) =>
      _db.collection(publicCollection).doc(childId);

  String? get _uid => _auth.currentUser?.uid;

  /// يحفظ الاسم والمرحلة، ولا يلمس البطاقات أو حالة المشاركة.
  Future<void> publishProfile({
    required String childId,
    required String name,
    required int level,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _doc(childId).set({
        'parentId': uid,
        'name': name,
        'level': level,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ShareRepository.publishProfile failed: $e');
    }
  }

  /// تفعيل المشاركة أو إلغاؤها. عند الإلغاء تُفرَّغ البطاقات والقصص والروتين.
  Future<void> setShared(String childId, bool shared) async {
    final uid = _uid;
    if (uid == null) return;
    await _doc(childId).set({
      'parentId': uid,
      'shared': shared,
      if (!shared) 'cards': <Map<String, dynamic>>[],
      if (!shared) 'videos': <Map<String, dynamic>>[],
      if (!shared) 'routine': <Map<String, dynamic>>[],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (shared) await refreshContent(childId);
  }

  /// ينسخ البطاقات والقصص والروتين إلى النسخة العامة، إذا كانت المشاركة مفعّلة.
  Future<void> refreshContent(String childId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final current = await _doc(childId).get();
      if (current.data()?['shared'] != true) return;

      final cardSnap = await _db
          .collection('cards')
          .where('parentId', isEqualTo: uid)
          .where('childId', isEqualTo: childId)
          .get();
      final videoSnap = await _db
          .collection('videos')
          .where('parentId', isEqualTo: uid)
          .where('childId', isEqualTo: childId)
          .get();

      final cards = cardSnap.docs.map((d) {
        final data = d.data();
        return {
          'label': data['label'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'audioUrl': data['audioUrl'] ?? '',
          'createdAt': _millis(data['createdAt']),
        };
      }).toList();

      final videos = videoSnap.docs.map((d) {
        final data = d.data();
        return {
          'title': data['title'] ?? '',
          'videoId': data['videoId'] ?? '',
          'youtubeUrl': data['youtubeUrl'] ?? '',
          'createdAt': _millis(data['createdAt']),
        };
      }).toList();

      final routine = await _buildRoutine(childId);

      await _doc(childId).set({
        'parentId': uid,
        'cards': cards,
        'videos': videos,
        'routine': routine,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ShareRepository.refreshContent failed: $e');
    }
  }

  /// يحوّل الروتين إلى صيغة مبسطة لتطبيق الطفل، مع ترجمة أسماء المهام الافتراضية.
  Future<List<Map<String, dynamic>>> _buildRoutine(String childId) async {
    final snap =
        await _db.collection(routinesCollection).doc(childId).get();
    final raw = snap.data()?['items'] as List<dynamic>? ?? const [];

    final list = raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return <String, dynamic>{
        'id': m['id'] ?? '',
        'label': (m['title'] as String? ?? '').tr,
        'time': m['time'] ?? '',
        'iconName': m['iconName'] ?? 'task',
        'enabled': m['enabled'] ?? true,
      };
    }).toList();

    list.sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
    return list;
  }

  int _millis(Object? value) =>
      value is Timestamp ? value.millisecondsSinceEpoch : 0;
}