// lib/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() {
    return _instance;
  }
  AuthController._internal() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final _auth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  app_user.User? _currentUser;
  app_user.User? get currentUser => _currentUser;

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final newUser = app_user.User(
          id: firebaseUser.uid,
          name: name,
          email: email,
        );
        await _usersCollection.doc(newUser.id).set(newUser.toJson());

        _currentUser = newUser;
        notifyListeners();
        return null;
      }
      return 'Erro ao criar usuário.';
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        _currentUser = await _loadUserFromFirestore(firebaseUser.uid);
        notifyListeners();
        return null;
      }
      return 'Erro ao fazer login.';
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<app_user.User?> _loadUserFromFirestore(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      _currentUser = await _loadUserFromFirestore(firebaseUser.uid);
    }
    notifyListeners();
  }

  Future<app_user.User?> getUserById(String userId) async {
    return await _loadUserFromFirestore(userId);
  }
}