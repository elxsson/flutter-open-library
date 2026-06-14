import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

class BookCover extends StatelessWidget {
  final int? coverId;
  final double width;
  final double height;
  final String size;

  const BookCover({
    super.key,
    this.coverId,
    this.width = 80,
    this.height = 120,
    this.size = 'M',
  });

  String get _url {
    if (coverId == null) return '';
    return 'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';
  }

  @override
  Widget build(BuildContext context) {
    if (coverId == null) {
      return _placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: _url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder,
        errorWidget: (_, __, ___) => _placeholder,
      ),
    );
  }

  Widget get _placeholder => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.menu_book,
          size: width * 0.4,
          color: AppColors.primary,
        ),
      );
}
