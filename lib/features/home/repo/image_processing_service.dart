import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

class ImageProcessingService {
  // Compress image with specified quality
  Future<File?> compressImage(File file, int quality) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        // Add more parameters to ensure better compression
        format: CompressFormat.jpeg,
        keepExif: false, // Remove metadata to reduce size
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Resize image with specified dimensions
  Future<File?> resizeImage(File file, int width, int height, int quality) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: width,
        minHeight: height,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false, // Remove metadata to reduce size
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  // Crop image
  Future<File?> cropImage(File file) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  // Convert image format
  Future<File?> convertFormat(File file, String format) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.$format');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        format: format.toLowerCase() == 'png' 
            ? CompressFormat.png 
            : format.toLowerCase() == 'webp' 
                ? CompressFormat.webp 
                : CompressFormat.jpeg,
        quality: 90,
        keepExif: false, // Remove metadata to reduce size
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error converting image format: $e');
      return null;
    }
  }

  // Save processed image to gallery
  Future<bool> saveToGallery(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savedPath = path.join(dir.path, 'processed_images', path.basename(file.path));
      
      // Create directory if it doesn't exist
      final savedDir = Directory(path.dirname(savedPath));
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }
      
      // Copy file to saved location
      await file.copy(savedPath);
      
      return true;
    } catch (e) {
      print('Error saving image to gallery: $e');
      return false;
    }
  }
  
  // Compress image to target file size
  Future<File?> compressToTargetSize(File file, double targetSize, String unit) async {
    try {
      // Convert target size to bytes
      final int targetBytes = _convertToBytes(targetSize, unit);
      
      // Get original file size
      final int originalBytes = await file.length();
      
      if (originalBytes <= targetBytes) {
        // No need to compress if already smaller than target
        return file;
      }
      
      // Start with quality 80 and adjust as needed
      int quality = 80;
      File? result;
      int resultBytes = originalBytes;
      
      // Binary search approach for finding optimal quality
      int minQuality = 1;
      int maxQuality = 100;
      
      while (minQuality <= maxQuality && resultBytes > targetBytes) {
        quality = (minQuality + maxQuality) ~/ 2;
        
        // Compress with current quality
        result = await compressImage(file, quality);
        
        if (result == null) break;
        
        resultBytes = await result.length();
        
        if (resultBytes > targetBytes) {
          // Still too large, reduce quality
          maxQuality = quality - 1;
        } else {
          // Too small, increase quality
          minQuality = quality + 1;
        }
      }
      
      // If we couldn't reach target size with quality adjustment alone,
      // try reducing dimensions
      if (result != null && resultBytes > targetBytes) {
        // Get image dimensions
         final bytes = await file.readAsBytes();
         final codec = await ui.instantiateImageCodec(bytes);
         final frameInfo = await codec.getNextFrame();
         final uiImage = frameInfo.image;
         int width = uiImage.width;
         int height = uiImage.height;
         uiImage.dispose(); // Clean up resources
        
        // Reduce dimensions by 10% increments until target size is reached
        // or dimensions become too small
        while (resultBytes > targetBytes && width > 100 && height > 100) {
          width = (width * 0.9).round();
          height = (height * 0.9).round();
          
          final dir = await getTemporaryDirectory();
          final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
          
          final resizeResult = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            minWidth: width,
            minHeight: height,
            quality: quality,
            format: CompressFormat.jpeg,
            keepExif: false,
          );
          
          if (resizeResult == null) break;
          
          result = File(resizeResult.path);
          resultBytes = await result.length();
        }
      }
      
      return result;
    } catch (e) {
      print('Error compressing image to target size: $e');
      return null;
    }
  }
  
  // Helper method to convert size to bytes
  int _convertToBytes(double size, String unit) {
    switch (unit) {
      case 'KB':
        return (size * 1024).round();
      case 'MB':
        return (size * 1024 * 1024).round();
      default:
        return size.round();
    }
  }
  
  // Share image with other apps
  Future<void> shareImage(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Shared from Image Processing App');
    } catch (e) {
      print('Error sharing image: $e');
    }
  }
}