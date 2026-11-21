import 'package:blobatar/flutter.dart';
import 'package:flutter/material.dart';

/// Profile image with a deterministic Blobatar fallback.
class ProfileAvatar extends StatelessWidget {
  final String seed;
  final String? imageUrl;
  final double size;
  final String? semanticLabel;

  const ProfileAvatar({
    super.key,
    required this.seed,
    this.imageUrl,
    this.size = 48,
    this.semanticLabel,
  });

  Widget _fallback() => Blobatar(
        name: seed.trim().isEmpty ? 'docentia-user' : seed,
        size: size,
        semanticLabel: semanticLabel,
        options: const BlobatarOptions(background: Backdrop.circle),
      );

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return _fallback();

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      ),
    );
  }
}
