import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/constants.dart';

class ShopProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<Map<String, dynamic>> _shops = [];
  Map<String, dynamic>? _currentShop;
  String? _error;
  bool _isLoading = false;
  String _currentLanguage = 'fr';

  // Getters
  List<Map<String, dynamic>> get shops => _shops;
  Map<String, dynamic>? get currentShop => _currentShop;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Set language
  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  // Create new shop
  Future<bool> createShop({
    required String userId,
    required String name,
    required String country,
    required List<String> salesTypes,
    required String description,
    XFile? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate shop name
      if (name.isEmpty || name.length > Constants.maxShopNameLength) {
        _error = Constants.errorMessages[_currentLanguage]!['invalid_shop_name'];
        return false;
      }

      String? imageUrl;
      if (imageFile != null) {
        // Upload image to Firebase Storage
        final file = File(imageFile.path);
        final ref = _storage.ref().child('shops/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await ref.putFile(file);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Create shop document in Firestore
      final shopData = {
        'name': name,
        'ownerId': userId,
        'country': country,
        'salesTypes': salesTypes,
        'description': description,
        'imageUrl': imageUrl,
        'isVerified': false,
        'rating': 0.0,
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      final docRef = await _firestore.collection('shops').add(shopData);
      shopData['id'] = docRef.id;
      _currentShop = shopData;
      _shops.add(shopData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user's shops
  Future<void> loadUserShops(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('shops')
          .where('ownerId', isEqualTo: userId)
          .get();

      _shops = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update shop
  Future<bool> updateShop({
    required String shopId,
    String? name,
    String? description,
    List<String>? salesTypes,
    XFile? newImage,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (salesTypes != null) updates['salesTypes'] = salesTypes;

      if (newImage != null) {
        // Upload new image
        final file = File(newImage.path);
        final ref = _storage.ref().child('shops/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await ref.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        updates['imageUrl'] = imageUrl;
      }

      await _firestore.collection('shops').doc(shopId).update(updates);

      // Update local data
      final index = _shops.indexWhere((shop) => shop['id'] == shopId);
      if (index != -1) {
        _shops[index] = {..._shops[index], ...updates};
        if (_currentShop != null && _currentShop!['id'] == shopId) {
          _currentShop = _shops[index];
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load shop details
  Future<void> loadShopDetails(String shopId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists) {
        _currentShop = doc.data();
        _currentShop!['id'] = doc.id;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search shops
  Future<List<Map<String, dynamic>>> searchShops({
    String? query,
    String? country,
    List<String>? salesTypes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      var ref = _firestore.collection('shops').where('status', isEqualTo: 'active');

      if (country != null) {
        ref = ref.where('country', isEqualTo: country);
      }

      if (salesTypes != null && salesTypes.isNotEmpty) {
        ref = ref.where('salesTypes', arrayContainsAny: salesTypes);
      }

      final snapshot = await ref.get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((shop) {
        if (query == null || query.isEmpty) return true;
        final name = shop['name'].toString().toLowerCase();
        final description = shop['description'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();

      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Delete shop
  Future<bool> deleteShop(String shopId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('shops').doc(shopId).delete();

      _shops.removeWhere((shop) => shop['id'] == shopId);
      if (_currentShop != null && _currentShop!['id'] == shopId) {
        _currentShop = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = Constants.errorMessages[_currentLanguage]!['network_error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
