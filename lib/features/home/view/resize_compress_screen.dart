import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/features/home/view_model/image_processing_view_model.dart';

class ResizeCompressScreen extends ConsumerStatefulWidget {
  const ResizeCompressScreen({super.key});

  @override
  ConsumerState<ResizeCompressScreen> createState() => _ResizeCompressScreenState();
}

class _ResizeCompressScreenState extends ConsumerState<ResizeCompressScreen> {
  bool _isProcessing = false;
  double _compressionQuality = 80; // Default value
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  bool _maintainAspectRatio = true;
  double? _aspectRatio;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);
    final processedImages = ref.watch(processedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resizeCompress),
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
            
            // Resize options
            if (selectedImages.isNotEmpty) ...[              
              Text(
                'Resize Dimensions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Width input
                  Expanded(
                    child: TextField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Width (px)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (_maintainAspectRatio && _aspectRatio != null && value.isNotEmpty) {
                          final width = int.tryParse(value) ?? 0;
                          if (width > 0) {
                            final height = (width / _aspectRatio!).round();
                            _heightController.text = height.toString();
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Height input
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (px)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (_maintainAspectRatio && _aspectRatio != null && value.isNotEmpty) {
                          final height = int.tryParse(value) ?? 0;
                          if (height > 0) {
                            final width = (height * _aspectRatio!).round();
                            _widthController.text = width.toString();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              // Maintain aspect ratio checkbox
              Row(
                children: [
                  Checkbox(
                    value: _maintainAspectRatio,
                    onChanged: (value) {
                      setState(() {
                        _maintainAspectRatio = value ?? true;
                      });
                    },
                  ),
                  const Text('Maintain aspect ratio'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Compression quality slider
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
              
              const SizedBox(height: 24),
              
              // Resize and compress button
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_size_select_large),
                label: Text(_isProcessing ? 'Processing...' : 'Resize & Compress'),
                onPressed: _isProcessing || selectedImages.isEmpty ||
                          _widthController.text.isEmpty || _heightController.text.isEmpty
                  ? null 
                  : () => _resizeAndCompressImage(),
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
    await ref.read(selectedImagesProvider.notifier).pickSingleImage();
    final selectedImages = ref.read(selectedImagesProvider);
    
    if (selectedImages.isNotEmpty) {
      // Get image dimensions to set initial values and aspect ratio
      final image = await decodeImageFromList(selectedImages.first.readAsBytesSync());
      setState(() {
        _widthController.text = image.width.toString();
        _heightController.text = image.height.toString();
        _aspectRatio = image.width / image.height;
      });
    }
  }

  Future<void> _resizeAndCompressImage() async {
    setState(() {
      _isProcessing = true;
    });

    final selectedImages = ref.read(selectedImagesProvider);
    if (selectedImages.isEmpty) return;
    
    final width = int.tryParse(_widthController.text) ?? 0;
    final height = int.tryParse(_heightController.text) ?? 0;
    
    // Update the compression quality provider
    ref.read(compressionQualityProvider.notifier).state = _compressionQuality.toInt();
    
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    processedImagesNotifier.clearProcessedImages();
    
    final service = ref.read(imageProcessingServiceProvider);
    final resizedImage = await service.resizeImage(selectedImages.first, width, height, _compressionQuality.toInt());
    
    if (resizedImage != null) {
      processedImagesNotifier.addProcessedImage(resizedImage);
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