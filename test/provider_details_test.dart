import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_catalog.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_model.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_preview.dart';
import 'package:waqty_user_application/features/home/provider_details/data/repo/provider_details_repo.dart';
import 'package:waqty_user_application/features/home/provider_details/data/services/provider_details_service.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_cubit.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_state.dart';
import 'package:waqty_user_application/features/home/provider_details/ui/provider_details_screen.dart';
import 'package:waqty_user_application/features/home/provider_details/ui/widgets/provider_details_shimmer.dart';

class _Api extends Fake implements ApiConsumer {}

class _Repo extends ProviderDetailsRepo {
  _Repo() : super(ProviderDetailsService(apiConsumer: _Api()));
  @override
  Future<ProviderCatalog> loadPreview() async => providerDetailsPreview;
}

class _PendingRepo extends _Repo {
  final result = Completer<ProviderCatalog>();
  @override
  Future<ProviderCatalog> loadPreview() => result.future;
}

const provider = ProviderDetailsModel(
  uuid: 'preview',
  name: '',
  rating: 4.9,
  reviewsCount: 312,
);
final captureKey = GlobalKey();
final translations = <String, Map<String, dynamic>>{};

class _Translations extends AssetLoader {
  const _Translations();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations[locale.toString()]!;
}

Future<void> mount(
  WidgetTester tester,
  ProviderDetailsCubit cubit,
  Locale locale,
  Size size, {
  bool loading = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      startLocale: locale,
      saveLocale: false,
      path: 'assets/languages',
      assetLoader: const _Translations(),
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(fontFamily: 'IBMPlexSansArabic', useMaterial3: true),
          home: BlocProvider.value(
            value: cubit,
            child: RepaintBoundary(
              key: captureKey,
              child: const ProviderDetailsScreen(provider: provider),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage('assets/figma/provider_details/70959.png'),
      tester.element(find.byType(MaterialApp)),
    );
  });
  await tester.pump(const Duration(milliseconds: 300));
  if (!loading) {
    await cubit.initialize(provider);
    await tester.pumpAndSettle();
  }
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_PROVIDER')) return;
  final boundary =
      captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final img = await boundary.toImage();
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/provider_details_previews').create(recursive: true);
    await File(
      'build/provider_details_previews/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    img.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    for (final locale in ['ar-EG', 'en-US']) {
      translations[locale.replaceAll('-', '_')] =
          jsonDecode(
                await rootBundle.loadString('assets/languages/$locale.json'),
              )
              as Map<String, dynamic>;
    }
    final loader = FontLoader('IBMPlexSansArabic');
    loader.addFont(
      rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
    );
    await loader.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  test('Service totals, independent tabs and branch reset', () async {
    final cubit = ProviderDetailsCubit(_Repo());
    await cubit.initialize(provider);
    var loaded = cubit.state as ProviderDetailsLoaded;
    expect(loaded.totalPrice, 370);
    expect(loaded.totalMinutes, 65);
    cubit.toggleService('hair');
    loaded = cubit.state as ProviderDetailsLoaded;
    expect(loaded.totalPrice, 120);
    cubit.toggleService('color-roots');
    expect((cubit.state as ProviderDetailsLoaded).totalPrice, 320);
    cubit.selectSpecialist('ahmed');
    cubit.selectTab(ProviderDetailsTab.packages);
    expect((cubit.state as ProviderDetailsLoaded).selectedIds, {
      'beard',
      'color-roots',
    });
    cubit.selectBranch(1);
    loaded = cubit.state as ProviderDetailsLoaded;
    expect(loaded.selectedIds, isEmpty);
    expect(loaded.specialistId, isNull);
    expect(loaded.branch.packages, isEmpty);
    expect(loaded.branch.namedStaff, isFalse);
    await cubit.close();
  });

  for (final locale in [const Locale('ar', 'EG'), const Locale('en', 'US')]) {
    testWidgets('Tabs, selection and empty states: ${locale.languageCode}', (
      tester,
    ) async {
      final cubit = ProviderDetailsCubit(_Repo());
      await mount(tester, cubit, locale, const Size(375, 1000));
      expect(tester.takeException(), isNull);
      await capture(tester, '${locale.languageCode}-services');
      await tester.ensureVisible(find.byKey(const ValueKey('service-hair')));
      await tester.tap(find.byKey(const ValueKey('service-hair')));
      await tester.pumpAndSettle();
      expect((cubit.state as ProviderDetailsLoaded).totalPrice, 120);
      for (final tab in [
        ProviderDetailsTab.specialists,
        ProviderDetailsTab.packages,
        ProviderDetailsTab.information,
      ]) {
        await tester.ensureVisible(find.byKey(ValueKey('tab-${tab.name}')));
        await tester.tap(find.byKey(ValueKey('tab-${tab.name}')));
        await tester.pumpAndSettle();
        expect((cubit.state as ProviderDetailsLoaded).tab, tab);
        expect(tester.takeException(), isNull);
        await capture(tester, '${locale.languageCode}-${tab.name}');
      }
      cubit.selectBranch(1);
      cubit.selectTab(ProviderDetailsTab.packages);
      await tester.pumpAndSettle();
      expect(
        find.text(
          locale.languageCode == 'ar'
              ? 'هذا المكان لا يقدّم باقات'
              : 'This place does not offer packages',
        ),
        findsOneWidget,
      );
      await capture(tester, '${locale.languageCode}-empty-packages');
      cubit.selectTab(ProviderDetailsTab.specialists);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, '${locale.languageCode}-unnamed');
      await tester.pumpWidget(const SizedBox());
      await cubit.close();
    });
  }
  testWidgets('320px width and large text remain within layout', (
    tester,
  ) async {
    final cubit = ProviderDetailsCubit(_Repo());
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester, cubit, const Locale('en', 'US'), const Size(320, 700));
    for (final tab in ProviderDetailsTab.values) {
      cubit.selectTab(tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await cubit.close();
  });
  testWidgets(
    'Loading has its own skeleton and completes after unmount safely',
    (tester) async {
      final repo = _PendingRepo();
      final cubit = ProviderDetailsCubit(repo);
      tester.view.physicalSize = const Size(375, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(
        tester,
        cubit,
        const Locale('ar', 'EG'),
        const Size(375, 1000),
        loading: true,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ProviderDetailsShimmer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, 'shimmer');
      await tester.pumpWidget(const SizedBox());
      await cubit.close();
      repo.result.complete(providerDetailsPreview);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
