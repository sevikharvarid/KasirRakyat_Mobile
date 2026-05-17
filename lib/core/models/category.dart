import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    String? icon,
    String? colorHex,
    @Default(0) int sortOrder,
  }) = _Category;
}
