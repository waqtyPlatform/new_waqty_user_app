part of '../explore_design_widgets.dart';

class _ExploreChipData {
  final String labelKey;
  final IconData icon;
  final bool selected;

  _ExploreChipData(this.labelKey, this.icon, this.selected);
}

class ExplorePlaceData {
  final String image;
  final String titleKey;
  final String subtitleKey;
  final String metaKey;
  final String rating;
  final String? slotKey;
  final String? badgeKey;

  const ExplorePlaceData({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
    required this.metaKey,
    required this.rating,
    this.slotKey,
    this.badgeKey,
  });
}

const explorePlaces = [
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_1.png',
    titleKey: 'explore.placeHoda',
    subtitleKey: 'explore.placeHodaSub',
    metaKey: 'explore.placeHodaMeta',
    rating: '4.8',
    slotKey: 'explore.slotHoda',
    badgeKey: 'explore.twoSlots',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_2.png',
    titleKey: 'home.providerCaptain',
    subtitleKey: 'explore.placeCaptainSub',
    metaKey: 'explore.placeCaptainMeta',
    rating: '4.9',
    slotKey: 'home.availableSlotCaptain',
    badgeKey: 'home.fastBooking',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_3.png',
    titleKey: 'explore.placeNour',
    subtitleKey: 'explore.placeNourSub',
    metaKey: 'explore.placeNourMeta',
    rating: '4.7',
    slotKey: 'explore.slotNour',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_4.png',
    titleKey: 'explore.placeFriends',
    subtitleKey: 'explore.placeFriendsSub',
    metaKey: 'explore.placeFriendsMeta',
    rating: '4.6',
    slotKey: 'explore.slotFriends',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_5.png',
    titleKey: 'explore.placeFreedom',
    subtitleKey: 'explore.placeFreedomSub',
    metaKey: 'explore.placeFreedomMeta',
    rating: '4.4',
    slotKey: 'explore.slotFreedom',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_6.png',
    titleKey: 'explore.placeDental',
    subtitleKey: 'explore.placeDentalSub',
    metaKey: 'explore.placeDentalMeta',
    rating: '4.8',
    slotKey: 'explore.slotDental',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_7.png',
    titleKey: 'explore.placeRelax',
    subtitleKey: 'explore.placeRelaxSub',
    metaKey: 'explore.placeRelaxMeta',
    rating: '4.3',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_8.png',
    titleKey: 'explore.placeBella',
    subtitleKey: 'explore.placeBellaSub',
    metaKey: 'explore.placeBellaMeta',
    rating: '4.6',
    slotKey: 'explore.slotBella',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_9.png',
    titleKey: 'explore.placeLamsa',
    subtitleKey: 'explore.placeLamsaSub',
    metaKey: 'explore.placeLamsaMeta',
    rating: '4.2',
    slotKey: 'explore.slotLamsa',
  ),
  ExplorePlaceData(
    image: 'assets/images/explore/explore_place_10.png',
    titleKey: 'explore.placeCare',
    subtitleKey: 'explore.placeCareSub',
    metaKey: 'explore.placeCareMeta',
    rating: '4.5',
    slotKey: 'explore.slotCare',
  ),
];
