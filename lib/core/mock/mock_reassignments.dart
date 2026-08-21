import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';

/// فكسشرز إعادة توزيع الحجز.
///
/// ## ليه دي مهمة أكتر من غيرها
///
/// الفلو ده **بمهلة ١٥ دقيقة**. عشان تراجع الشاشة على سيرفر حقيقي لازم:
/// موظف يخرج إجازة، وحجز جاي من الأبلكيشن يقع في الفترة، وموظف فرع يقترح
/// بديل — وبعدين تراجع في ١٥ دقيقة قبل ما المهلة تخلص. وعشان تراجع حالة
/// «المهلة راحت» تستنى ١٥ دقيقة كاملة.
///
/// فالسيناريوهات هنا مش رفاهية، دي الطريقة الوحيدة إن الحالات دي تتشاف
/// في مراجعة تصميم.
class MockReassignments {
  const MockReassignments._();

  /// بينط لما حاجة تتغيّر — الـcubit بيعيد القراءة.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// الحالات اللي العميل شالها في الجلسة دي (قبول/رفض/إلغاء).
  static final Map<String, ReassignmentStatus> _overrides =
      <String, ReassignmentStatus>{};

  /// الرسايل اللي العميل بعتها في الجلسة دي.
  static final Map<String, List<ReassignmentMessageUiModel>> _sent =
      <String, List<ReassignmentMessageUiModel>>{};

  static void reset() {
    _overrides.clear();
    _sent.clear();
    revision.value++;
  }

  static List<ReassignmentUiModel> forUser(DateTime now) {
    final base = switch (MockConfig.scenario) {
      MockScenario.emptyState => const <ReassignmentUiModel>[],
      _ => <ReassignmentUiModel>[_awaitingCustomer(now)],
    };

    return base.map((entry) => _applyOverrides(entry)).toList();
  }

  static ReassignmentUiModel? byUuid(String uuid, DateTime now) {
    final matches = forUser(now).where((e) => e.uuid == uuid);
    return matches.isEmpty ? null : matches.first;
  }

  static void accept(String proposalUuid) {
    _overrides[_ownerOf(proposalUuid)] = ReassignmentStatus.applied;
    revision.value++;
  }

  static void requestChange(String proposalUuid, String note) {
    final owner = _ownerOf(proposalUuid);
    _overrides[owner] = ReassignmentStatus.changeRequested;
    _appendMessage(owner, note);
    revision.value++;
  }

  static void cancel(String proposalUuid) {
    _overrides[_ownerOf(proposalUuid)] = ReassignmentStatus.cancelled;
    revision.value++;
  }

  static void sendMessage(String uuid, String body) {
    _appendMessage(uuid, body);
    revision.value++;
  }

  // ── الداخل ────────────────────────────────────────────────────────────

  static const String _uuid = 'rsg-1';
  static const String _proposalUuid = 'rsg-1-prop-1';

  /// الفكسشر واحد فبالمفتاح ثابت. لو بقوا أكتر، الربط بيتعمل بخريطة.
  static String _ownerOf(String proposalUuid) => _uuid;

  static void _appendMessage(String uuid, String body) {
    if (body.trim().isEmpty) return;
    _sent.putIfAbsent(uuid, () => <ReassignmentMessageUiModel>[]).add(
      ReassignmentMessageUiModel(
        uuid: 'msg-${DateTime.now().microsecondsSinceEpoch}',
        sender: ReassignmentSender.customer,
        body: body.trim(),
        createdAt: DateTime.now(),
      ),
    );
  }

  static ReassignmentUiModel _applyOverrides(ReassignmentUiModel entry) {
    final status = _overrides[entry.uuid];
    final extra = _sent[entry.uuid] ?? const <ReassignmentMessageUiModel>[];

    if (status == null && extra.isEmpty) return entry;

    return ReassignmentUiModel(
      uuid: entry.uuid,
      status: status ?? entry.status,
      attempts: status == ReassignmentStatus.changeRequested
          ? entry.attempts + 1
          : entry.attempts,
      maxAttempts: entry.maxAttempts,
      bookingUuid: entry.bookingUuid,
      serviceName: entry.serviceName,
      originalEmployeeName: entry.originalEmployeeName,
      originalStartAt: entry.originalStartAt,
      originalEndAt: entry.originalEndAt,
      // الاقتراح بيختفي أول ما العميل يرد — نفس اللي السيرفر بيعمله.
      activeProposal: status == null ? entry.activeProposal : null,
      conversation: [...entry.conversation, ...extra],
    );
  }

  /// **الحالة الأساسية: الفرع اقترح بديل والعميل عليه الدور.**
  ///
  /// المهلة بتبدأ من **دلوقتي** كل مرة الفكسشر تتقرا، عشان العدّاد يبان
  /// شغّال في المراجعة بدل ما يبقى منتهي.
  static ReassignmentUiModel _awaitingCustomer(DateTime now) {
    final original = DateTime(now.year, now.month, now.day + 2, 18);
    final proposed = DateTime(now.year, now.month, now.day + 2, 20);

    // ⚠ مهلة قصيرة في السيناريو ده عشان «راحت المهلة» تبقى قابلة للمراجعة
    // من غير ما حد يقعد ١٥ دقيقة قدام الشاشة.
    final holdMinutes =
        MockConfig.scenario == MockScenario.waitlistExpired ? 0 : 15;

    return ReassignmentUiModel(
      uuid: _uuid,
      status: ReassignmentStatus.awaitingCustomer,
      attempts: 1,
      bookingUuid: 'bkg-1',
      serviceName: 'قص شعر',
      originalEmployeeName: 'كريم سمير',
      originalStartAt: original,
      originalEndAt: original.add(const Duration(minutes: 45)),
      activeProposal: ReassignmentProposalUiModel(
        uuid: _proposalUuid,
        attemptNumber: 1,
        employeeName: 'محمود عادل',
        startAt: proposed,
        endAt: proposed.add(const Duration(minutes: 45)),
        holdExpiresAt: now.add(Duration(minutes: holdMinutes)),
        price: 250,
        reason: 'employee_leave',
        branchMessage: 'كريم طالع إجازة، محمود متاح نفس اليوم الساعة ٨.',
      ),
      conversation: [
        ReassignmentMessageUiModel(
          uuid: 'msg-sys-1',
          sender: ReassignmentSender.system,
          body: 'الأخصائي مش متاح في ميعادك، الفرع بيدوّر على بديل.',
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        ReassignmentMessageUiModel(
          uuid: 'msg-branch-1',
          sender: ReassignmentSender.branch,
          body: 'كريم طالع إجازة، محمود متاح نفس اليوم الساعة ٨.',
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
      ],
    );
  }
}
