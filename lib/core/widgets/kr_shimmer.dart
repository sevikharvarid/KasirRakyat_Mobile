import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Kotak shimmer tunggal yang bisa dipakai sebagai placeholder.
class KrShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const KrShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  /// Warna dasar shimmer sesuai tema aplikasi.
  static const Color base = AppColors.border;
  static const Color highlight = AppColors.primarySurface;

  /// Bungkus sembarang widget dengan efek shimmer.
  static Widget wrap({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
