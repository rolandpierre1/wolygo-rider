import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/custom_title.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';


class HomeMapView extends StatefulWidget {
  final String title;
  const HomeMapView({super.key, required this.title});

  @override
  HomeMapViewState createState() => HomeMapViewState();
}

class HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;
  int isFirstCount = 0;


  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (mapController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        Completer<GoogleMapController> mapCompleter = Completer<GoogleMapController>();
        if(mapController.mapController != null) {
          mapCompleter.complete(mapController.mapController);
        }
        return mapController.nearestDeliveryManMarkers != null ?
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: Column(children: [
            CustomTitle(
              title: widget.title.tr,
              color: Get.isDarkMode ? Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.9) : Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
            const SizedBox(height:Dimensions.paddingSizeSmall),

            Container(height: Get.height * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                child: GoogleMap(
                  style: Get.isDarkMode ?
                  Get.find<ThemeController>().darkMap :
                  Get.find<ThemeController>().lightMap,
                  markers: mapController.nearestDeliveryManMarkers!.toSet(),
                  initialCameraPosition: CameraPosition(target: LatLng(
                    Get.find<LocationController>().getUserAddress()?.latitude ?? 0,
                    Get.find<LocationController>().getUserAddress()?.longitude ?? 0,
                  ), zoom: 16),
                   minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  onMapCreated: (gController) {
                    _mapController = gController;
                    calculateCenterBound(
                      Get.find<LocationController>().getUserAddress()?.latitude ?? 0,
                      Get.find<LocationController>().getUserAddress()?.longitude ?? 0,
                    );
                    mapController.setMapController(gController);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                ),
              ),
            ),
          ]),
        ) :
        const BannerShimmer();
      });
    });
  }


  LatLng calculateCenterBound(double lat, double lng){
    double searchRadius = (Get.find<ConfigController>().config?.searchRadius ?? 0)/2;
    // Calculating coordinates for center left , center right ,center top, center bottom
    List<LatLng> list = [] ;
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 270)); // 270 degrees (West lat-lng)
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 90)); // 270 degrees (East  lat-lng)
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 180)); // 270 degrees (South  lat-lng)
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 360)); // 270 degrees (North  lat-lng)
    LatLngBounds bounds = Get.find<MapController>().boundWithMaximumLatLngPoint(list);
    LatLng centerBounds = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude)/2,
      (bounds.northeast.longitude + bounds.southwest.longitude)/2,
    );

    if(isFirstCount == 0){
      isFirstCount++;
      Get.find<MapController>().zoomToFit(_mapController, bounds, centerBounds, 0);
    }
    return centerBounds;
  }


  LatLng calculateOffset(LatLng center, double distance, double bearing) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double radLat = radians(center.latitude);
    double radLon = radians(center.longitude);
    double radBearing = radians(bearing);
    double newLat = asin(sin(radLat) * cos(distance / earthRadius) +
        cos(radLat) * sin(distance / earthRadius) * cos(radBearing));
    double newLon = radLon +
        atan2(sin(radBearing) * sin(distance / earthRadius) * cos(radLat),
            cos(distance / earthRadius) - sin(radLat) * sin(newLat));
    return LatLng(degrees(newLat), degrees(newLon));
  }
  double radians(double degrees) {
    return degrees * pi / 180;
  }
  double degrees(double radians) {
    return radians * 180 / pi;
  }

}
