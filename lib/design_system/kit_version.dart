/// إصدار الكيت.
///
/// ## ⚠ خطوة صفر في التبنّي
///
/// الكيت **بيتنسخ مش بيتربط**، يعني مافيش انتشار تلقائي لأي تعديل. اللي
/// بيخلي ده قابل للإدارة إن كل نسخة تعرف **من فين جت**.
///
/// اللي بينسخ الكيت بيسجّل [kDesignKitVersion] و[kDesignKitSourceCommit]
/// في README تطبيقه. بعد كده أي مقارنة بتبقى `git diff` بين نقطتين
/// معروفتين، مش تنقيب.
///
/// ولو التطبيق **عدّل** ملف من الكيت، بيزوّد لاحقة محلية
/// (`1.0.0+app.1`) وبيضيف سطر في `KIT_CHANGES.md` عنده. سطر واحد، وهو
/// كل التخفيف المتاح لانحراف النسخ.
const String kDesignKitVersion = '1.0.1';

/// الكوميت اللي النسخة دي اتاخدت منه في `Waqty-Platform/design-kit`.
///
/// بيتحدّث مع كل إصدار. `unversioned` معناها إن الكيت لسه ما اتكوميتش.
const String kDesignKitSourceCommit = 'unversioned';

/// وصف قصير بيتحط في شاشة «عن التطبيق» لو حد حبّ.
const String kDesignKitLabel = 'Waqty Design Kit $kDesignKitVersion';
