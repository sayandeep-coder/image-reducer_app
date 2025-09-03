import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ripehash/features/home/view_model/image_processing_view_model.dart';

class AdvancedCompressScreen extends ConsumerStatefulWidget {
  const AdvancedCompressScreen({super.key});

  @override
  ConsumerState<AdvancedCompressScreen> createState() => _AdvancedCompressScreenState();
}

class _AdvancedCompressScreenState extends ConsumerState<AdvancedCompressScreen> {
  bool _isProcessing = false;
  double _compressionQuality = 80; // Default value
  String _compressionAlgorithm = 'standard';
  final List<String> _algorithms = ['standard', 'high', 'ultra'];
  bool _optimizeForWeb = false;
  bool _removeMetadata = true;
  String _targetSizeUnit = 'KB';
  double _targetSize = 100.0; // Default target size

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);
    final processedImages = ref.watch(processedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.advancedCompress),
        actions: [
          // Premium badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(MdiIcons.crown, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('PREMIUM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
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
            
            // Advanced compression options
            if (selectedImages.isNotEmpty) ...[              
              // Compression algorithm
              Text(
                'Compression Algorithm',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _algorithms.map((algorithm) => 
                  ButtonSegment<String>(
                    value: algorithm,
                    label: Text(algorithm.toUpperCase()),
                  )
                ).toList(),
                selected: {_compressionAlgorithm},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _compressionAlgorithm = selection.first;
                  });
                },
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
              
              // Additional options
              SwitchListTile(
                title: const Text('Optimize for Web'),
                subtitle: const Text('Reduce file size for web uploads'),
                value: _optimizeForWeb,
                onChanged: (value) {
                  setState(() {
                    _optimizeForWeb = value;
                  });
                },
              ),
              
              SwitchListTile(
                title: const Text('Remove Metadata'),
                subtitle: const Text('Strip EXIF and other metadata'),
                value: _removeMetadata,
                onChanged: (value) {
                  setState(() {
                    _removeMetadata = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Compress button
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isProcessing ? 'Compressing...' : 'Advanced Compress'),
                onPressed: _isProcessing || selectedImages.isEmpty 
                  ? null 
                  : () => _compressImages(),
              ),
            ],
            
            const SizedBox(height: 16),
            
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
    final service = ref.read(imageProcessingServiceProvider);
    
    // Update the compression quality provider
    ref.read(compressionQualityProvider.notifier).state = _compressionQuality.toInt();
    
    // Update the advanced compression options
    ref.read(advancedCompressionOptionsProvider.notifier).state = {
      'algorithm': _compressionAlgorithm,
      'optimizeForWeb': _optimizeForWeb,
      'removeMetadata': _removeMetadata,
    };
    
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
        // Otherwise use the advanced compression provider
        final quality = ref.read(compressionQualityProvider);
        compressedImage = await service.compressImage(image, quality);
        
        // Apply additional processing based on advanced options
        // This would be expanded in a real implementation
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
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image shared')),
      );
    }
  }
}