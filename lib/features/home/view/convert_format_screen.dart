import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/features/home/view_model/image_processing_view_model.dart';

class ConvertFormatScreen extends ConsumerStatefulWidget {
  const ConvertFormatScreen({super.key});

  @override
  ConsumerState<ConvertFormatScreen> createState() => _ConvertFormatScreenState();
}

class _ConvertFormatScreenState extends ConsumerState<ConvertFormatScreen> {
  bool _isProcessing = false;
  String _selectedFormat = 'jpg';
  final List<String> _availableFormats = ['jpg', 'png', 'webp'];

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);
    final processedImages = ref.watch(processedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.convertFormat),
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
            
            // Format selection
            if (selectedImages.isNotEmpty) ...[              
              Text(
                'Select Output Format',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _availableFormats.map((format) => 
                  ButtonSegment<String>(
                    value: format,
                    label: Text(format.toUpperCase()),
                  )
                ).toList(),
                selected: {_selectedFormat},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedFormat = selection.first;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Convert button
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: Text(_isProcessing ? 'Converting...' : AppStrings.convert),
                onPressed: _isProcessing || selectedImages.isEmpty 
                  ? null 
                  : () => _convertFormat(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Results section
            if (processedImages.isNotEmpty) ...[              
              Text(
                'Converted Image',
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

  Future<void> _convertFormat() async {
    setState(() {
      _isProcessing = true;
    });

    final selectedImages = ref.read(selectedImagesProvider);
    if (selectedImages.isEmpty) return;
    
    final processedImagesNotifier = ref.read(processedImagesProvider.notifier);
    processedImagesNotifier.clearProcessedImages();
    
    await ref.read(convertFormatProvider({
      'images': selectedImages,
      'format': _selectedFormat,
    }).future);

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