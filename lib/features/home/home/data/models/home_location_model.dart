enum HomeLocationSource { device, manual, unknown }

class HomeLocationCity {
  final String uuid;
  final String name;

  const HomeLocationCity({required this.uuid, required this.name});

  factory HomeLocationCity.fromJson(Map<String, dynamic> json) {
    return HomeLocationCity(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class HomeLocationModel {
  final bool needsPrompt;
  final bool hasCoordinates;
  final String? label;
  final String? governorate;
  final HomeLocationCity? city;
  final HomeLocationSource source;
  final bool isStale;

  const HomeLocationModel({
    required this.needsPrompt,
    required this.hasCoordinates,
    required this.label,
    required this.governorate,
    required this.city,
    required this.source,
    required this.isStale,
  });

  const HomeLocationModel.empty()
    : needsPrompt = false,
      hasCoordinates = false,
      label = null,
      governorate = null,
      city = null,
      source = HomeLocationSource.unknown,
      isStale = false;

  factory HomeLocationModel.fromJson(Map<String, dynamic> json) {
    final source = json['source']?.toString();
    final city = json['city'];
    final cityName = _locationName(city);
    return HomeLocationModel(
      needsPrompt: json['needs_prompt'] == true,
      hasCoordinates: json['has_coordinates'] == true,
      label: _nullableString(
        json['label'] ??
            json['display_name'] ??
            json['formatted_address'] ??
            json['address'],
      ),
      governorate: _locationName(json['governorate']),
      city: cityName == null
          ? null
          : HomeLocationCity(
              uuid: city is Map<String, dynamic>
                  ? city['uuid']?.toString() ?? ''
                  : '',
              name: cityName,
            ),
      source: switch (source) {
        'device' => HomeLocationSource.device,
        'manual' => HomeLocationSource.manual,
        _ => HomeLocationSource.unknown,
      },
      isStale: json['is_stale'] == true,
    );
  }

  String? get displayLabel {
    final first = governorate;
    final second = label ?? city?.name;
    if (first != null && second != null && first != second) {
      return '$first، $second';
    }
    return first ?? second;
  }
}

String? _nullableString(dynamic value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}

String? _locationName(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _nullableString(
      value['name'] ?? value['name_ar'] ?? value['name_en'] ?? value['title'],
    );
  }
  return _nullableString(value);
}
