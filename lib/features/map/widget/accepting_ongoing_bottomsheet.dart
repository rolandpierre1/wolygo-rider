import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/ride_cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AcceptingAndOngoingBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const AcceptingAndOngoingBottomSheet({super.key,required this.firstRoute,required this.secondRoute, required this.expandableKey});

  @override
  State<AcceptingAndOngoingBottomSheet> createState() => _AcceptingAndOngoingBottomSheetState();
}

class _AcceptingAndOngoingBottomSheetState extends State<AcceptingAndOngoingBottomSheet> {
   int currentState = 0;
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController){

      return GetBuilder<LocationController>(builder: (locationController){
       return currentState == 0 ? rideController.tripDetails != null ?
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          rideController.currentRideState == RideState.acceptingRider ? Column(children: [
              TollTipWidget(title: 'rider_is_coming'.tr),

            const OtpWidget(fromPage: false),
            ],
          ) :
          TollTipWidget(title: '${'drop_off'.tr} ${DateConverter.dateToTimeOnly(DateTime.now().add(Duration(seconds: rideController.remainingDistanceModel.isNotEmpty ? rideController.remainingDistanceModel[0].durationSec ?? 0 : 0)))}'),
          const SizedBox(height: Dimensions.paddingSizeDefault,),

          const EstimatedFareAndDistance(),

          const SizedBox(height: Dimensions.paddingSizeDefault,),
          const ActivityScreenRiderDetails(),

          const SizedBox(height: Dimensions.paddingSizeDefault,),


          Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
             child: Text('trip_details'.tr,style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColor),),),

         if(rideController.tripDetails != null)
            RouteWidget(totalDistance: rideController.estimatedDistance,
               fromAddress: rideController.tripDetails?.pickupAddress??'',
               toAddress: rideController.tripDetails?.destinationAddress??'',
               extraOneAddress: widget.firstRoute,
               extraTwoAddress: widget.secondRoute,
               entrance:  rideController.tripDetails?.entrance??''),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
             color: Theme.of(context).primaryColor.withOpacity(0.15)),
           padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Image.asset(Images.farePrice,height: 15,width: 15,),
                  const SizedBox(width: Dimensions.paddingSizeSmall,),
                  Text('fare_fee'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
               ]),

               Container(decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                   color:  Theme.of(context).primaryColor.withOpacity(0.2)),
                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeExtraSmall),
                 child: Text(PriceConverter.convertPrice(((rideController.tripDetails?.discountAmount ?? 0) > 0) ?
                 rideController.tripDetails?.discountActualFare ?? 0 :
                 rideController.tripDetails?.actualFare ?? 0),
                   style: textRobotoBold.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).primaryColor),),
               )
             ]),

             const SizedBox(height: Dimensions.paddingSizeSmall,),
             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
               Expanded(
                   child: Row(children: [
                     Image.asset(Images.paymentTypeIcon,height: 15,width: 15,),
                     const SizedBox(width: Dimensions.paddingSizeSmall,),
                     Text('payment'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeDefault),),
                   ])),
               Text(rideController.tripDetails?.paymentMethod?.replaceAll(RegExp('[\\W_]+'),' ').capitalize ?? 'cash'.tr,style: TextStyle(color: Theme.of(context).primaryColor),)
             ]),
           ],
           ),
         ),

         const SizedBox(height: Dimensions.paddingSizeDefault),
         if(rideController.tripDetails != null && rideController.tripDetails!.type == 'ride_request' && !rideController.tripDetails!.isPaused!)
           Center(
             child: SliderButton(
               action: (){
                 currentState = 1;
                 widget.expandableKey.currentState?.expand();
                 setState(() {});
               },
               label: Text('cancel_ride'.tr,style: TextStyle(color: Theme.of(context).primaryColor),),
               dismissThresholds: 0.5, dismissible: false, shimmer: false,
               width: 1170, height: 40, buttonSize: 40, radius: 20,
               icon: Center(child: Container(
                 width: 36, height: 36,
                 decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: Theme.of(context).cardColor),
                 child: Center(
                   child: Icon(
                     Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                     color: Colors.grey, size: 20.0,
                   ),
                 ),
               )),
               isLtr: Get.find<LocalizationController>().isLtr,
               boxShadow: const BoxShadow(blurRadius: 0),
               buttonColor: Colors.transparent,
               backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
               baseColor: Theme.of(context).primaryColor,
             ),
           )
       ]) :
         const Column(children: [BannerShimmer(), BannerShimmer(), BannerShimmer()]) :
         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           const SizedBox(height: Dimensions.paddingSizeSmall,),
             Text(rideController.currentRideState == RideState.acceptingRider ?'rider_is_coming'.tr :'trip_is_ongoing'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),),

             const SizedBox(height: Dimensions.paddingSizeSmall,),

              CancellationRadioButton(isOngoing: rideController.currentRideState == RideState.acceptingRider ? false : true),

             const SizedBox(height: Dimensions.paddingSizeLarge,),
             Row(children: [
               Expanded(child: ButtonWidget(buttonText: 'no_continue_trip'.tr,
               showBorder: true,
               transparent: true,
               backgroundColor: Theme.of(context).primaryColor,
               borderColor: Theme.of(context).primaryColor,
               textColor: Theme.of(context).cardColor,
               radius: Dimensions.paddingSizeSmall,
               onPressed: (){
                 currentState = 0;
                 setState(() {});
               })),

               const SizedBox(width: Dimensions.paddingSizeSmall,),
               Expanded(child: ButtonWidget(buttonText: 'submit'.tr,
                 showBorder: true,
                 transparent: true,
                 textColor: Get.isDarkMode ? Colors.white : Colors.black,
                 borderColor: Theme.of(context).hintColor,
                 radius: Dimensions.paddingSizeSmall,
                 onPressed: (){
                 if(rideController.currentRideState == RideState.acceptingRider){
                   Get.find<RideController>().stopLocationRecord();
                   rideController.tripStatusUpdate(rideController.tripDetails!.id!, 'cancelled', 'ride_request_cancelled_successfully',Get.find<TripController>().rideCancellationReasonList!.data!.acceptedRide![Get.find<TripController>().rideCancellationCauseCurrentIndex]).then((value){
                    if(value.statusCode == 200){
                      Get.find<MapController>().notifyMapController();
                      Get.find<BottomMenuController>().navigateToDashboard();
                    }
                   });
                 }else{
                   rideController.tripStatusUpdate(rideController.tripDetails!.id!, 'cancelled', 'ride_request_cancelled_successfully', Get.find<TripController>().rideCancellationReasonList!.data!.ongoingRide![Get.find<TripController>().rideCancellationCauseCurrentIndex], afterAccept: true).then((value) async {
                     if(value.statusCode == 200){
                       Get.find<RideController>().stopLocationRecord();
                       rideController.getFinalFare(rideController.tripDetails!.id!).then((value) {
                         if(value.statusCode == 200){
                           Get.find<RideController>().updateRideCurrentState(RideState.completeRide);
                           Get.find<MapController>().notifyMapController();
                           Get.off(() => const PaymentScreen());
                         }
                       });
                     }
                   });
                 }
               })),
         ],)
       ],);
      });
    });
  }
}
