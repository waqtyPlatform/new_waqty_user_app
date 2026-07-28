/// موديل عرض للفرع.
///
/// العنوان والتليفون ومواعيد العمل السيرفر عنده الداتا بتاعتهم بس مش
/// بيرجّعهم في الـ payload العام لسه — فدلوقتي جايين من الـ mock.
class BranchUiModel {
  final String uuid;
  final String name;
  final String areaName;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double distanceKm;

  /// «مفتوح · يقفل ٩:٠٠ م» أو «مغلق · يفتح غدًا ٩:٠٠ ص»
  final String openStatusLabel;
  final bool isOpenNow;

  /// ٧ أيام بالترتيب من الاثنين. اليوم المقفول بيبقى فيه «مغلق».
  final List<BranchWorkingDay> workingHours;

  const BranchUiModel({
    required this.uuid,
    required this.name,
    required this.areaName,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0,
    this.openStatusLabel = '',
    this.isOpenNow = false,
    this.workingHours = const <BranchWorkingDay>[],
  });
}

class BranchWorkingDay {
  final String dayName;
  final String hoursLabel;
  final bool isClosed;
  final bool isToday;

  const BranchWorkingDay({
    required this.dayName,
    required this.hoursLabel,
    this.isClosed = false,
    this.isToday = false,
  });
}
