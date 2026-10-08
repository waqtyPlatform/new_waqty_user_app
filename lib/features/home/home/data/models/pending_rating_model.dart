class PendingRatingModel {
  final String bookingUuid;
  final String serviceName;
  final String providerName;
  final String branchName;
  final String? employeeName;
  final String visitedOn;

  const PendingRatingModel({
    required this.bookingUuid,
    required this.serviceName,
    required this.providerName,
    required this.branchName,
    required this.visitedOn,
    this.employeeName,
  });

  factory PendingRatingModel.fromJson(Map<String, dynamic> json) =>
      PendingRatingModel(
        bookingUuid: json['booking_uuid']?.toString() ?? '',
        serviceName: json['service_name']?.toString() ?? '',
        providerName: json['provider_name']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        employeeName: _nullableText(json['employee_name']),
        visitedOn: json['visited_on']?.toString() ?? '',
      );
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
