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
    this.addedItem,
    this.expiresAt,
    this.serverTime,
    this.expiresInSeconds,
    this.expiresInHours,
    this.expirationMessage,
  });

  factory BookingCartModel.fromJson(Map<String, dynamic> json) =>
      BookingCartModel(
        uuid: _text(json['cart_uuid']),
        addedItem: json['item'] is Map<String, dynamic>
            ? BookingCartItemModel.fromJson(
                json['item'] as Map<String, dynamic>,
              )
            : null,
        items: _models(json['items'], BookingCartItemModel.fromJson),
        itemsCount: _integer(json['items_count']),
        subtotal: _number(json['subtotal']),
        currencyCode: _text(json['currency_code']),
        expiresAt: _date(json['expires_at']),
        serverTime: _date(json['server_time']),
        expiresInSeconds: _nullableInteger(json['expires_in_seconds']),
        expiresInHours: _nullableNumber(json['expires_in_hours']),
        expirationMessage: _nullableText(json['expiration_message']),
      );
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
