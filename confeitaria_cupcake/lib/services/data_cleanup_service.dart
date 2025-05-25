import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/image_validator.dart';
import '../models/app_models.dart';

/// Service to clean up corrupted data from Firestore
class DataCleanupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Cleans up corrupted profile pictures for the current user
  Future<bool> cleanupCurrentUserProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;
      
      final userData = UserModel.fromMap(userDoc.data()!);
      
      if (userData.fotoPerfil != null) {
        if (ImageValidator.isCorruptedImageData(userData.fotoPerfil!)) {
          // Remove corrupted profile picture
          await _firestore.collection('users').doc(user.uid).update({
            'fotoPerfil': null,
          });
          print('Removed corrupted profile picture for user ${user.uid}');
          return true;
        } else {
          // Try to fix the profile picture
          final fixedImage = ImageValidator.validateAndFixBase64Image(userData.fotoPerfil!);
          if (fixedImage != null && fixedImage != userData.fotoPerfil!) {
            await _firestore.collection('users').doc(user.uid).update({
              'fotoPerfil': fixedImage,
            });
            print('Fixed profile picture for user ${user.uid}');
            return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      print('Error cleaning up user profile picture: $e');
      return false;
    }
  }
  
  /// Cleans up corrupted cupcake images (admin only)
  Future<int> cleanupCorruptedCupcakeImages() async {
    try {
      int cleanedCount = 0;
      
      final cupcakesSnapshot = await _firestore.collection('cupcakes').get();
      
      for (var doc in cupcakesSnapshot.docs) {
        try {
          final data = doc.data();
          final imageUrl = data['imagem'] as String?;
          
          if (imageUrl != null && ImageValidator.isCorruptedImageData(imageUrl)) {
            // For corrupted cupcake images, we'll use a placeholder from image_util
            print('Found corrupted cupcake image: ${doc.id}');
            cleanedCount++;
            
            // You could update with a placeholder or remove the corrupted data
            // For now, we'll just log it
          }
        } catch (e) {
          print('Error processing cupcake ${doc.id}: $e');
        }
      }
      
      return cleanedCount;
    } catch (e) {
      print('Error cleaning up cupcake images: $e');
      return 0;
    }
  }
  
  /// General method to scan and report corruption statistics
  Future<Map<String, int>> scanForCorruption() async {
    final stats = <String, int>{
      'corrupted_user_profiles': 0,
      'corrupted_cupcake_images': 0,
      'total_users_scanned': 0,
      'total_cupcakes_scanned': 0,
    };
    
    try {
      // Scan user profiles
      final usersSnapshot = await _firestore.collection('users').get();
      stats['total_users_scanned'] = usersSnapshot.docs.length;
      
      for (var doc in usersSnapshot.docs) {
        try {
          final data = doc.data();
          final imageUrl = data['fotoPerfil'] as String?;
          
          if (imageUrl != null && ImageValidator.isCorruptedImageData(imageUrl)) {
            stats['corrupted_user_profiles'] = stats['corrupted_user_profiles']! + 1;
          }
        } catch (e) {
          // Count parsing errors as corruption
          stats['corrupted_user_profiles'] = stats['corrupted_user_profiles']! + 1;
        }
      }
      
      // Scan cupcake images
      final cupcakesSnapshot = await _firestore.collection('cupcakes').get();
      stats['total_cupcakes_scanned'] = cupcakesSnapshot.docs.length;
      
      for (var doc in cupcakesSnapshot.docs) {
        try {
          final data = doc.data();
          final imageUrl = data['imagem'] as String?;
          
          if (imageUrl != null && ImageValidator.isCorruptedImageData(imageUrl)) {
            stats['corrupted_cupcake_images'] = stats['corrupted_cupcake_images']! + 1;
          }
        } catch (e) {
          // Count parsing errors as corruption
          stats['corrupted_cupcake_images'] = stats['corrupted_cupcake_images']! + 1;
        }
      }
      
    } catch (e) {
      print('Error scanning for corruption: $e');
    }
    
    return stats;
  }
  
  /// Validates a single document's image data
  Future<bool> validateDocumentImageData(String collection, String docId, String imageField) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final imageUrl = data[imageField] as String?;
      
      if (imageUrl == null) return true; // No image is valid
      
      return !ImageValidator.isCorruptedImageData(imageUrl);
    } catch (e) {
      print('Error validating document $collection/$docId: $e');
      return false;
    }
  }
  
  /// Attempts to fix a specific document's image data
  Future<bool> fixDocumentImageData(String collection, String docId, String imageField) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final imageUrl = data[imageField] as String?;
      
      if (imageUrl == null) return true; // No image to fix
      
      if (ImageValidator.isCorruptedImageData(imageUrl)) {
        // Try to fix the image
        final fixedImage = ImageValidator.validateAndFixBase64Image(imageUrl);
        
        if (fixedImage != null && fixedImage != imageUrl) {
          await _firestore.collection(collection).doc(docId).update({
            imageField: fixedImage,
          });
          print('Fixed image data for $collection/$docId');
          return true;
        } else {
          // Remove corrupted image
          await _firestore.collection(collection).doc(docId).update({
            imageField: null,
          });
          print('Removed corrupted image data for $collection/$docId');
          return true;
        }
      }
      
      return true; // Already valid
    } catch (e) {
      print('Error fixing document $collection/$docId: $e');
      return false;
    }
  }
}