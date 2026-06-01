import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Picks an image from camera/gallery and uploads it directly to Supabase
/// Storage, returning the public URL.
class ImageUploadService {
  static const _bucket = 'media';
  static final _picker = ImagePicker();
  static final _uuid = const Uuid();

  /// Pick an image from the given [source]. Returns null if the user cancels.
  static Future<XFile?> pickImage({required ImageSource source}) {
    return _picker.pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
  }

  /// Upload bytes of an already-picked image. [folder] is a subpath inside
  /// the bucket (e.g. `products`, `brands/logos`).
  static Future<String> uploadFile({
    required XFile file,
    required String folder,
  }) async {
    final ext = _extensionOf(file.path);
    final filename = '${_uuid.v4()}.$ext';
    final path = '$folder/$filename';

    final bytes = await file.readAsBytes();
    await Supabase.instance.client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/$ext',
            upsert: false,
          ),
        );

    return Supabase.instance.client.storage
        .from(_bucket)
        .getPublicUrl(path);
  }

  /// Delete a previously-uploaded file by its public URL. Fails silently if
  /// the URL doesn't match the bucket or the object doesn't exist.
  static Future<void> deleteByUrl(String url) async {
    final marker = '/object/public/$_bucket/';
    final i = url.indexOf(marker);
    if (i == -1) return;
    final path = Uri.decodeFull(url.substring(i + marker.length));
    try {
      await Supabase.instance.client.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Best-effort cleanup; ignore failures.
    }
  }

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    // Some pickers return a path without an extension; default to jpg.
    return ext.isEmpty ? 'jpg' : ext;
  }
}

// Convenience: lets callers read XFile bytes via File API if they prefer.
extension XFileToFile on XFile {
  File toFile() => File(path);
}
