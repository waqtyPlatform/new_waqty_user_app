import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/end_points.dart';

import '../models/booking_cart_model.dart';

class BookingCartApiException implements Exception {
  final String code, message;
  final List<String> expiredItemUuids;

  const BookingCartApiException({
    required this.code,
    required this.message,
    this.expiredItemUuids = const [],
  });
}

class BookingCartService {
  final ApiConsumer apiConsumer;
  const BookingCartService({required this.apiConsumer});

  Future<BookingCartModel?> getCart() async =>
      _cart(await apiConsumer.get(_url(''), null));

  Future<BookingCartModel> addItem(BookingCartAddRequest request) async =>
      _requiredCart(
        await apiConsumer.post(_url('/items'), request.toJson(), null),
      );

  Future<BookingCartModel?> updateItem({
    required String itemUuid,
    required String slotToken,
    String? employeeUuid,
  }) async => _cart(
    await apiConsumer.patch(_url('/items/${Uri.encodeComponent(itemUuid)}'), {
      'slot_token': slotToken,
      'employee_uuid': employeeUuid,
    }, null),
  );

  Future<BookingCartModel?> deleteItem(String itemUuid) async => _cart(
    await apiConsumer.delete(
      _url('/items/${Uri.encodeComponent(itemUuid)}'),
      null,
      null,
    ),
  );

  Future<void> clear() async {
    _decode(await apiConsumer.delete(_url(''), null, null));
  }

  Future<BookingCartCheckoutModel> checkout({
    required String cartUuid,
    required String idempotencyKey,
    String paymentMethod = 'cash',
  }) async {
    final data = _decode(
      await apiConsumer.post(_url('/checkout'), {
        'cart_uuid': cartUuid,
        'payment_method': paymentMethod,
        'idempotency_key': idempotencyKey,
      }, null),
    );
    return BookingCartCheckoutModel.fromJson(_map(data));
  }

  String _url(String suffix) => '${EndPoints.baseUrl}/user/booking-cart$suffix';

  BookingCartModel _requiredCart(dynamic response) {
    final cart = _cart(response);
    if (cart == null) {
      throw const BookingCartApiException(
        code: 'EMPTY_CART_RESPONSE',
        message: 'Empty cart response.',
      );
    }
    return cart;
  }

  BookingCartModel? _cart(dynamic response) {
    final data = _decode(response);
    return data is Map<String, dynamic>
        ? BookingCartModel.fromJson(data)
        : null;
  }

  dynamic _decode(dynamic response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded is Map<String, dynamic>) {
      return decoded['data'];
    }
    final root = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    final error = _map(root['error']);
    final errors = root['errors'];
    final expired = error['expired_item_uuids'];
    throw BookingCartApiException(
      code: _text(error['code']).isNotEmpty
          ? _text(error['code'])
          : 'REQUEST_FAILED',
      message: _validationMessage(errors) ?? _text(root['message']),
      expiredItemUuids: expired is List
          ? expired.map((item) => item.toString()).toList(growable: false)
          : const [],
    );
  }

  String? _validationMessage(dynamic errors) {
    if (errors is! Map<String, dynamic>) return null;
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value != null) return value.toString();
    }
    return null;
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};
String _text(dynamic value) => value?.toString().trim() ?? '';
