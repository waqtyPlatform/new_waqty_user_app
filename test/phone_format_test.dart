import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/utils/app_phone.dart';
import 'package:waqty_user_application/core/utils/app_regex.dart';

/// **الرقم اللي رايح للـAPI لازم يبقى الصيغة المحلية بالصفر.**
///
/// الباك-إند مابينرملش الأرقام — اتأكدنا بالتجربة على
/// `POST /api/user/auth/login`: `01113000000` بيعدّي، و`+201113000000`
/// و`201113000000` و`+2001113000000` كلهم `invalid_credentials`.
///
/// الـcubits كانت بتلزق `'+20'` على رقم لسه فيه الصفر فبتطلّع
/// `+2001113000000` — صيغة رابعة مالهاش وجود، والدخول والتسجيل كانوا
/// بيقعوا الاتنين. الباج فضل مستخبي طول ما الأبلكيشن على mock.
void main() {
  group('AppPhone.toApiFormat', () {
    test('الرقم المحلي بيعدّي زي ما هو', () {
      expect(AppPhone.toApiFormat('01113000000'), '01113000000');
    });

    test('كود الدولة بيتشال بصيغه التلاتة', () {
      expect(AppPhone.toApiFormat('+201113000000'), '01113000000');
      expect(AppPhone.toApiFormat('201113000000'), '01113000000');
      expect(AppPhone.toApiFormat('00201113000000'), '01113000000');
    });

    test('الصيغة المكسورة اللي كانت بتتبعت بترجع صح', () {
      // ده بالظبط اللي الـcubit كان بيبنيه: '+20' + '01113000000'
      expect(AppPhone.toApiFormat('+2001113000000'), '01113000000');
    });

    test('الصفر بيترجّع لو المستخدم نسيه', () {
      expect(AppPhone.toApiFormat('1113000000'), '01113000000');
    });

    test('المسافات والشرط بيطيروا', () {
      expect(AppPhone.toApiFormat('011 130 00000'), '01113000000');
      expect(AppPhone.toApiFormat('011-130-00000'), '01113000000');
    });

    test('الفاضي بيفضل فاضي مش بيبقى صفر', () {
      expect(AppPhone.toApiFormat(''), '');
      expect(AppPhone.toApiFormat('   '), '');
    });

    test('الناتج دايمًا بيعدّي على فاليديتور الأبلكيشن نفسه', () {
      // لو البوابة طلّعت حاجة الفاليديتور بيرفضها، يبقى الاتنين
      // مختلفين على شكل الرقم — وده أصل الباج ده من الأول.
      for (final raw in [
        '01113000000',
        '+201113000000',
        '+2001113000000',
        '1113000000',
        '011 130 00000',
      ]) {
        expect(
          AppRegex.isPhoneNumberValid(AppPhone.toApiFormat(raw)),
          isTrue,
          reason: 'الفاليديتور رفض ناتج البوابة لـ"$raw"',
        );
      }
    });
  });
}
