// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Product {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int? get categoryId => throw _privateConstructorUsedError;
  int get sellPrice => throw _privateConstructorUsedError;
  int get buyPrice => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  int get minStock => throw _privateConstructorUsedError;

  /// Satuan produk, mis. "pcs", "kg", "dus". Default "pcs".
  String get unit => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    int id,
    String name,
    int? categoryId,
    int sellPrice,
    int buyPrice,
    int stock,
    int minStock,
    String unit,
    String? imageUrl,
    String? barcode,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? sellPrice = null,
    Object? buyPrice = null,
    Object? stock = null,
    Object? minStock = null,
    Object? unit = null,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int?,
            sellPrice: null == sellPrice
                ? _value.sellPrice
                : sellPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            buyPrice: null == buyPrice
                ? _value.buyPrice
                : buyPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            minStock: null == minStock
                ? _value.minStock
                : minStock // ignore: cast_nullable_to_non_nullable
                      as int,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            barcode: freezed == barcode
                ? _value.barcode
                : barcode // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    int? categoryId,
    int sellPrice,
    int buyPrice,
    int stock,
    int minStock,
    String unit,
    String? imageUrl,
    String? barcode,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? sellPrice = null,
    Object? buyPrice = null,
    Object? stock = null,
    Object? minStock = null,
    Object? unit = null,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int?,
        sellPrice: null == sellPrice
            ? _value.sellPrice
            : sellPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        buyPrice: null == buyPrice
            ? _value.buyPrice
            : buyPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        minStock: null == minStock
            ? _value.minStock
            : minStock // ignore: cast_nullable_to_non_nullable
                  as int,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        barcode: freezed == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    required this.name,
    this.categoryId,
    required this.sellPrice,
    required this.buyPrice,
    required this.stock,
    required this.minStock,
    this.unit = 'pcs',
    this.imageUrl,
    this.barcode,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final int? categoryId;
  @override
  final int sellPrice;
  @override
  final int buyPrice;
  @override
  final int stock;
  @override
  final int minStock;

  /// Satuan produk, mis. "pcs", "kg", "dus". Default "pcs".
  @override
  @JsonKey()
  final String unit;
  @override
  final String? imageUrl;
  @override
  final String? barcode;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, categoryId: $categoryId, sellPrice: $sellPrice, buyPrice: $buyPrice, stock: $stock, minStock: $minStock, unit: $unit, imageUrl: $imageUrl, barcode: $barcode, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.sellPrice, sellPrice) ||
                other.sellPrice == sellPrice) &&
            (identical(other.buyPrice, buyPrice) ||
                other.buyPrice == buyPrice) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    categoryId,
    sellPrice,
    buyPrice,
    stock,
    minStock,
    unit,
    imageUrl,
    barcode,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);
}

abstract class _Product implements Product {
  const factory _Product({
    required final int id,
    required final String name,
    final int? categoryId,
    required final int sellPrice,
    required final int buyPrice,
    required final int stock,
    required final int minStock,
    final String unit,
    final String? imageUrl,
    final String? barcode,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ProductImpl;

  @override
  int get id;
  @override
  String get name;
  @override
  int? get categoryId;
  @override
  int get sellPrice;
  @override
  int get buyPrice;
  @override
  int get stock;
  @override
  int get minStock;

  /// Satuan produk, mis. "pcs", "kg", "dus". Default "pcs".
  @override
  String get unit;
  @override
  String? get imageUrl;
  @override
  String? get barcode;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
