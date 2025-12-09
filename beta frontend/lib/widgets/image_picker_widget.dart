import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Widget for selecting and displaying multiple images
class ImagePickerWidget extends StatefulWidget {
  final List<File>? initialImages;
  final int maxImages;
  final Function(List<File>)? onImagesChanged;
  final bool enabled;

  const ImagePickerWidget({
    super.key,
    this.initialImages,
    this.maxImages = 5,
    this.onImagesChanged,
    this.enabled = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _selectedImages = List.from(widget.initialImages!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!widget.enabled) return;
    
    final remainingSlots = widget.maxImages - _selectedImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxImages} images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      List<XFile> pickedImages = [];
      
      if (source == ImageSource.gallery) {
        // Pick multiple images from gallery
        pickedImages = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
      } else {
        // Camera - single image
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        if (image != null) {
          pickedImages = [image];
        }
      }

      if (pickedImages.isNotEmpty) {
        // Limit to remaining slots
        final imagesToAdd = pickedImages.take(remainingSlots).toList();
        
        if (pickedImages.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Only ${remainingSlots} image(s) added. Maximum ${widget.maxImages} images allowed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        setState(() {
          _selectedImages.addAll(imagesToAdd.map((xFile) => File(xFile.path)));
        });
        widget.onImagesChanged?.call(_selectedImages);
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Could not access photos. Please check permissions.';
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        errorMessage = 'Could not access photos. Please check permissions.';
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    if (!widget.enabled) return;
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesChanged?.call(_selectedImages);
  }

  Future<void> _showImageSourceDialog() async {
    if (!widget.enabled) return;
    if (_selectedImages.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxImages} images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Photos Button
        GestureDetector(
          onTap: widget.enabled ? _showImageSourceDialog : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textGrey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: widget.enabled
                      ? AppTheme.primaryColor
                      : AppTheme.textGrey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    color: widget.enabled
                        ? AppTheme.textDark
                        : AppTheme.textGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Image Grid
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _selectedImages.length + (widget.enabled && _selectedImages.length < widget.maxImages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                // Add more button
                return GestureDetector(
                  onTap: widget.enabled ? _showImageSourceDialog : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.textGrey.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 32,
                          color: widget.enabled
                              ? AppTheme.primaryColor
                              : AppTheme.textGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: widget.enabled
                                ? AppTheme.textDark
                                : AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Image preview with remove button
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  if (widget.enabled)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedImages.length}/${widget.maxImages} images selected',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

