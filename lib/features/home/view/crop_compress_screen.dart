import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/features/home/view_model/image_processing_view_model.dart';

class CropCompressScreen extends ConsumerStatefulWidget {
  const CropCompressScreen({super.key});

  @override
  ConsumerState<CropCompressScreen> createState() => _CropCompressScreenState();
}

class _CropCompressScreenState extends ConsumerState<CropCompressScreen> {
  bool _isProcessing = false;
  double _compressionQuality = 80; // Default value
  String _targetSizeUnit = 'KB';
  double _targetSize = 100.0; // Default target size

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);
    final processedImages = ref.watch(processedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cropCompress),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image selection button
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: Text(selectedImages.isEmpty 
                ? 'Select Photo' 
                : 'Photo Selected'),
              onPressed: _isProcessing 
                ? null 
                : () => _selectImage(),
            ),
            
            const SizedBox(height: 24),
            
            // Crop button
            if (selectedImages.isNotEmpty && processedImages.isEmpty) ...[              
              ElevatedButton.icon(
                icon: const Icon(Icons.crop),
                label: const Text('Crop Image'),
                onPressed: _isProcessing 
                  ? null 
                  : () => _cropImage(),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Compression quality slider (only show after cropping)
            if (processedImages.isNotEmpty) ...[              
              Text(
                'Compression Quality: ${_compressionQuality.toInt()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _compressionQuality,
                min: 10,
                max: 100,
                divisions: 9,
                label: '${_compressionQuality.toInt()}%',
                onChanged: _isProcessing 
                  ? null 
                  : (value) {
                      setState(() {
                        _compressionQuality = value;
                      });
                      ref.read(compressionQualityProvider.notifier).state = value.toInt();
                    },
              ),
              
              const SizedBox(height: 16),
              
              // Target file size options
              Text(
                'Target File Size',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target Size',
                        border: const OutlineInputBorder(),
                        suffixText: _targetSizeUnit,
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _targetSize.toString(),
                      enabled: !_isProcessing,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _targetSize = double.tryParse(value) ?? 0.0;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(value: 'KB', label: Text('KB')),
                      ButtonSegment<String>(value: 'MB', label: Text('MB')),
                    ],
                    selected: {_targetSizeUnit},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _targetSizeUnit = selection.first;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Compress button
              ElevatedButton.icon(
                icon: const Icon(Icons.compress),
                label: Text(_isProcessing ? 'Compressing...' : AppStrings.compress),
                onPressed: _isProcessing 
                  ? null 
                  : () => _compressImage(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Results section
            if (processedImages.isNotEmpty) ...[              
              Text(
                'Processed Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Image
                      Positioned.fill(
                        child: Image.file(
                          processedImages.first,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Save button
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.save_alt, color: Colors.white),
                                onPressed: () => _saveImage(processedImages.first),
                                tooltip: 'Save to Gallery',
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.white),
                                onPressed: () => _shareImage(processedImages.first),
                                tooltip: 'Share',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage() async {
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    processedImagesNotifier.clearProcessedImages();
    await ref.read(selectedImagesProvider.notifier).pickSingleImage();
  }

  Future<void> _cropImage() async {
    setState(() {
      _isProcessing = true;
    });

    final selectedImages = ref.read(selectedImagesProvider);
    if (selectedImages.isEmpty) return;
    
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    processedImagesNotifier.clearProcessedImages();
    
    final service = ref.read(imageProcessingServiceProvider);
    final croppedImage = await service.cropImage(selectedImages.first);
    if (croppedImage != null) {
      processedImagesNotifier.addProcessedImage(croppedImage);
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _compressImage() async {
    setState(() {
      _isProcessing = true;
    });

    final processedImages = ref.read(processedImagesProvider);
    if (processedImages.isEmpty) return;
    
    ref.read(compressionQualityProvider.notifier).state = _compressionQuality.toInt();
    
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    final service = ref.read(imageProcessingServiceProvider);
    final originalImage = processedImages.first;
    
    // Clear the current processed image
    processedImagesNotifier.clearProcessedImages();
    
    File? compressedImage;
    
    // Use target size compression if target size is provided
    if (_targetSize > 0) {
      compressedImage = await service.compressToTargetSize(
        originalImage,
        _targetSize,
        _targetSizeUnit,
      );
    } else {
      // Otherwise use quality-based compression
      compressedImage = await service.compressImage(
        originalImage, 
        _compressionQuality.toInt()
      );
    }
    
    if (compressedImage != null) {
      processedImagesNotifier.addProcessedImage(compressedImage);
    }
    
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _saveImage(File image) async {
    final service = ref.read(imageProcessingServiceProvider);
    await service.saveToGallery(image);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery')),
      );
    }
  }

  Future<void> _shareImage(File image) async {
    final service = ref.read(imageProcessingServiceProvider);
    await service.shareImage(image);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image shared')),
      );
    }
  }
}