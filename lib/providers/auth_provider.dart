import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ashop/utils/constants.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _error;
  Map<String, dynamic>? _userData;
  String _currentLanguage = 'fr'; // Default to French

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  String get currentLanguage => _currentLanguage;
  bool get isAdmin => _userData?['isAdmin'] ?? false;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _userData = null;
    } else {
      _user = firebaseUser;
      await _loadUserData();
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        _currentLanguage = _userData?['preferredLanguage'] ?? 'fr';
      }
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _error = null;
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      await _loadUserData();
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['invalid_credentials'];
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password, String name) async {
    try {
      _error = null;
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      // Create user document in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'preferredLanguage': _currentLanguage,
        'subscriptionPlan': 'basic',
        'subscriptionStatus': 'active',
      });

      await _loadUserData();
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          _error = Constants.errorMessages[_currentLanguage]!['email_in_use'];
        } else if (e.code == 'weak-password') {
          _error = Constants.errorMessages[_currentLanguage]!['weak_password'];
        } else {
          _error = Constants.errorMessages[_currentLanguage]!['network_error'];
        }
      }
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({String? name, String? language}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (language != null) {
        updates['preferredLanguage'] = language;
        _currentLanguage = language;
      }

      await _firestore.collection('users').doc(_user!.uid).update(updates);
      await _loadUserData();
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      notifyListeners();
      return false;
    }
  }

  // Update subscription plan
  Future<bool> updateSubscription(String plan) async {
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'subscriptionPlan': plan,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      });
      await _loadUserData();
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      notifyListeners();
      return false;
    }
  }

  // Change language
  void setLanguage(String language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      if (_user != null) {
        updateProfile(language: language);
      }
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
