class WaitlistOfferModel {
  final String uuid;
  final DateTime? startAt;
  final DateTime? endAt;
  final String providerName;
  final String branchName;
  final String message;
  final DateTime? expiresAt;
  final int secondsRemaining;

  const WaitlistOfferModel({
    required this.uuid,
    required this.providerName,
    required this.branchName,
    required this.message,
    required this.secondsRemaining,
    this.startAt,
    this.endAt,
    this.expiresAt,
  });

  factory WaitlistOfferModel.fromJson(Map<String, dynamic> json) =>
      WaitlistOfferModel(
        uuid: json['uuid']?.toString() ?? '',
        startAt: DateTime.tryParse(json['start_at']?.toString() ?? ''),
        endAt: DateTime.tryParse(json['end_at']?.toString() ?? ''),
        providerName: json['provider_name']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
        secondsRemaining:
            int.tryParse(json['seconds_remaining']?.toString() ?? '') ?? 0,
      );

  int remainingAt(DateTime now) {
    final expiry = expiresAt;
    if (expiry == null) return secondsRemaining.clamp(0, 1 << 31);
    return expiry.difference(now).inSeconds.clamp(0, 1 << 31);
  }
}
