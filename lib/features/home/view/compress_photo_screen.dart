import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/features/home/view_model/image_processing_view_model.dart';

class CompressPhotoScreen extends ConsumerStatefulWidget {
  const CompressPhotoScreen({super.key});

  @override
  ConsumerState<CompressPhotoScreen> createState() => _CompressPhotoScreenState();
}

class _CompressPhotoScreenState extends ConsumerState<CompressPhotoScreen> {
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
        title: const Text(AppStrings.compressPhoto),
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
                ? 'Select Photos' 
                : '${selectedImages.length} Photos Selected'),
              onPressed: _isProcessing 
                ? null 
                : () => _selectImages(),
            ),
            
            const SizedBox(height: 24),
            
            // Compression quality slider
            if (selectedImages.isNotEmpty) ...[              
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
              
              // Target file size selection
              const SizedBox(height: 16),
              Text(
                'Target File Size',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('KB'),
                      value: 'KB',
                      groupValue: _targetSizeUnit,
                      onChanged: _isProcessing
                        ? null
                        : (value) {
                            setState(() {
                              _targetSizeUnit = value!;
                            });
                          },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('MB'),
                      value: 'MB',
                      groupValue: _targetSizeUnit,
                      onChanged: _isProcessing
                        ? null
                        : (value) {
                            setState(() {
                              _targetSizeUnit = value!;
                            });
                          },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Target Size ($_targetSizeUnit)',
                  border: const OutlineInputBorder(),
                  suffixText: _targetSizeUnit,
                ),
                keyboardType: TextInputType.number,
                enabled: !_isProcessing,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _targetSize = double.tryParse(value) ?? 0.0;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Compress button
              ElevatedButton.icon(
                icon: const Icon(Icons.compress),
                label: Text(_isProcessing ? 'Compressing...' : AppStrings.compress),
                onPressed: _isProcessing || selectedImages.isEmpty 
                  ? null 
                  : () => _compressImages(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Results section
            if (processedImages.isNotEmpty) ...[              
              Text(
                'Compressed Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: processedImages.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Image
                          Positioned.fill(
                            child: Image.file(
                              processedImages[index],
                              fit: BoxFit.cover,
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
                                    onPressed: () => _saveImage(processedImages[index]),
                                    tooltip: 'Save to Gallery',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.white),
                                    onPressed: () => _shareImage(processedImages[index]),
                                    tooltip: 'Share',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectImages() async {
    await ref.read(selectedImagesProvider.notifier).pickImages();
  }

  Future<void> _compressImages() async {
    setState(() {
      _isProcessing = true;
    });

    final selectedImages = ref.read(selectedImagesProvider);
    final quality = ref.read(compressionQualityProvider);
    final service = ref.read(imageProcessingServiceProvider);
    
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    processedImagesNotifier.clearProcessedImages();
    
    for (final image in selectedImages) {
      File? compressedImage;
      
      // Use target size compression if target size is provided
      if (_targetSize > 0) {
        compressedImage = await service.compressToTargetSize(
          image,
          _targetSize,
          _targetSizeUnit,
        );
      } else {
        // Otherwise use quality-based compression
        compressedImage = await service.compressImage(image, quality);
      }
      
      if (compressedImage != null) {
        processedImagesNotifier.addProcessedImage(compressedImage);
      }
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
  }
}