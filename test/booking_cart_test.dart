import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/models/booking_cart_model.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/services/booking_cart_service.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_cubit.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_timer_cubit.dart';

class _Api extends Fake implements ApiConsumer {
  final http.Response response;
  String? path;
  Map<String, dynamic>? body;

  _Api(this.response);

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    this.path = path;
    this.body = body;
    return response;
  }
}

void main() {
  test(
    'add request sends identifiers only without client price or duration',
    () {
      final json = BookingCartAddRequest(
        providerUuid: 'provider-1',
        branchUuid: 'branch-1',
        itemType: BookingCartItemType.service,
        serviceUuid: 'service-1',
        slotToken: 'slot-token',
        idempotencyKey: 'request-1',
      ).toJson();

      expect(json['item_type'], 'service');
      expect(json['service_uuid'], 'service-1');
      expect(json.containsKey('employee_uuid'), isFalse);
      expect(json.containsKey('price'), isFalse);
      expect(json.containsKey('duration'), isFalse);
    },
  );

  test('parses cart and nullable employee using server timestamps', () {
    final cart = BookingCartModel.fromJson({
      'cart_uuid': 'cart-1',
      'items_count': 1,
      'subtotal': 300,
      'currency_code': 'EGP',
      'expires_at': '2026-10-13T10:15:00+03:00',
      'server_time': '2026-10-13T10:00:00+03:00',
      'expires_in_seconds': 43200,
      'expires_in_hours': 12,
      'expiration_message': 'Reserved for 12 hours',
      'items': [
        {
          'uuid': 'item-1',
          'type': 'service',
          'name': 'Haircut',
          'provider_uuid': 'provider-1',
          'branch_uuid': 'branch-1',
          'employee': null,
          'starts_at': '2026-10-13T11:00:00+03:00',
          'ends_at': '2026-10-13T11:30:00+03:00',
          'price': 300,
          'currency_code': 'EGP',
          'hold_uuid': 'hold-1',
          'hold_expires_at': '2026-10-13T10:15:00+03:00',
          'remaining_seconds': 900,
          'remaining_hours': 12,
          'expiration_message': 'Reserved for 12 hours',
        },
      ],
    });

    expect(cart.items.single.employee, isNull);
    expect(cart.expiresAt!.difference(cart.serverTime!).inMinutes, 15);
    expect(cart.subtotal, 300);
    expect(cart.expiresInSeconds, 43200);
    expect(cart.expiresInHours, 12);
    expect(cart.expirationMessage, 'Reserved for 12 hours');
    expect(cart.items.single.remainingHours, 12);
  });

  test('add item calls cart endpoint and parses returned cart', () async {
    final api = _Api(
      http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'cart_uuid': 'cart-1',
            'item': null,
            'items': [],
            'items_count': 1,
            'subtotal': 300,
            'currency_code': 'EGP',
            'expires_at': '2026-10-13T10:15:00+03:00',
            'server_time': '2026-10-13T10:00:00+03:00',
          },
        }),
        201,
      ),
    );
    final service = BookingCartService(apiConsumer: api);
    final cart = await service.addItem(
      BookingCartAddRequest(
        providerUuid: 'provider-1',
        branchUuid: 'branch-1',
        itemType: BookingCartItemType.package,
        packageUuid: 'package-1',
        slotToken: 'slot-token',
        idempotencyKey: 'request-1',
      ),
    );

    expect(api.path, endsWith('/user/booking-cart/items'));
    expect(api.body?['item_type'], 'package');
    expect(cart.itemsCount, 1);
  });

  test('parses booking cart error codes', () async {
    final service = BookingCartService(
      apiConsumer: _Api(
        http.Response(
          jsonEncode({
            'success': false,
            'error': {'code': 'SLOT_UNAVAILABLE'},
          }),
          409,
        ),
      ),
    );

    expect(
      () => service.addItem(
        BookingCartAddRequest(
          providerUuid: 'provider-1',
          branchUuid: 'branch-1',
          itemType: BookingCartItemType.service,
          serviceUuid: 'service-1',
          slotToken: 'slot-token',
          idempotencyKey: 'request-1',
        ),
      ),
      throwsA(
        isA<BookingCartApiException>().having(
          (error) => error.code,
          'code',
          'SLOT_UNAVAILABLE',
        ),
      ),
    );
  });

  test('idempotency keys are UUID v4 values', () {
    final first = newIdempotencyKey();
    final second = newIdempotencyKey();
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(first, matches(pattern));
    expect(second, matches(pattern));
    expect(first, isNot(second));
  });

  test('cart timer starts from server time', () async {
    final timer = BookingCartTimerCubit(
      serverTime: DateTime.parse('2026-10-13T10:00:00+03:00'),
      expiresAt: DateTime.parse('2026-10-13T10:15:00+03:00'),
    );

    expect(timer.state, 900);
    await timer.close();
  });

  test('cart timer uses the exact duration returned by server', () async {
    final timer = BookingCartTimerCubit(
      remainingSeconds: 129600,
      serverTime: DateTime.parse('2026-10-13T10:00:00+03:00'),
      expiresAt: DateTime.parse('2026-10-13T10:15:00+03:00'),
    );

    expect(timer.state, 129600);
    await timer.close();
  });
}
