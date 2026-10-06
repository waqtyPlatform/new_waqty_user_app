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
  final HomeLocationCity? city;
  final HomeLocationSource source;
  final bool isStale;

  const HomeLocationModel({
    required this.needsPrompt,
    required this.hasCoordinates,
    required this.label,
    required this.city,
    required this.source,
    required this.isStale,
  });

  const HomeLocationModel.empty()
    : needsPrompt = false,
      hasCoordinates = false,
      label = null,
      city = null,
      source = HomeLocationSource.unknown,
      isStale = false;

  factory HomeLocationModel.fromJson(Map<String, dynamic> json) {
    final source = json['source']?.toString();
    final city = json['city'];
    return HomeLocationModel(
      needsPrompt: json['needs_prompt'] == true,
      hasCoordinates: json['has_coordinates'] == true,
      label: _nullableString(json['label']),
      city: city is Map<String, dynamic>
          ? HomeLocationCity.fromJson(city)
          : null,
      source: switch (source) {
        'device' => HomeLocationSource.device,
        'manual' => HomeLocationSource.manual,
        _ => HomeLocationSource.unknown,
      },
      isStale: json['is_stale'] == true,
    );
  }
}

String? _nullableString(dynamic value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}
