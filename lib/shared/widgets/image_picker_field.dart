import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/services/image_upload_service.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';

/// Tap-to-upload image field. Shows a placeholder when empty, the uploaded
/// image when set, and exposes a remove button to clear the value.
///
/// The widget owns the upload lifecycle: tapping opens a camera/gallery
/// sheet, uploads to Supabase Storage, then calls [onChanged] with the
/// final public URL.
class ImagePickerField extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String folder;
  final String? hint;
  final double? aspectRatio;
  final bool deleteOnReplace;

  const ImagePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.folder,
    this.hint,
    this.aspectRatio = 1.0,
    this.deleteOnReplace = true,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  bool _uploading = false;

  Future<void> _pick() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _SheetTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            _SheetTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final file = await ImageUploadService.pickImage(source: source);
      if (file == null || !mounted) return;

      setState(() => _uploading = true);

      final url = await ImageUploadService.uploadFile(
        file: file,
        folder: widget.folder,
      );

      if (!mounted) return;

      // Clean up the previous image if any.
      final previous = widget.value;
      if (widget.deleteOnReplace && previous != null && previous.isNotEmpty) {
        ImageUploadService.deleteByUrl(previous);
      }

      widget.onChanged(url);
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Upload failed: ${_msg(e)}');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _remove() {
    final previous = widget.value;
    if (widget.deleteOnReplace && previous != null && previous.isNotEmpty) {
      ImageUploadService.deleteByUrl(previous);
    }
    widget.onChanged(null);
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.startsWith('Exception:') ? s.substring(10).trim() : s;
  }

  @override
  Widget build(BuildContext context) {
    final has = widget.value != null && widget.value!.isNotEmpty;

    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (has)
            CachedNetworkImage(
              imageUrl: widget.value!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _loading(),
              errorWidget: (_, __, ___) => _placeholderEmpty(),
            )
          else
            _placeholderEmpty(),
          if (_uploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          if (has && !_uploading)
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black87,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _remove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
          if (!_uploading)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pick,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.aspectRatio != null) {
      return AspectRatio(aspectRatio: widget.aspectRatio!, child: tile);
    }
    return tile;
  }

  Widget _placeholderEmpty() => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined,
                  color: Colors.black38, size: 26),
              const SizedBox(height: 6),
              Text(
                widget.hint ?? 'Tap to upload',
                style: const TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _loading() => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          ),
        ),
      );
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AppAssets.manrope,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}
