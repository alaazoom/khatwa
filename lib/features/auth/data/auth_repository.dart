import 'dart:convert';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository({required StorageService storage})
      : _storage = storage,
        _auth = FirebaseAuth.instance,
        _db = FirebaseFirestore.instance;

  /// اسم المجموعة في Firestore التي تحفظ بيانات ولي الأمر.
  static const String parentsCollection = 'parents_accounts';

  final StorageService _storage;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  bool get isLoggedIn => _storage.read<bool>(StorageKeys.isLoggedIn) ?? false;

  UserModel? get currentUser {
    final raw = _storage.read<String>(StorageKeys.user);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// رمز الجلسة الحالي من Firebase، ويتجدد تلقائياً.
  Future<String?> accessToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    User? created;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      created = credential.user!;
      await created.updateDisplayName(name);

      final user = UserModel(id: created.uid, name: name, email: email);
      await _db.collection(parentsCollection).doc(user.id).set({
        'uid': user.id,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _saveSession(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on FirebaseException catch (e) {
      // فشل الحفظ في Firestore: نحذف الحساب حتى يتمكن المستخدم من المحاولة مجدداً بنفس البريد.
      await _rollback(created);
      throw _mapFirestoreError(e);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _loadParentAccount(credential.user!);
      await _saveSession(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AppException(AppErrorType.unauthorized, 'err_unauthorized');
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AppException(AppErrorType.validation, 'err_wrong_password');
      }
      throw _mapAuthError(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _storage.remove(StorageKeys.user);
    await _storage.write(StorageKeys.isLoggedIn, false);
  }

  /// يقرأ بيانات ولي الأمر من Firestore، وإن تعذّر ذلك يستخدم بيانات Firebase Auth.
  Future<UserModel> _loadParentAccount(User firebaseUser) async {
    try {
      final snapshot = await _db
          .collection(parentsCollection)
          .doc(firebaseUser.uid)
          .get();
      final data = snapshot.data();
      if (data != null && data['name'] is String) {
        return UserModel(
          id: firebaseUser.uid,
          name: data['name'] as String,
          email: firebaseUser.email ?? '',
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('AuthRepository._loadParentAccount failed: $e');
    }
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
    );
  }

  Future<void> _saveSession(UserModel user) async {
    await _storage.write(StorageKeys.user, jsonEncode(user.toJson()));
    await _storage.write(StorageKeys.isLoggedIn, true);
  }

  Future<void> _rollback(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (e) {
      debugPrint('AuthRepository rollback failed: $e');
    }
  }

  AppException _mapAuthError(FirebaseAuthException e) => switch (e.code) {
        'email-already-in-use' =>
          const AppException(AppErrorType.validation, 'err_email_in_use'),
        'invalid-email' =>
          const AppException(AppErrorType.validation, 'email_invalid'),
        'weak-password' =>
          const AppException(AppErrorType.validation, 'err_weak_password'),
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' ||
        'invalid-login-credentials' =>
          const AppException(AppErrorType.unauthorized, 'err_invalid_credentials'),
        'user-disabled' =>
          const AppException(AppErrorType.unauthorized, 'err_user_disabled'),
        'too-many-requests' =>
          const AppException(AppErrorType.server, 'err_too_many_requests'),
        'network-request-failed' =>
          const AppException(AppErrorType.network, 'err_network'),
        _ => const AppException(AppErrorType.server, 'err_server'),
      };

  AppException _mapFirestoreError(FirebaseException e) =>
      e.code == 'unavailable'
          ? const AppException(AppErrorType.network, 'err_network')
          : const AppException(AppErrorType.server, 'err_server');
}