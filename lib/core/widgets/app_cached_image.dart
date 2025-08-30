import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholderColor,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (BuildContext context, String _) => Container(
        width: width,
        height: height,
        color: (placeholderColor ?? Theme.of(context).colorScheme.surfaceVariant).withOpacity(0.35),
        alignment: Alignment.center,
        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (BuildContext context, String _, dynamic __) => Container(
        width: width,
        height: height,
        color: (placeholderColor ?? Theme.of(context).colorScheme.surfaceVariant).withOpacity(0.5),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
