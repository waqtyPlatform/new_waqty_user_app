class UpcomingBookingModel {
  final String uuid;
  final String status;
  final String paymentStatus;
  final String bookingDate;
  final String startTime;
  final bool isToday;
  final String serviceName;
  final String providerName;
  final String branchName;
  final String? employeeName;
  final double price;
  final String currency;
  final double? latitude;
  final double? longitude;
  final bool canAnnounceOnWay;
  final DateTime? onWayAnnouncedAt;

  const UpcomingBookingModel({
    required this.uuid,
    required this.status,
    required this.paymentStatus,
    required this.bookingDate,
    required this.startTime,
    required this.isToday,
    required this.serviceName,
    required this.providerName,
    required this.branchName,
    required this.price,
    required this.currency,
    required this.canAnnounceOnWay,
    this.employeeName,
    this.latitude,
    this.longitude,
    this.onWayAnnouncedAt,
  });

  factory UpcomingBookingModel.fromJson(Map<String, dynamic> json) =>
      UpcomingBookingModel(
        uuid: (json['uuid'] ?? json['booking_uuid'])?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        paymentStatus: json['payment_status']?.toString() ?? '',
        bookingDate: json['booking_date']?.toString() ?? '',
        startTime: json['start_time']?.toString() ?? '',
        isToday: json['is_today'] == true,
        serviceName: json['service_name']?.toString() ?? '',
        providerName: json['provider_name']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        employeeName: _nullableText(json['employee_name']),
        price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
        currency: json['currency']?.toString() ?? '',
        latitude: double.tryParse(json['latitude']?.toString() ?? ''),
        longitude: double.tryParse(json['longitude']?.toString() ?? ''),
        canAnnounceOnWay: json['can_announce_on_way'] == true,
        onWayAnnouncedAt: DateTime.tryParse(
          json['on_way_announced_at']?.toString() ?? '',
        ),
      );

  UpcomingBookingModel announcedAt(DateTime value) => UpcomingBookingModel(
    uuid: uuid,
    status: status,
    paymentStatus: paymentStatus,
    bookingDate: bookingDate,
    startTime: startTime,
    isToday: isToday,
    serviceName: serviceName,
    providerName: providerName,
    branchName: branchName,
    employeeName: employeeName,
    price: price,
    currency: currency,
    latitude: latitude,
    longitude: longitude,
    canAnnounceOnWay: canAnnounceOnWay,
    onWayAnnouncedAt: value,
  );
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
