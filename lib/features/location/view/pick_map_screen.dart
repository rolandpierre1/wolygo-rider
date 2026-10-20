import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/widget/location_search_dialog.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class PickMapScreen extends StatefulWidget {
  final LocationType type;
  final bool oldLocationExist;
  final Function(Position position, String address)? onLocationPicked;
  const PickMapScreen({super.key, this.onLocationPicked, required this.type,this.oldLocationExist = false});

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;

  @override
  void initState() {
    super.initState();

    if(widget.onLocationPicked != null) {
      Get.find<LocationController>().setPickData(widget.type);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: GetBuilder<LocationController>(builder: (locationController) {
          return Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.oldLocationExist ?
                LatLng(locationController.pickPosition.latitude, locationController.pickPosition.longitude) :
                widget.onLocationPicked != null ?
                LatLng(locationController.position.latitude, locationController.position.longitude) :
                locationController.initialPosition, zoom: 16,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              onMapCreated: (GoogleMapController mapController) {
                Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                  _mapController = mapController;
                  if(widget.onLocationPicked == null && !widget.oldLocationExist) {
                    //Get.find<LocationController>().getCurrentLocation(mapController: mapController, type: widget.type);
                    Get.find<LocationController>().updatePosition(_cameraPosition?.target ?? locationController.initialPosition, false, widget.type);
                  }
                });
              },
              zoomControlsEnabled: false,
              onCameraMove: (CameraPosition cameraPosition) {
                _cameraPosition = cameraPosition;
              },
              onCameraMoveStarted: () {
                locationController.disableButton();
              },
              onCameraIdle: () {
                try{
                  Get.find<LocationController>().updatePosition(_cameraPosition?.target, false, widget.type);
                }catch(e){
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              style: Get.isDarkMode ?
              Get.find<ThemeController>().darkMap :
              Get.find<ThemeController>().lightMap,
            ),

            Center(
              child: !locationController.loading ?
              Image.asset(Images.mapLocationIcon, height: 120, width: 120) :
              SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0),
            ),

            Positioned(
              top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              child: InkWell(
                onTap: () => Get.dialog(LocationSearchDialog(mapController: _mapController!, type: widget.type)),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Row(children: [
                    Icon(
                      Icons.location_on,
                      size: 25, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.6),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(
                      child: Text(
                        locationController.pickAddress,
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ]),
                ),
              ),
            ),

            Positioned(
              bottom: 80, right: Dimensions.paddingSizeSmall,
              child: FloatingActionButton(
                hoverColor: Colors.transparent,
                mini: true, backgroundColor:Theme.of(context).colorScheme.primary,
                onPressed: () => Get.find<LocationController>().getCurrentPosition(mapController: _mapController),
                child: Icon(Icons.my_location, color: Colors.white.withOpacity(0.9)),
              ),
            ),

            Positioned(
              bottom: 30.0, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: locationController.picking ?
              Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0)) :
              ButtonWidget(
                fontSize: Dimensions.fontSizeDefault,
                buttonText: locationController.inZone ?
                'pick_location'.tr :
                'service_not_available_in_this_area'.tr,
                onPressed: (locationController.buttonDisabled || locationController.loading) ? null : () {
                  if(locationController.pickPosition.latitude != 0 && locationController.pickAddress.isNotEmpty) {
                    if(widget.onLocationPicked != null) {
                      locationController.setAddAddressData(widget.type);
                      widget.onLocationPicked!(locationController.pickPosition, locationController.pickAddress);
                      Get.back();

                    }else {
                      Address address = Address(
                        latitude: locationController.pickPosition.latitude,
                        longitude: locationController.pickPosition.longitude,
                        addressLabel: 'others',
                        address: locationController.pickAddress,
                        zoneId: locationController.zoneID,
                      );
                      locationController.saveAddressAndNavigate(address, widget.type);

                    }
                  }else {
                    showCustomSnackBar('pick_an_address'.tr);

                  }
                },
              ),
            ),

          ]);
        }),
      )),
    );
  }
}
