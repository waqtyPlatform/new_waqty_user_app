enum BookingCartItemType { service, package, ownedPackage, followUp }

extension BookingCartItemTypeApi on BookingCartItemType {
  String get value => switch (this) {
    BookingCartItemType.service => 'service',
    BookingCartItemType.package => 'package',
    BookingCartItemType.ownedPackage => 'owned_package',
    BookingCartItemType.followUp => 'follow_up',
  };
}

class BookingCartAddRequest {
  final String providerUuid, branchUuid, slotToken, idempotencyKey;
  final BookingCartItemType itemType;
  final String? serviceUuid;
  final String? packageUuid;
  final String? entitlementUuid;
  final String? followUpUuid;
  final String? employeeUuid;

  const BookingCartAddRequest({
    required this.providerUuid,
    required this.branchUuid,
    required this.slotToken,
    required this.idempotencyKey,
    required this.itemType,
    this.serviceUuid,
    this.packageUuid,
    this.entitlementUuid,
    this.followUpUuid,
    this.employeeUuid,
  });

  Map<String, dynamic> toJson() => {
    'provider_uuid': providerUuid,
    'branch_uuid': branchUuid,
    'item_type': itemType.value,
    if (serviceUuid != null) 'service_uuid': serviceUuid,
    if (packageUuid != null) 'package_uuid': packageUuid,
    if (entitlementUuid != null) 'entitlement_uuid': entitlementUuid,
    if (followUpUuid != null) 'follow_up_uuid': followUpUuid,
    if (employeeUuid != null) 'employee_uuid': employeeUuid,
    'slot_token': slotToken,
    'idempotency_key': idempotencyKey,
  };
}

class BookingCartModel {
  final String uuid;
  final BookingCartItemModel? addedItem;
  final List<BookingCartItemModel> items;
  final int itemsCount;
  final double subtotal;
  final String currencyCode;
  final double servicesTotal, serviceFee, tax, discount, estimatedTotal;
  final bool hasServiceFee, hasTax, hasDiscount;
  final DateTime? expiresAt, serverTime;
  final int? expiresInSeconds;
  final double? expiresInHours;
  final String? expirationMessage;

  const BookingCartModel({
    required this.uuid,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.currencyCode,
    this.servicesTotal = 0,
    this.serviceFee = 0,
    this.tax = 0,
    this.discount = 0,
    this.estimatedTotal = 0,
    this.hasServiceFee = false,
    this.hasTax = false,
    this.hasDiscount = false,
    this.addedItem,
    this.expiresAt,
    this.serverTime,
    this.expiresInSeconds,
    this.expiresInHours,
    this.expirationMessage,
  });

  factory BookingCartModel.fromJson(Map<String, dynamic> json) {
    final summary = _map(json['summary']);
    final subtotal = _number(json['subtotal']);
    final servicesTotal = _number(
      json['services_total'] ?? summary['services_total'] ?? subtotal,
    );
    final serviceFee = _number(json['service_fee'] ?? summary['service_fee']);
    final tax = _number(
      json['tax'] ??
          json['tax_amount'] ??
          json['vat'] ??
          json['vat_amount'] ??
          summary['tax'] ??
          summary['tax_amount'] ??
          summary['vat'] ??
          summary['vat_amount'],
    );
    final discount = _number(
      json['discount'] ??
          json['discount_amount'] ??
          summary['discount'] ??
          summary['discount_amount'],
    );
    final estimatedTotalValue =
        json['estimated_total'] ?? summary['estimated_total'];
    final estimatedTotal = estimatedTotalValue == null
        ? servicesTotal + serviceFee + tax - discount
        : _number(estimatedTotalValue);
    return BookingCartModel(
      uuid: _text(json['cart_uuid']),
      addedItem: json['item'] is Map<String, dynamic>
          ? BookingCartItemModel.fromJson(json['item'] as Map<String, dynamic>)
          : null,
      items: _models(json['items'], BookingCartItemModel.fromJson),
      itemsCount: _integer(json['items_count']),
      subtotal: subtotal,
      currencyCode: _text(json['currency_code'] ?? summary['currency_code']),
      servicesTotal: servicesTotal,
      serviceFee: serviceFee,
      tax: tax,
      discount: discount,
      estimatedTotal: estimatedTotal,
      hasServiceFee:
          json.containsKey('service_fee') || summary.containsKey('service_fee'),
      hasTax:
          json.containsKey('tax') ||
          json.containsKey('tax_amount') ||
          json.containsKey('vat') ||
          json.containsKey('vat_amount') ||
          summary.containsKey('tax') ||
          summary.containsKey('tax_amount') ||
          summary.containsKey('vat') ||
          summary.containsKey('vat_amount'),
      hasDiscount:
          json.containsKey('discount') ||
          json.containsKey('discount_amount') ||
          summary.containsKey('discount') ||
          summary.containsKey('discount_amount'),
      expiresAt: _date(json['expires_at']),
      serverTime: _date(json['server_time']),
      expiresInSeconds: _nullableInteger(json['expires_in_seconds']),
      expiresInHours: _nullableNumber(json['expires_in_hours']),
      expirationMessage: _nullableText(json['expiration_message']),
    );
  }
}

class BookingCartItemModel {
  final String uuid, type, name, providerUuid, branchUuid;
  final BookingCartEmployeeModel? employee;
  final DateTime? startsAt, endsAt, holdExpiresAt;
  final double price;
  final String currencyCode, holdUuid;
  final int remainingSeconds;
  final double? remainingHours;
  final String? expirationMessage;

  const BookingCartItemModel({
    required this.uuid,
    required this.type,
    required this.name,
    required this.providerUuid,
    required this.branchUuid,
    required this.price,
    required this.currencyCode,
    required this.holdUuid,
    required this.remainingSeconds,
    this.remainingHours,
    this.expirationMessage,
    this.employee,
    this.startsAt,
    this.endsAt,
    this.holdExpiresAt,
  });

  factory BookingCartItemModel.fromJson(Map<String, dynamic> json) =>
      BookingCartItemModel(
        uuid: _text(json['uuid']),
        type: _text(json['type']),
        name: _text(json['name']),
        providerUuid: _text(json['provider_uuid']),
        branchUuid: _text(json['branch_uuid']),
        employee: json['employee'] is Map<String, dynamic>
            ? BookingCartEmployeeModel.fromJson(
                json['employee'] as Map<String, dynamic>,
              )
            : null,
        startsAt: _date(json['starts_at']),
        endsAt: _date(json['ends_at']),
        price: _number(json['price']),
        currencyCode: _text(json['currency_code']),
        holdUuid: _text(json['hold_uuid']),
        holdExpiresAt: _date(json['hold_expires_at']),
        remainingSeconds: _integer(json['remaining_seconds']),
        remainingHours: _nullableNumber(json['remaining_hours']),
        expirationMessage: _nullableText(json['expiration_message']),
      );
}

class BookingCartEmployeeModel {
  final String uuid, name;
  const BookingCartEmployeeModel({required this.uuid, required this.name});

  factory BookingCartEmployeeModel.fromJson(Map<String, dynamic> json) =>
      BookingCartEmployeeModel(
        uuid: _text(json['uuid']),
        name: _text(json['name']),
      );
}

class BookingCartCheckoutModel {
  final String bookingUuid, status;
  const BookingCartCheckoutModel({
    required this.bookingUuid,
    required this.status,
  });

  factory BookingCartCheckoutModel.fromJson(Map<String, dynamic> json) =>
      BookingCartCheckoutModel(
        bookingUuid: _text(json['booking_uuid']),
        status: _text(json['status']),
      );
}

List<T> _models<T>(dynamic value, T Function(Map<String, dynamic>) parser) =>
    value is List
    ? value
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(growable: false)
    : <T>[];

String _text(dynamic value) => value?.toString().trim() ?? '';
int _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(_text(value)) ?? 0;
double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(_text(value)) ?? 0;
int? _nullableInteger(dynamic value) => value == null
    ? null
    : value is num
    ? value.toInt()
    : int.tryParse(_text(value));
double? _nullableNumber(dynamic value) => value == null
    ? null
    : value is num
    ? value.toDouble()
    : double.tryParse(_text(value));
String? _nullableText(dynamic value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) => DateTime.tryParse(_text(value));

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};
