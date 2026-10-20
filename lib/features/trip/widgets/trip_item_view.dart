import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/domain/enums/refund_status_enum.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class TripItemView extends StatelessWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;
  const TripItemView({super.key, required this.tripDetails, this.isDetailsScreen = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(tripDetails.currentStatus == 'accepted' ||
            tripDetails.currentStatus == 'ongoing'||
            tripDetails.currentStatus == 'pending'){
          if(tripDetails.type == 'parcel'){
            Get.find<RideController>().getRideDetails(tripDetails.id!).then((value) {
              if(tripDetails.currentStatus == 'accepted'){
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.otpSent);
                Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

              }else if (tripDetails.currentStatus == 'ongoing'){
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelOngoing);
                if(value.body['data']['parcel_information']['payer'] == 'sender' &&
                    value.body['data']['payment_status'] == 'unpaid'){
                  Get.off(()=>const PaymentScreen(fromParcel: true));

                }else{
                  Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

                }
              }else{
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.findingRider);
                Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

              }
            });

          }else{
            Get.find<RideController>().getRideDetails(tripDetails.id!);
            if(tripDetails.currentStatus == 'accepted'){
              Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
            }else if (tripDetails.currentStatus == 'ongoing'){
              Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
            }else{
              Get.find<RideController>().updateRideCurrentState(RideState.findingRider);
            }
            Get.to(()=> const MapScreen(fromScreen: MapScreenType.ride));
          }
        }else{
          if(tripDetails.currentStatus == 'completed' && tripDetails.paymentStatus == 'unpaid'){
            Get.find<RideController>().getFinalFare(tripDetails.id!).then((value){
              Get.to(()=> PaymentScreen(fromParcel: tripDetails.type == 'parcel' ? true : false));
            });

          }else{
            Get.to(()=> TripDetailsScreen(tripId: tripDetails.id!));
          }
        }
      },
      child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Stack(children: [
            Container(width: 80, height: Get.height * 0.105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color:tripDetails.vehicle != null ?
                Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.02) :
                Theme.of(context).cardColor,
              ),
              child: Center(child: Column(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: tripDetails.type != 'parcel' ?
                    ImageWidget(width: 60, height: 60,
                        image : tripDetails.vehicle != null ?
                        '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${tripDetails.vehicle!.model!.image!}' :
                        '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleCategory!}/${tripDetails.vehicleCategory?.image!}',
                        fit: BoxFit.cover) :
                    Image.asset(Images.parcel,height: 60,width: 30)
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  tripDetails.type != 'parcel' ?
                  tripDetails.vehicleCategory != null ?
                  tripDetails.vehicleCategory!.name!
                      : '' :
                  'parcel'.tr,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                  ),
                ),
              ])),
            ),

            if(!isDetailsScreen)
            Positioned(
              right: 0,
              child: Container(
                height: 20,width: 20,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color:  tripDetails.currentStatus == 'cancelled' ?
                    Theme.of(context).colorScheme.error.withOpacity(0.15) :
                    tripDetails.currentStatus == 'completed' ?
                    Theme.of(context).colorScheme.surfaceTint.withOpacity(0.15) :
                    tripDetails.currentStatus == 'returning' ?
                    Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.15) :
                    tripDetails.currentStatus == 'returned' ?
                    Theme.of(context).colorScheme.surfaceTint.withOpacity(0.15) :
                    Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.15) ,
                    shape: BoxShape.circle
                ),
                child: tripDetails.currentStatus == 'cancelled' ?
                Image.asset(Images.crossIcon,color: Theme.of(context).colorScheme.error) :
                tripDetails.currentStatus == 'completed' ?
                Image.asset(Images.selectedIcon,color: Theme.of(context).colorScheme.surfaceTint) :
                tripDetails.currentStatus == 'returning' ?
                Image.asset(Images.returnIcon,color: Theme.of(context).colorScheme.surfaceContainer) :
                tripDetails.currentStatus == 'returned' ?
                Image.asset(Images.returnIcon,color: Theme.of(context).colorScheme.surfaceTint) :
                Image.asset(Images.ongoingMarkerIcon,color: Theme.of(context).colorScheme.surfaceContainer),
              ),
            )
          ]),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text( tripDetails.type == 'parcel' ?
                tripDetails.parcelInformation?.parcelCategoryName ?? '' :
              tripDetails.destinationAddress ?? '',
              style: textRegular.copyWith(color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.9) : null),overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text (
                DateConverter.isoStringToDateTimeString(tripDetails.createdAt!),
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) ,
                ),
              ),

              if(!isDetailsScreen && (tripDetails.parcelRefund?.status == RefundStatus.pending || tripDetails.parcelRefund?.status == RefundStatus.approved))
              Image.asset(Images.tripDetailsRefundIcon,height: 16,width: 16)
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            !isDetailsScreen ?
            SizedBox(width: Get.width*0.6, child: Row( children: [
              tripDetails.estimatedFare!=null ?
              Text(PriceConverter.convertPrice(
                (
                    tripDetails.currentStatus == 'cancelled' || tripDetails.currentStatus == 'completed' ||
                    (tripDetails.parcelInformation?.payer == 'sender' && tripDetails.currentStatus == 'ongoing') ||
                    tripDetails.currentStatus == 'returning' || tripDetails.currentStatus == 'returned'
                ) ?
                  tripDetails.paidFare! :
                ( tripDetails.discountActualFare! > 0 ? tripDetails.discountActualFare! : tripDetails.actualFare!),
              ),
                style: textRobotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ) :
              const SizedBox(),

            ])) :
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              tripDetails.estimatedFare != null ?
              Text(PriceConverter.convertPrice(tripDetails.paidFare!),
                style: textRobotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ) :
              const SizedBox(),

              Text(tripDetails.currentStatus!.tr,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ])),
        ]),
      ),
    );
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
