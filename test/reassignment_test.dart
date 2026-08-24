import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';

/// **عقد إعادة توزيع الحجز.**
///
/// الـJSON منقول من `BookingReassignmentResource` حرف بحرف.
///
/// التلات حاجات اللي بيقفلهم:
///
/// | | ليه |
/// |---|---|
/// | العدّاد من `hold_expires_at` | `hold_remaining_seconds` لقطة بتبوظ في الخلفية |
/// | `active_proposal: null` بيتقرا | الفرع بيدوّر = مفيش اقتراح، مش خطأ |
/// | `attempts` مقابل `max_attempts` | آخر محاولة ليها تحذير مختلف |
void main() {
  setUp(() => MockConfig.delay = Duration.zero);
  tearDown(() => MockConfig.delay = const Duration(milliseconds: 600));

  /// الرد زي ما `BookingReassignmentResource` بيبنيه.
  Map<String, dynamic> serverJson({
    String status = 'awaiting_customer',
    int attempts = 1,
    Object? activeProposal = _sentinel,
  }) => {
    'uuid': '01KZHF7KVH440GQ3A9VW5GRS8V',
    'status': status,
    'attempts': attempts,
    'max_attempts': 3,
    'booking': {
      'uuid': '01KZHF7137MZVBQTCEATD92ETE',
      'status': 'confirmed',
      'original': {
        'employee': 'كريم سمير',
        'date': '2026-09-07',
        'start_at': '2026-09-07T18:00:00+03:00',
        'end_at': '2026-09-07T18:45:00+03:00',
        'service': 'قص شعر',
      },
    },
    'active_proposal': identical(activeProposal, _sentinel)
        ? {
            'uuid': 'prop-1',
            'attempt_number': 1,
            'employee': 'محمود عادل',
            'start_at': '2026-09-07T20:00:00+03:00',
            'end_at': '2026-09-07T20:45:00+03:00',
            'price': '250.00',
            'currency': 'EGP',
            'reason': 'employee_leave',
            'branch_message': 'كريم طالع إجازة.',
            'hold_expires_at': '2026-09-07T12:15:00+03:00',
            'hold_remaining_seconds': 900,
          }
        : activeProposal,
    'conversation': [
      {
        'uuid': 'msg-1',
        'sender_type': 'system',
        'type': 'system',
        'body': 'الأخصائي مش متاح في ميعادك.',
        'created_at': '2026-09-07T12:00:00+03:00',
      },
      {
        'uuid': 'msg-2',
        'sender_type': 'branch',
        'type': 'text',
        'body': 'محمود متاح الساعة ٨.',
        'created_at': '2026-09-07T12:01:00+03:00',
      },
    ],
  };

  group('ReassignmentUiModel.fromJson', () {
    test('الرد الكامل بيتقرا صح', () {
      final model = ReassignmentUiModel.fromJson(serverJson());

      expect(model.uuid, '01KZHF7KVH440GQ3A9VW5GRS8V');
      expect(model.status, ReassignmentStatus.awaitingCustomer);
      expect(model.attempts, 1);
      expect(model.maxAttempts, 3);
      expect(model.bookingUuid, '01KZHF7137MZVBQTCEATD92ETE');
      expect(model.serviceName, 'قص شعر');
      expect(model.originalEmployeeName, 'كريم سمير');
      expect(model.originalStartAt, isNotNull);
      expect(model.conversation.length, 2);
    });

    test('السعر نص "250.00" بيتحوّل رقم', () {
      final model = ReassignmentUiModel.fromJson(serverJson());
      expect(model.activeProposal!.price, 250);
    });

    test('⚠ active_proposal: null مش خطأ — الفرع بيدوّر', () {
      final model = ReassignmentUiModel.fromJson(
        serverJson(status: 'change_requested', activeProposal: null),
      );

      expect(model.activeProposal, isNull);
      expect(model.status, ReassignmentStatus.changeRequested);
      expect(model.needsMyAnswer, isFalse);
      expect(model.isHoldActive(DateTime.now()), isFalse);
    });

    test('نوع المرسل بيتقرا للتلاتة', () {
      final model = ReassignmentUiModel.fromJson(serverJson());

      expect(model.conversation[0].sender, ReassignmentSender.system);
      expect(model.conversation[1].sender, ReassignmentSender.branch);
      expect(model.conversation[0].isMine, isFalse);
    });

    test('حالة مش معروفة بتبقى unknown مش استثناء', () {
      final model = ReassignmentUiModel.fromJson(
        serverJson(status: 'some_new_status_from_the_future'),
      );

      expect(model.status, ReassignmentStatus.unknown);
      expect(model.status.label, '—');
    });
  });

  group('⚠ المهلة بتتحسب من hold_expires_at مش من اللقطة', () {
    test('اللحظة المطلقة هي الحكم', () {
      final now = DateTime.now();

      final proposal = ReassignmentProposalUiModel.fromJson({
        'uuid': 'p',
        'employee': 'محمود',
        'start_at': now.toIso8601String(),
        'end_at': now.toIso8601String(),
        'hold_expires_at': now.add(const Duration(minutes: 10)).toIso8601String(),
        // اللقطة **بتكدب**: بتقول ١٥ دقيقة والمطلقة بتقول ١٠.
        'hold_remaining_seconds': 900,
      });

      expect(proposal.remainingSeconds(now), closeTo(600, 2));
      expect(proposal.isHoldActive(now), isTrue);
    });

    test('مهلة راحت بترجّع صفر مش رقم سالب', () {
      final now = DateTime.now();

      final proposal = ReassignmentProposalUiModel.fromJson({
        'uuid': 'p',
        'start_at': now.toIso8601String(),
        'hold_expires_at':
            now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'hold_remaining_seconds': 0,
      });

      expect(proposal.remainingSeconds(now), 0);
      expect(proposal.isHoldActive(now), isFalse);
    });

    test('لو hold_expires_at ناقصة بتتحسب من الثواني كاحتياطي', () {
      final now = DateTime.now();

      final proposal = ReassignmentProposalUiModel.fromJson({
        'uuid': 'p',
        'start_at': now.toIso8601String(),
        'hold_remaining_seconds': 300,
      });

      // احتياطي معقول أحسن من مهلة منتهية بالغلط على اقتراح شغّال.
      expect(proposal.remainingSeconds(now), closeTo(300, 2));
      expect(proposal.isHoldActive(now), isTrue);
    });
  });

  group('عدّاد المحاولات', () {
    test('محاولة ٢ من ٣ = آخر محاولة', () {
      final model = ReassignmentUiModel.fromJson(serverJson(attempts: 2));
      expect(model.isLastAttempt, isTrue);
    });

    test('محاولة ١ من ٣ لسه فيه فرصة', () {
      final model = ReassignmentUiModel.fromJson(serverJson(attempts: 1));
      expect(model.isLastAttempt, isFalse);
    });
  });

  group('الحالات المفتوحة', () {
    test('اللي فيها دور للعميل أو للفرع', () {
      expect(ReassignmentStatus.awaitingCustomer.isOpen, isTrue);
      expect(ReassignmentStatus.changeRequested.isOpen, isTrue);
    });

    test('اللي خلصت', () {
      expect(ReassignmentStatus.applied.isOpen, isFalse);
      expect(ReassignmentStatus.cancelled.isOpen, isFalse);
      expect(ReassignmentStatus.noAgreement.isOpen, isFalse);
    });
  });
}

/// علامة «مامرّرش القيمة» — عشان نفرّق بين «سيب الافتراضي» و«حطّ `null`».
const Object _sentinel = Object();
