import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajyal/core/config/app_config.dart';
import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/communication/data/models/communication_card.dart';
import 'package:ajyal/features/communication/data/models/story_item.dart';
import 'package:ajyal/features/sharing/data/share_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// نتيجة رفع ملف إلى Cloudinary.
class _UploadResult {
  const _UploadResult({required this.url, required this.publicId});

  final String url;
  final String publicId;
}

/// الصور والأصوات تُرفع إلى Cloudinary، والبيانات تبقى في Firestore.
class ContentRepository {
  ContentRepository()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  static const String cardsCollection = 'cards';
  static const String videosCollection = 'videos';

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final ShareRepository _share = ShareRepository();

  CollectionReference<Map<String, dynamic>> get _cards =>
      _db.collection(cardsCollection);

  CollectionReference<Map<String, dynamic>> get _videos =>
      _db.collection(videosCollection);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AppException(AppErrorType.unauthorized, 'err_unauthorized');
    }
    return uid;
  }

  // ---------- البطاقات ----------

  Stream<List<CommunicationCard>> watchCards(String childId) {
    return _cards
        .where('parentId', isEqualTo: _uid)
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(CommunicationCard.fromDoc).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// يرفع الصورة والصوت إلى Cloudinary ثم يحفظ البيانات في مجموعة `cards`.
  /// ملاحظة: حقلا imagePath وaudioPath في البطاقة يحملان الآن معرّف Cloudinary (public_id).
  Future<void> saveCard({
    required String childId,
    CommunicationCard? existing,
    required String label,
    String? imageFilePath,
    String? audioFilePath,
  }) async {
    final uid = _uid;
    final id = existing?.id ?? _cards.doc().id;
    var imageUrl = existing?.imageUrl ?? '';
    var imagePublicId = existing?.imagePath ?? '';
    var audioUrl = existing?.audioUrl ?? '';
    var audioPublicId = existing?.audioPath ?? '';

    if (imageFilePath != null) {
      final result = await _upload(
        localPath: imageFilePath,
        uid: uid,
        resourceType: 'image',
      );
      imageUrl = result.url;
      imagePublicId = result.publicId;
    }

    if (audioFilePath != null) {
      // الصوت يُرفع عبر نقطة نهاية الفيديو في Cloudinary لأنها تدعم الملفات الصوتية.
      final result = await _upload(
        localPath: audioFilePath,
        uid: uid,
        resourceType: 'video',
      );
      audioUrl = result.url;
      audioPublicId = result.publicId;
    }

    try {
      await _cards.doc(id).set(
        {
          'parentId': uid,
          'childId': childId,
          'label': label,
          'imageUrl': imageUrl,
          'imagePath': imagePublicId,
          'audioUrl': audioUrl,
          'audioPath': audioPublicId,
          'updatedAt': FieldValue.serverTimestamp(),
          if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      unawaited(_share.refreshContent(childId));
    } on FirebaseException catch (e) {
      throw _mapFirebase(e);
    }
  }

  /// يحذف بيانات البطاقة من Firestore فقط.
  /// لا يحذف الملفات من Cloudinary، لأن الحذف يتطلب مفتاحاً سرياً لا يُوضع داخل التطبيق.
  Future<void> deleteCard(CommunicationCard card) async {
    try {
      await _cards.doc(card.id).delete();
      unawaited(_share.refreshContent(card.childId));
    } on FirebaseException catch (e) {
      throw _mapFirebase(e);
    }
  }

  Future<_UploadResult> _upload({
    required String localPath,
    required String uid,
    required String resourceType,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/$resourceType/upload',
    );
    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
        ..fields['folder'] = 'ajyal/$uid'
        ..files.add(await http.MultipartFile.fromPath('file', localPath));

      final streamed = await request.send().timeout(AppConfig.uploadTimeout);
      final body = await streamed.stream.bytesToString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final url = json['secure_url'];
      final publicId = json['public_id'];

      if (streamed.statusCode != 200 || url is! String || publicId is! String) {
        debugPrint('Cloudinary upload failed (${streamed.statusCode}): $body');
        throw const AppException(AppErrorType.server, 'err_upload_failed');
      }
      return _UploadResult(url: url, publicId: publicId);
    } on SocketException {
      throw const AppException(AppErrorType.network, 'err_network');
    } on http.ClientException {
      throw const AppException(AppErrorType.network, 'err_network');
    } on TimeoutException {
      throw const AppException(AppErrorType.timeout, 'err_timeout');
    } on FormatException {
      throw const AppException(AppErrorType.server, 'err_upload_failed');
    } on FileSystemException catch (e) {
      debugPrint('Local file error: $e');
      throw const AppException(AppErrorType.validation, 'err_upload_failed');
    } catch (e, stack) {
      if (e is AppException) rethrow;
      debugPrint('Upload error: $e\n$stack');
      throw const AppException(AppErrorType.server, 'err_upload_failed');
    }
  }

  // ---------- القصص ----------

  Stream<List<StoryItem>> watchStories(String childId) {
    return _videos
        .where('parentId', isEqualTo: _uid)
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(StoryItem.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> saveStory({
    required String childId,
    required String title,
    required String youtubeUrl,
  }) async {
    final uid = _uid;
    final videoId = StoryItem.extractYoutubeId(youtubeUrl);
    if (videoId == null) {
      throw const AppException(AppErrorType.validation, 'err_invalid_youtube');
    }
    try {
      await _videos.doc().set({
        'parentId': uid,
        'childId': childId,
        'title': title,
        'youtubeUrl': youtubeUrl.trim(),
        'videoId': videoId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      unawaited(_share.refreshContent(childId));
    } on FirebaseException catch (e) {
      throw _mapFirebase(e);
    }
  }

  Future<void> deleteStory(String id) async {
    try {
      final doc = await _videos.doc(id).get();
      final childId = doc.data()?['childId'] as String?;
      await _videos.doc(id).delete();
      if (childId != null) unawaited(_share.refreshContent(childId));
    } on FirebaseException catch (e) {
      throw _mapFirebase(e);
    }
  }

  AppException _mapFirebase(FirebaseException e) => switch (e.code) {
        'unavailable' || 'network-request-failed' =>
          const AppException(AppErrorType.network, 'err_network'),
        'permission-denied' || 'unauthenticated' || 'unauthorized' =>
          const AppException(AppErrorType.unauthorized, 'err_unauthorized'),
        _ => const AppException(AppErrorType.server, 'err_server'),
      };
}