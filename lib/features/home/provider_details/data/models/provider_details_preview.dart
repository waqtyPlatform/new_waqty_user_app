import 'provider_catalog.dart';

// Design fixtures only; replace the repository preview source when the API contract arrives.
const providerDetailsPreview = ProviderCatalog([
  ProviderBranch(
    id: 'preview-main',
    label: 'mainBranch',
    address: 'mainAddress',
    services: previewServices,
    specialists: previewSpecialists,
    packages: previewPackages,
  ),
  ProviderBranch(
    id: 'preview-secondary',
    label: 'secondBranch',
    address: 'secondAddress',
    services: previewServices,
    specialists: [],
    packages: [],
    namedStaff: false,
  ),
], isPreview: true);
const previewServices = [
  ProviderServiceItem('hair', 'haircut', 250, 45),
  ProviderServiceItem('beard', 'beard', 120, 20),
  ProviderServiceItem('cream', 'cream', 180, 30),
  ProviderServiceItem(
    'color',
    'color',
    200,
    40,
    children: [
      ProviderServiceItem('color-roots', 'roots', 200, 40),
      ProviderServiceItem('color-full', 'fullColor', 350, 60),
      ProviderServiceItem('color-highlights', 'highlights', 450, 75),
      ProviderServiceItem('color-toner', 'toner', 220, 30),
      ProviderServiceItem('color-correction', 'correction', 600, 90),
    ],
  ),
];
const previewSpecialists = [
  ProviderSpecialist('ahmed', 'ahmed', 300, 45, recommended: true),
  ProviderSpecialist('mohamed', 'mohamed', 250, 45),
  ProviderSpecialist('mostafa', 'mostafa', 250, 50),
];
const previewPackages = [
  ProviderPackage(
    'care',
    'carePackage',
    1350,
    4,
    'offerExpiry',
    oldPrice: 1800,
  ),
  ProviderPackage('hair', 'hairPackage', 1600, 8, 'sixMonths'),
  ProviderPackage('groom', 'groomPackage', 900, 1, 'twoMonths'),
];
