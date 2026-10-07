import '../models/provider_catalog.dart';
import '../services/provider_details_service.dart';

class ProviderDetailsRepo {
  final ProviderDetailsService _service;
  ProviderDetailsRepo(this._service);
  Future<ProviderCatalog> loadPreview() => _service.loadPreview();
}
