import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';

import 'booking_cart_api_end_points.dart';
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

  Future<BookingCartModel?> getCart() async => _cart(
    await apiConsumer.get(BookingCartApiEndPoints.cart, await _authHeaders()),
  );

  Future<BookingCartModel> addItem(BookingCartAddRequest request) async =>
      _requiredCart(
        await apiConsumer.post(
          BookingCartApiEndPoints.items,
          request.toJson(),
          await _authHeaders(),
        ),
      );

  Future<BookingCartModel?> updateItem({
    required String itemUuid,
    required String slotToken,
    String? employeeUuid,
  }) async => _cart(
    await apiConsumer.patch(BookingCartApiEndPoints.item(itemUuid), {
      'slot_token': slotToken,
      'employee_uuid': employeeUuid,
    }, await _authHeaders()),
  );

  Future<BookingCartModel?> deleteItem(String itemUuid) async => _cart(
    await apiConsumer.delete(
      BookingCartApiEndPoints.item(itemUuid),
      null,
      await _authHeaders(),
    ),
  );

  Future<void> clear() async {
    _decode(
      await apiConsumer.delete(
        BookingCartApiEndPoints.cart,
        null,
        await _authHeaders(),
      ),
    );
  }

  Future<BookingCartCheckoutModel> checkout({
    required String cartUuid,
    required String idempotencyKey,
    String paymentMethod = 'cash',
  }) async {
    final data = _decode(
      await apiConsumer.post(BookingCartApiEndPoints.checkout, {
        'cart_uuid': cartUuid,
        'payment_method': paymentMethod,
        'idempotency_key': idempotencyKey,
      }, await _authHeaders()),
    );
    final checkout = BookingCartCheckoutModel.fromJson(_map(data));
    if ((checkout.bookingUuid == null || checkout.bookingUuid!.isEmpty) &&
        checkout.purchases.isEmpty) {
      throw const BookingCartApiException(
        code: 'EMPTY_CHECKOUT_RESPONSE',
        message: 'Checkout response did not include a booking UUID.',
      );
    }
    return checkout;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};

    final normalizedToken = token.toLowerCase().startsWith('bearer ')
        ? token.substring('bearer '.length).trim()
        : token;
    return {
      ConstantKeys.appAuthorization:
          '${ConstantKeys.appBearer} $normalizedToken',
    };
  }

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
