class ProviderServiceItem {
  final String id, label;
  final int price, minutes;
  final List<ProviderServiceItem> children;
  const ProviderServiceItem(
    this.id,
    this.label,
    this.price,
    this.minutes, {
    this.children = const [],
  });
}

class ProviderSpecialist {
  final String id, label;
  final int price, minutes;
  final bool recommended;
  const ProviderSpecialist(
    this.id,
    this.label,
    this.price,
    this.minutes, {
    this.recommended = false,
  });
}

class ProviderPackage {
  final String id, label, validity;
  final int price, sessions;
  final int? oldPrice;
  const ProviderPackage(
    this.id,
    this.label,
    this.price,
    this.sessions,
    this.validity, {
    this.oldPrice,
  });
}

class ProviderBranch {
  final String id, label, address;
  final bool namedStaff;
  final List<ProviderServiceItem> services;
  final List<ProviderSpecialist> specialists;
  final List<ProviderPackage> packages;
  const ProviderBranch({
    required this.id,
    required this.label,
    required this.address,
    required this.services,
    required this.specialists,
    required this.packages,
    this.namedStaff = true,
  });
}

class ProviderCatalog {
  final List<ProviderBranch> branches;
  final bool isPreview;
  const ProviderCatalog(this.branches, {this.isPreview = false});
}
