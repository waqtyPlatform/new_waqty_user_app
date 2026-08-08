import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';
import 'package:waqty_user_application/core/widgets/empty_state_widget.dart';
import 'package:waqty_user_application/core/widgets/loading_widget.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_state.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/widgets/waitlist_card_widget.dart';

/// كل إدخالات العميل في قوائم الانتظار.
///
/// ## ليه شاشة مستقلة والكارت موجود في الرئيسية
///
/// كارت الرئيسية بيعرض **الشغّال بس** — وده صح هناك: الرئيسية شاشة
/// «اعمل إيه دلوقتي»، والإدخال اللي خلص مالوش فعل. بس ده معناه إن
/// العميل اللي دخل تلات قوايم مايقدرش يشوفهم كلهم في مكان واحد،
/// ومايعرفش أبدًا إيه اللي حصل في اللي خلصوا.
///
/// ## الترتيب: الشغّال فوق
///
/// الترتيب مش زمني. الإدخال اللي فيه عرض شغّال بعدّاد بينزل هو الوحيد
/// اللي فيه وقت بيجري، فبيقعد فوق مهما كان قديم. تحته اللي لسه في
/// القائمة، وتحتهم اللي خلصوا.
///
/// **مفيش تبويبات.** العميل العادي عنده إدخال أو اتنين — تبويبين على
/// تلات كروت بيخبّوا نص المحتوى ورا دوسة عشان ينظّموا حاجة مش محتاجة
/// تنظيم.
class WaitlistScreen extends StatelessWidget {
  const WaitlistScreen({super.key});

  /// **بيدفع الشاشة بالـ cubit الموجود مش بواحد جديد.**
  ///
  /// مافيش راوت مسمّى للشاشة دي بالقصد. الراوت المسمّى بيتبني من
  /// `onGenerateRoute` اللي مالوش وصول للشجرة، فكان لازم يعمل
  /// `WaitlistCubit` جديد — يعني **مؤقتين بينبضوا على نفس العدّاد**.
  /// الاتنين بيقروا `MockWaitlist` في لحظتين مختلفتين، فالعدّاد في
  /// الرئيسية والعدّاد في الشاشة يقدروا يعرضوا رقمين مختلفين لنفس العرض.
  ///
  /// لازم تتنادى من context تحت `ButtonNavigationBarScreen`.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<WaitlistCubit>.value(
          value: WaitlistCubit.get(context),
          child: const WaitlistScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      appBar: AppBar(
        backgroundColor: AppSemanticColors.page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          // `back` مش معناها «شمال» — الـ widget بيسمّي الاتجاه بمعناه
          // في اتجاه القراءة وفلاتر بيعكس الأيقونة لوحده في العربي.
          icon: const DirectionalChevronWidget(
            direction: ChevronDirection.back,
          ),
        ),
        title: Text('قايمة الانتظار', style: AppTextStyles.titleLg),
      ),
      body: BlocBuilder<WaitlistCubit, WaitlistState>(
        builder: (context, state) {
          if (state is WaitlistLoadingState || state is WaitlistInitialState) {
            return LoadingWidget(color: AppSemanticColors.accent);
          }

          if (state is WaitlistEmptyState) {
            return const _EmptyWaitlist();
          }

          final ready = state as WaitlistReadyState;
          final now = DateTime.now();
          final entries = _sorted(ready.entries, now);

          return ListView.separated(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.s16.w,
              AppSpacing.s16.h,
              AppSpacing.s16.w,
              AppSpacing.s24.h,
            ),
            itemCount: entries.length + 1,
            separatorBuilder: (_, __) => verticalSpace(AppSpacing.s12),
            itemBuilder: (context, index) {
              if (index == 0) return const _WaitlistIntro();

              final entry = entries[index - 1];
              return WaitlistCardWidget(
                entry: entry,
                now: now,
                onRemove: entry.status.canLeaveQueue
                    ? () => WaitlistCubit.get(context).removeEntry(entry.uuid)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  /// الشغّال فوق، وجوّه الشغّال العرض المحجوز فوق الكل.
  ///
  /// بيتعمل على نسخة — `ready.entries` هي نفس ليستة الـ cubit، وترتيبها
  /// في مكانها بيعيد ترتيب مصدر الحقيقة من جوه `build`.
  static List<WaitlistUiModel> _sorted(
    List<WaitlistUiModel> entries,
    DateTime now,
  ) {
    int rank(WaitlistUiModel e) {
      if (e.isHoldActive(now)) return 0;
      if (e.status.isLive) return 1;
      return 2;
    }

    return <WaitlistUiModel>[...entries]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      // نفس المرتبة؟ الأقرب ميعادًا الأول — ده الترتيب اللي العميل
      // بيفكّر بيه لما الحالة واحدة.
      return byRank != 0 ? byRank : a.preferredAt.compareTo(b.preferredAt);
    });
  }
}

/// سطر بيقول الميزة بتعمل إيه — **مرة واحدة فوق، مش على كل كارت**.
class _WaitlistIntro extends StatelessWidget {
  const _WaitlistIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s4.h),
      child: Text(
        'لما ميعاد يفضى في يوم إنت مستنيه، الفرع بيتصل بالناس اللي في '
        'القايمة بالترتيب.',
        style: AppTextStyles.caption.copyWith(
          color: AppSemanticColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyWaitlist extends StatelessWidget {
  const _EmptyWaitlist();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.hourglass_empty_rounded,
      title: 'مش في أي قايمة انتظار',
      // **بيقول إزاي يدخل واحدة.** حالة فاضية بتوصف الفراغ بس بتسيب
      // العميل يخمّن الميزة دي بتتفتح منين — وهي بتتفتح من جوه شاشة
      // محل لما اليوم اللي عايزه مايبقاش فيه مواعيد.
      message: 'لو اليوم اللي عايزه مافيهوش مواعيد، تقدر تدخل قايمة '
          'الانتظار من صفحة المحل.',
    );
  }
}
