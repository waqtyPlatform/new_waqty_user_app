/// **Waqty Design Kit** — الواجهة العامة الوحيدة.
///
/// أي حاجة بتستخدم الكيت بتكتب سطر واحد:
///
/// ```dart
/// import 'package:<your_app>/design_system/design_system.dart';
/// ```
///
/// ⚠ الملف ده هو **الوحيد** اللي بيتكتب فيه `package:` عند المتبنّي. كل
/// الـ imports **جوه** `design_system/` relative، عشان الفولدر يتنسخ في أي
/// تطبيق بأي اسم على أي عمق من غير ولا تعديل. `portability_test.dart` هو
/// اللي بيفرض ده.
library;

// ── التوكنز ────────────────────────────────────────────────────────────
export 'tokens/app_entity_tint.dart';
export 'tokens/app_gradients.dart';
export 'tokens/app_icons.dart';
export 'tokens/app_motion.dart';
export 'tokens/app_palette.dart';
export 'tokens/app_radius.dart';
export 'tokens/app_semantic_colors.dart';
export 'tokens/app_shadows.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_text_styles.dart';

// ── الثيم ──────────────────────────────────────────────────────────────
export 'theme/app_theme.dart';

// ── التنسيق (قرارات السوق — الملف الوحيد اللي بيتغيّر لسوق تاني) ────────
export 'format/app_format.dart';

// ── الأسطح والتخطيط ────────────────────────────────────────────────────
export 'widgets/app_dashed_divider_widget.dart';
export 'widgets/app_hairline_widget.dart';
export 'widgets/app_layout_widgets.dart';
export 'widgets/app_row_widget.dart';
export 'widgets/app_screen_header_widget.dart';
export 'widgets/app_section_header_widget.dart';
export 'widgets/app_surface_widget.dart';

// ── الأفعال ────────────────────────────────────────────────────────────
export 'widgets/app_button_widget.dart';
export 'widgets/app_chip_widget.dart';
export 'widgets/app_icon_button_widget.dart';
export 'widgets/app_quantity_widget.dart';
export 'widgets/app_segmented_widget.dart';
export 'widgets/app_tab_bar_widget.dart';

// ── الحالة والداتا ─────────────────────────────────────────────────────
export 'widgets/app_amount_widget.dart';
export 'widgets/app_banner_widget.dart';
export 'widgets/app_detail_row_widget.dart';
export 'widgets/app_menu_row_widget.dart';
export 'widgets/app_pill_widget.dart';
export 'widgets/app_progress_widget.dart';
export 'widgets/app_rating_widget.dart';
export 'widgets/app_stat_tile_widget.dart';
export 'widgets/app_stepper_widget.dart';
export 'widgets/directional_chevron_widget.dart';

// ── الإدخال ────────────────────────────────────────────────────────────
export 'widgets/app_choice_row_widget.dart';
export 'widgets/app_drop_down_field.dart';
export 'widgets/app_pin_code_field_widget.dart';
export 'widgets/app_search_field_widget.dart';
export 'widgets/app_text_field.dart';
export 'widgets/app_toggle_widget.dart';

// ── التغذية الراجعة والحالات ───────────────────────────────────────────
export 'widgets/app_accordion_widget.dart';
export 'widgets/app_dialog_widget.dart';
export 'widgets/app_network_image_widget.dart';
export 'widgets/app_sheet_widget.dart';
export 'widgets/app_skeleton_widget.dart';
export 'widgets/app_state_widgets.dart';

// ── الهوية ─────────────────────────────────────────────────────────────
export 'widgets/entity_avatar_widget.dart';

// ── الإصدار ────────────────────────────────────────────────────────────
export 'kit_version.dart';
