class BookAgainModel {
  final String bookingUuid;
  final String serviceUuid;
  final String serviceName;
  final String providerUuid;
  final String providerName;
  final String branchUuid;
  final String branchName;
  final String employeeName;
  final DateTime? lastBookedOn;
  final double price;
  final String currency;

  const BookAgainModel({
    required this.bookingUuid,
    required this.serviceUuid,
    required this.serviceName,
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.employeeName,
    required this.price,
    required this.currency,
    this.lastBookedOn,
  });

  factory BookAgainModel.fromJson(Map<String, dynamic> json) => BookAgainModel(
    bookingUuid: json['booking_uuid']?.toString() ?? '',
    serviceUuid: json['service_uuid']?.toString() ?? '',
    serviceName: json['service_name']?.toString() ?? '',
    providerUuid: json['provider_uuid']?.toString() ?? '',
    providerName: json['provider_name']?.toString() ?? '',
    branchUuid: json['branch_uuid']?.toString() ?? '',
    branchName: json['branch_name']?.toString() ?? '',
    employeeName: json['employee_name']?.toString() ?? '',
    lastBookedOn: DateTime.tryParse(json['last_booked_on']?.toString() ?? ''),
    price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
    currency: json['currency']?.toString() ?? '',
  );
}

class BookAgainPageModel {
  final List<BookAgainModel> items;
  final int page;
  final bool hasMore;

  const BookAgainPageModel({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory BookAgainPageModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedPage,
  }) {
    final data = json['data'];
    final meta = json['meta'];
    final metaMap = meta is Map<String, dynamic> ? meta : null;
    final page =
        int.tryParse(metaMap?['page']?.toString() ?? '') ??
        int.tryParse(metaMap?['current_page']?.toString() ?? '') ??
        requestedPage;
    final lastPage = int.tryParse(metaMap?['last_page']?.toString() ?? '');
    return BookAgainPageModel(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(BookAgainModel.fromJson)
                .where(
                  (item) =>
                      item.providerUuid.isNotEmpty &&
                      item.branchUuid.isNotEmpty &&
                      item.serviceUuid.isNotEmpty,
                )
                .toList(growable: false)
          : const [],
      page: page,
      hasMore:
          metaMap?['has_more'] == true || (lastPage != null && page < lastPage),
    );
  }
}
