import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ripehash/features/home/repo/image_processing_service.dart';

// Providers
final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService();
});

// Advanced compression options provider
final advancedCompressionOptionsProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'algorithm': 'default',
  'optimizeForWeb': false,
  'removeMetadata': false,
});

// Advanced compression provider
final advancedCompressImagesProvider = FutureProvider.family<List<File>?, List<File>>((ref, images) async {
  if (images.isEmpty) return null;
  
  final service = ref.read(imageProcessingServiceProvider);
  final quality = ref.read(compressionQualityProvider);
  final options = ref.read(advancedCompressionOptionsProvider);
  
  final processedImages = <File>[];
  
  for (final image in images) {
    // Use the standard compression for now, but in a real app, you would use the options
    final processed = await service.compressImage(image, quality);
    if (processed != null) {
      processedImages.add(processed);
    }
  }
  
  if (processedImages.isNotEmpty) {
    ref.read(processedImagesProvider.notifier).setProcessedImages(processedImages);
    return processedImages;
  }
  
  return null;
});

final selectedImagesProvider = StateNotifierProvider<SelectedImagesNotifier, List<File>>((ref) {
  return SelectedImagesNotifier();
});

final compressionQualityProvider = StateProvider<int>((ref) => 80); // Default 80%

final processedImagesProvider = StateNotifierProvider<ProcessedImagesNotifier, List<File>>((ref) {
  return ProcessedImagesNotifier();
});

// Notifiers
class SelectedImagesNotifier extends StateNotifier<List<File>> {
  SelectedImagesNotifier() : super([]);

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      state = pickedFiles.map((xFile) => File(xFile.path)).toList();
    }
  }

  Future<void> pickSingleImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      state = [File(pickedFile.path)];
    }
  }

  void clearImages() {
    state = [];
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<File>.from(state);
      newList.removeAt(index);
      state = newList;
    }
  }
}

class ProcessedImagesNotifier extends StateNotifier<List<File>> {
  ProcessedImagesNotifier() : super([]);

  void addProcessedImage(File file) {
    state = [...state, file];
  }

  void setProcessedImages(List<File> files) {
    state = files;
  }

  void clearProcessedImages() {
    state = [];
  }
}

// Image processing functions
final compressImagesProvider = FutureProvider.family<List<File>?, List<File>>((ref, images) async {
  if (images.isEmpty) return null;
  
  final service = ref.read(imageProcessingServiceProvider);
  final quality = ref.read(compressionQualityProvider);
  
  final processedImages = <File>[];
  
  for (final image in images) {
    final processed = await service.compressImage(image, quality);
    if (processed != null) {
      processedImages.add(processed);
    }
  }
  
  if (processedImages.isNotEmpty) {
    ref.read(processedImagesProvider.notifier).setProcessedImages(processedImages);
    return processedImages;
  }
  
  return null;
});

final resizeImagesProvider = FutureProvider.family<List<File>?, Map<String, dynamic>>((ref, params) async {
  final images = params['images'] as List<File>;
  final width = params['width'] as int;
  final height = params['height'] as int;
  final quality = params['quality'] as int;

  if (images.isEmpty) return null;
  
  final service = ref.read(imageProcessingServiceProvider);
  
  final processedImages = <File>[];
  
  for (final image in images) {
    final processed = await service.resizeImage(image, width, height, quality);
    if (processed != null) {
      processedImages.add(processed);
    }
  }
  
  if (processedImages.isNotEmpty) {
    ref.read(processedImagesProvider.notifier).setProcessedImages(processedImages);
    return processedImages;
  }
  
  return null;
});

final cropImagesProvider = FutureProvider.family<List<File>?, List<File>>((ref, images) async {
  if (images.isEmpty) return null;
  
  final service = ref.read(imageProcessingServiceProvider);
  
  final processedImages = <File>[];
  
  for (final image in images) {
    final processed = await service.cropImage(image);
    if (processed != null) {
      processedImages.add(processed);
    }
  }
  
  if (processedImages.isNotEmpty) {
    ref.read(processedImagesProvider.notifier).setProcessedImages(processedImages);
    return processedImages;
  }
  
  return null;
});



// Share image provider
final shareImageProvider = FutureProvider.family<void, File>((ref, image) async {
  final service = ref.read(imageProcessingServiceProvider);
  await service.shareImage(image);
});

final cropImageProvider = FutureProvider.family<File?, File>((ref, image) async {
  final service = ref.read(imageProcessingServiceProvider);
  return service.cropImage(image);
});

final convertFormatProvider = FutureProvider.family<List<File>?, Map<String, dynamic>>((ref, params) async {
  final images = params['images'] as List<File>;
  final format = params['format'] as String;
  
  if (images.isEmpty) return null;
  
  final service = ref.read(imageProcessingServiceProvider);
  
  final processedImages = <File>[];
  
  for (final image in images) {
    final processed = await service.convertFormat(image, format);
    if (processed != null) {
      processedImages.add(processed);
    }
  }
  
  if (processedImages.isNotEmpty) {
    ref.read(processedImagesProvider.notifier).setProcessedImages(processedImages);
    return processedImages;
  }
  
  return null;
});