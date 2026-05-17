class StoreProfile {
  final String name;
  final String? address;
  final String? phone;
  final String? ownerName;

  const StoreProfile({
    required this.name,
    this.address,
    this.phone,
    this.ownerName,
  });

  StoreProfile copyWith({
    String? name,
    String? address,
    String? phone,
    String? ownerName,
  }) {
    return StoreProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}
