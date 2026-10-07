import 'package:waqty_user_application/core/api/api_consumer.dart';
import '../models/provider_catalog.dart';
import '../models/provider_details_preview.dart';

class ProviderDetailsService {
  final ApiConsumer apiConsumer;
  ProviderDetailsService({required this.apiConsumer});
  // No endpoint is assumed before the provider-details API contract is supplied.
  Future<ProviderCatalog> loadPreview() async => providerDetailsPreview;
}
