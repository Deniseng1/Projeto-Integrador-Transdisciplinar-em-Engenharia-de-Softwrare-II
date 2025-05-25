import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Utility class for validating and fixing corrupted image data
class ImageValidator {
  
  /// Validates and attempts to fix corrupted base64 image strings
  static String? validateAndFixBase64Image(String? imageData) {
    if (imageData == null || imageData.trim().isEmpty) {
      return null;
    }
    
    try {
      // Remove whitespace and normalize
      String normalized = imageData.trim();
      
      // Check for common corruption patterns and fix them
      normalized = _fixCommonCorruptions(normalized);
      
      // Validate the format
      if (!_isValidBase64ImageFormat(normalized)) {
        return null;
      }
      
      // Test if we can actually decode it
      if (!_canDecodeBase64(normalized)) {
        return null;
      }
      
      return normalized;
    } catch (e) {
      print('Error validating image data: $e');
      return null;
    }
  }
  
  /// Attempts to fix common corruption patterns in base64 image strings
  static String _fixCommonCorruptions(String imageData) {
    String fixed = imageData;
    
    // Fix missing colon in data URI
    if (fixed.startsWith('dataimage/')) {
      fixed = fixed.replaceFirst('dataimage/', 'data:image/');
    }
    
    // Fix missing semicolon before base64
    if (fixed.contains(':base64,') == false && fixed.contains('base64,')) {
      fixed = fixed.replaceFirst('base64,', ';base64,');
    }
    
    // Fix missing comma after base64
    if (fixed.contains(';base64') && !fixed.contains(';base64,')) {
      fixed = fixed.replaceFirst(';base64', ';base64,');
    }
    
    // Remove invalid characters from the beginning
    final validStartPatterns = ['data:image/', 'http://', 'https://'];
    bool hasValidStart = validStartPatterns.any((pattern) => fixed.startsWith(pattern));
    
    if (!hasValidStart) {
      // Try to find and extract valid base64 data
      final base64Match = RegExp(r'([A-Za-z0-9+/]{20,}={0,2})').firstMatch(fixed);
      if (base64Match != null) {
        fixed = 'data:image/jpeg;base64,${base64Match.group(1)}';
      }
    }
    
    return fixed;
  }
  
  /// Validates that the image data has the correct base64 format
  static bool _isValidBase64ImageFormat(String imageData) {
    if (imageData.isEmpty) return false;
    
    // Must start with data:image/ for base64 images
    if (imageData.startsWith('data:image/')) {
      // Must contain ;base64,
      if (!imageData.contains(';base64,')) {
        return false;
      }
      
      // Extract the base64 part
      final parts = imageData.split(';base64,');
      if (parts.length != 2) {
        return false;
      }
      
      final base64Part = parts[1];
      return _isValidBase64String(base64Part);
    }
    
    // For network URLs
    if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
      try {
        final uri = Uri.parse(imageData);
        return uri.hasScheme && uri.hasAuthority;
      } catch (e) {
        return false;
      }
    }
    
    return false;
  }
  
  /// Validates that a string is valid base64
  static bool _isValidBase64String(String str) {
    if (str.isEmpty) return false;
    
    // Base64 should only contain valid characters
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64Pattern.hasMatch(str)) {
      return false;
    }
    
    // Length should be multiple of 4 (with padding)
    if (str.length % 4 != 0) {
      return false;
    }
    
    return true;
  }
  
  /// Tests if the base64 data can actually be decoded
  static bool _canDecodeBase64(String imageData) {
    try {
      if (imageData.startsWith('data:image/')) {
        final base64Part = imageData.split(';base64,')[1];
        final decoded = base64Decode(base64Part);
        return decoded.isNotEmpty && decoded.length > 10; // Minimum reasonable image size
      }
      return true; // For URLs, assume they're valid if format is correct
    } catch (e) {
      return false;
    }
  }
  
  /// Safely decodes base64 image data
  static Uint8List? safeDecodeBase64Image(String imageData) {
    try {
      final validImage = validateAndFixBase64Image(imageData);
      if (validImage == null) return null;
      
      if (validImage.startsWith('data:image/')) {
        final base64Part = validImage.split(';base64,')[1];
        return base64Decode(base64Part);
      }
      
      return null;
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }
  
  /// Checks if an image URL or data is corrupted
  static bool isCorruptedImageData(String? imageData) {
    if (imageData == null || imageData.trim().isEmpty) {
      return true;
    }
    
    // Check for known corruption patterns
    final corruptionPatterns = [
      'MoblloHloader',
      'tatfreeotion:',
      'dataimage/', // Missing colon
      '@hara',
      'مرeg:',
      'basob',
      'اله',
      'AAAGGIZINGABAG',
      'aqHYoUH',
      'OxIUSIUztLd',
      '|', // Pipe characters
      'dota:',
      'magel',
    ];
    
    final lowerCase = imageData.toLowerCase();
    for (String pattern in corruptionPatterns) {
      if (lowerCase.contains(pattern.toLowerCase())) {
        return true;
      }
    }
    
    // Check for invalid characters in what should be base64
    if (imageData.contains(';base64,')) {
      final base64Part = imageData.split(';base64,').last;
      if (!_isValidBase64String(base64Part)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Creates a safe image widget that handles corrupted data
  static Widget buildSafeImage({
    required String? imageData,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Return placeholder immediately if data is corrupted
    if (isCorruptedImageData(imageData)) {
      return errorWidget ?? placeholder ?? _buildDefaultPlaceholder(width, height);
    }
    
    final validImageData = validateAndFixBase64Image(imageData);
    if (validImageData == null) {
      return errorWidget ?? placeholder ?? _buildDefaultPlaceholder(width, height);
    }
    
    try {
      if (validImageData.startsWith('data:image/')) {
        final decodedBytes = safeDecodeBase64Image(validImageData);
        if (decodedBytes != null) {
          return Image.memory(
            decodedBytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? placeholder ?? _buildDefaultPlaceholder(width, height);
            },
          );
        }
      } else if (validImageData.startsWith('http')) {
        return Image.network(
          validImageData,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? placeholder ?? _buildDefaultPlaceholder(width, height);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? _buildDefaultPlaceholder(width, height);
          },
        );
      }
    } catch (e) {
      print('Error building safe image: $e');
    }
    
    return errorWidget ?? placeholder ?? _buildDefaultPlaceholder(width, height);
  }
  
  static Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}