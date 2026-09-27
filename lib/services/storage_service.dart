import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:artisan_market/services/auth_service.dart';

class StorageService {
  final FirebaseStorage? _storage = AuthService.isFirebaseReady ? FirebaseStorage.instance : null;

  /// Uploads an image as bytes (for Flutter Web) to Firebase Storage
  /// and returns the public download URL.
  Future<String> uploadProductImage({
    required String productId, 
    required Uint8List imageBytes, 
    required String mimeType,
  }) async {
    if (!AuthService.isFirebaseReady) {
      // If Firebase isn't set up yet, return a mock high-res image
      await Future.delayed(const Duration(seconds: 2)); // Simulate network
      return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?q=80&w=800'; 
    }

    try {
      // Extract extension from mimeType (e.g. 'image/jpeg' -> 'jpeg')
      final extension = mimeType.split('/').last;
      final fileName = 'product_$productId.$extension';
      
      final ref = _storage!.ref().child('products').child(fileName);
      
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: mimeType),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
