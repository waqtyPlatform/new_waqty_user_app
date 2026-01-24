import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waqty_user_application/core/services/geocoding_service.dart';
import 'package:waqty_user_application/core/services/location_service.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/logic/explore_near_people_cubit.dart';

class ExploreNearPeopleScreen extends StatefulWidget {
  const ExploreNearPeopleScreen({super.key});

  @override
  State<ExploreNearPeopleScreen> createState() =>
      _ExploreNearPeopleScreenState();
}

class _ExploreNearPeopleScreenState extends State<ExploreNearPeopleScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  CameraPosition? currentLocationCameraPosition;
  Set<Marker> markers = {};
  Placemark? address;
  Position? position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyCurrentLocation();
  }

  getMyCurrentLocation() async {
    position = await YourLocation.getCurrentLocation();
    ExploreNearPeopleCubit.get(context).latitudeController.text =
        (position?.latitude ?? 0).toString();
    ExploreNearPeopleCubit.get(context).longitudeController.text =
        (position?.longitude ?? 0).toString();

    currentLocationCameraPosition = CameraPosition(
      bearing: 0,
      tilt: 0,
      target: LatLng(position!.latitude, position!.longitude),
      zoom: 5,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (currentLocationCameraPosition == null)
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.greenColor500,
                    ),
                  )
                : Expanded(
                  child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: currentLocationCameraPosition!,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markers,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      onTap: (LatLng latLong) {
                        onTapOnMap(latLong);
                      },
                    ),
                ),
          ],
        ),
      ),
    );
  }

  onTapOnMap(LatLng latLong) async {
    List<Placemark>? item = await GeocodingService.getPlaceMarkFromCoordinates(
      latLong.latitude,
      latLong.longitude,
    );
    if (item != null && item.isNotEmpty) {
      ExploreNearPeopleCubit.get(context).latitudeController.text =
          (latLong.latitude).toString();
      ExploreNearPeopleCubit.get(context).longitudeController.text =
          (latLong.longitude).toString();
      currentLocationCameraPosition = CameraPosition(
        bearing: 0,
        tilt: 0,
        target: LatLng(latLong.latitude, latLong.longitude),
        zoom: 5,
      );

      address = item[0];
    }
    markers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: latLong,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ), // Blue marker
      ),
    );
    setState(() {});
  }
}
