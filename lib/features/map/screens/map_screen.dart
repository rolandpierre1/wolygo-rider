import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/map/widget/custom_icon_card.dart';
import 'package:ride_sharing_user_app/features/map/widget/discount_coupon_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';


enum MapScreenType{ride, splash, parcel, location}

class MapScreen extends StatefulWidget {
  final MapScreenType fromScreen;
  final bool isShowCurrentPosition;
  const MapScreen({super.key, required this.fromScreen, this.isShowCurrentPosition = true});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver{
  GoogleMapController? _mapController;
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey<ExpandableBottomSheetState>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Get.find<MapController>().setContainerHeight((widget.fromScreen == MapScreenType.parcel) ? 200 : 260, false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      Get.find<RideController>().getRideDetails(Get.find<RideController>().currentTripDetails!.id!).then((value) {
        if (value.statusCode == 200) {
          if(Get.find<RideController>().currentTripDetails!.type == 'parcel'){
            if(Get.find<RideController>().currentTripDetails!.currentStatus == 'pending'){
              Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.findingRider);
              Get.find<MapController>().getPolyline();
            }else if(Get.find<RideController>().currentTripDetails!.currentStatus == 'accepted'){
              Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.otpSent);
              Get.find<MapController>().getPolyline();
              Get.find<RideController>().startLocationRecord();
              Get.find<MapController>().notifyMapController();
            }else if(Get.find<RideController>().currentTripDetails!.currentStatus == 'ongoing'){
              Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelOngoing);
              Get.find<MapController>().getPolyline();
              Get.find<RideController>().startLocationRecord();
              Get.find<MapController>().notifyMapController();
              if(Get.find<RideController>().currentTripDetails!.parcelInformation?.payer == 'sender' &&
                  Get.find<RideController>().currentTripDetails!.paymentStatus == 'unpaid'){
                Get.off(()=>const PaymentScreen(fromParcel: true));
              }
            }else{
              Get.offAll(()=> const DashboardScreen());
            }

          }else{
            if(Get.find<RideController>().currentTripDetails!.currentStatus == 'pending'){
              Get.find<RideController>().updateRideCurrentState(RideState.findingRider);
              Get.find<MapController>().getPolyline();
            }else if(Get.find<RideController>().currentTripDetails!.currentStatus == 'accepted'){
              Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
              Get.find<MapController>().getPolyline();
              Get.find<RideController>().startLocationRecord();
              Get.find<MapController>().notifyMapController();
            }else if(Get.find<RideController>().currentTripDetails!.currentStatus == 'ongoing'){
              Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
              Get.find<MapController>().getPolyline();
              Get.find<RideController>().startLocationRecord();
              Get.find<MapController>().notifyMapController();
            }else if((Get.find<RideController>().currentTripDetails!.currentStatus == 'completed' && Get.find<RideController>().currentTripDetails!.paymentStatus == 'unpaid')
                || (Get.find<RideController>().currentTripDetails!.currentStatus == 'cancelled' && Get.find<RideController>().currentTripDetails!.paymentStatus == 'unpaid' &&
                    Get.find<RideController>().currentTripDetails!.paidFare! > 0)){
              Get.off(()=>const PaymentScreen(fromParcel: false));
            } else{
              Get.offAll(()=> const DashboardScreen());
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Get.find<MapController>().mapController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, value){
        if(didPop){
          Future.delayed(const Duration(milliseconds: 500)).then((onValue){
            if(Get.find<RideController>().currentRideState.name == 'findingRider' ||
                Get.find<ParcelController>().currentParcelState.name == 'findingRider'){
              Get.offAll(()=> const DashboardScreen());
            }
          });

        }else{
          Get.offAll(()=> const DashboardScreen());
        }
      },
      child: Scaffold(resizeToAvoidBottomInset: false,
        body: Stack(children: [
          BodyWidget(topMargin: 0,
            appBar: AppBarWidget(
              title: 'the_deliveryman_need_you'.tr, centerTitle: true,
              onBackPressed: () {
                if(Navigator.canPop(context)) {
                  if(Get.find<RideController>().currentRideState.name == 'findingRider' ||
                      Get.find<ParcelController>().currentParcelState.name == 'findingRider'){
                    Get.offAll(()=> const DashboardScreen());
                  }else{
                    Get.back();
                  }

                }else {
                  Get.offAll(()=> const DashboardScreen());
                }
              },
            ),
            body: GetBuilder<MapController>(builder: (mapController) {
              return ExpandableBottomSheet(key: key,
                background: GetBuilder<RideController>(builder: (rideController) {
                  return Stack(children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: mapController.sheetHeight - 20),
                      child: GoogleMap(
                          style: Get.isDarkMode ?
                          Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                          initialCameraPosition:  CameraPosition(
                            target:  rideController.tripDetails?.pickupCoordinates != null ?
                            LatLng(
                              rideController.tripDetails!.pickupCoordinates!.coordinates![1],
                              rideController.tripDetails!.pickupCoordinates!.coordinates![0],
                            ) :
                            Get.find<LocationController>().initialPosition,
                            zoom: 16,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController.mapController = controller;
                            if(
                            Get.find<RideController>().currentRideState.name == 'findingRider' ||
                                Get.find<RideController>().currentRideState.name == 'riseFare'
                            ){
                              Get.find<MapController>().initializeData();
                              Get.find<MapController>().setOwnCurrentLocation();
                            }else if(Get.find<RideController>().currentRideState.name == 'initial'){
                              mapController.getPolyline();
                            }else if(Get.find<RideController>().currentRideState.name == 'completeRide'){
                              Get.find<MapController>().initializeData();
                            }else{
                              Get.find<MapController>().initializeData();
                              Get.find<MapController>().setMarkersInitialPosition();
                              Get.find<RideController>().startLocationRecord();
                            }
                            _mapController = controller;
                          },
                          minMaxZoomPreference: const MinMaxZoomPreference(0, AppConstants.mapZoom),
                          markers: Set<Marker>.of(mapController.markers),
                          polylines: Set<Polyline>.of(mapController.polylines.values),
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          trafficEnabled: mapController.isTrafficEnable,
                          indoorViewEnabled: true,
                          mapToolbarEnabled: true),
                    ),

                    if(widget.isShowCurrentPosition)
                      Positioned(bottom: Get.height * 0.34,right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            return CustomIconCard(
                              index: 5,icon: Images.currentLocation,
                              iconColor: Theme.of(context).primaryColor,
                              onTap: () async {
                                await locationController.getCurrentLocation(mapController: _mapController);
                                await _mapController?.moveCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(target: Get.find<LocationController>().initialPosition, zoom: 16),
                                ));
                              },
                            );
                          }),
                        ),
                      ),

                    Positioned(bottom: Get.height * 0.41, right:0,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: CustomIconCard(
                            icon: mapController.isTrafficEnable ?
                            Images.trafficOnlineIcon : Images.trafficOfflineIcon,
                            iconColor: mapController.isTrafficEnable ?
                            Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).hintColor,
                            index: 2,
                            onTap: () => mapController.toggleTrafficView(),
                          )
                      ),
                    ),

                    Positioned(bottom: Get.height * 0.48, right:0,
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: CustomIconCard(
                              icon: Images.offerMapIcon,iconColor: Theme.of(context).colorScheme.inverseSurface,
                              index: 2,
                              onTap: (){
                                Get.bottomSheet(
                                  const DiscountAndCouponBottomSheet(),
                                  backgroundColor: Theme.of(context).cardColor,isDismissible: false,
                                );
                              },
                            )
                        )

                    ),
                  ]);
                }),
                persistentContentHeight: mapController.sheetHeight,

                expandableContent: Column(mainAxisSize: MainAxisSize.min, children: [
                  widget.fromScreen == MapScreenType.parcel ?
                  GetBuilder<RideController>(builder: (parcelController) {
                    return ParcelExpendableBottomSheet(expandableKey: key);
                  }) :
                  (widget.fromScreen == MapScreenType.ride || widget.fromScreen == MapScreenType.splash) ?
                  GetBuilder<RideController>(builder: (rideController) {
                    return RideExpendableBottomSheet(expandableKey: key);
                  }) :
                  const SizedBox(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),

                ]),
              );
            }),
          ),

          widget.fromScreen == MapScreenType.location ?
          Positioned(
            child: Align(alignment: Alignment.bottomCenter,
              child: SizedBox(height: 70, child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: ButtonWidget(buttonText: 'set_location'.tr, onPressed: () => Get.back()),
              )),
            ),
          ) :
          const SizedBox(),

        ]),
      ),
    );
  }
}
