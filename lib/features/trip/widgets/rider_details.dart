import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/contact_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class ActivityScreenRiderDetails extends StatelessWidget {
  const ActivityScreenRiderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        String ratting = rideController.tripDetails?.driverAvgRating != null
            ? double.parse(rideController.tripDetails!.driverAvgRating!).toStringAsFixed(1) : "0";

        return Container(
           decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              border: Border.all(width: .75, color: Theme.of(context).hintColor.withOpacity(0.25))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: ImageWidget(height: 50, width: 50,
                      image: rideController.tripDetails?.driver != null ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}'
                          '/${rideController.tripDetails!.driver!.profileImage}' : '')),
                const SizedBox(width: Dimensions.paddingSizeSmall,),


                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        rideController.tripDetails?.driver != null ? SizedBox(width: 100,
                          child: Text('${rideController.tripDetails!.driver!.firstName!} ${rideController.tripDetails!.driver!.lastName!}',
                            style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).primaryColorDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ) : const SizedBox(),
                        Text.rich(TextSpan(style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),), children:  [

                            WidgetSpan(child: Icon(Icons.star,color: Theme.of(context).colorScheme.primaryContainer,size: 15,),
                              alignment: PlaceholderAlignment.middle),

                            TextSpan(text: ratting,
                                style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        )),
                      ],),

                Container(width: 1,height: 25,color: Theme.of(context).hintColor.withOpacity(0.25),margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge)),

                ContactWidget(driverId: rideController.tripDetails?.driver?.id??'0',),
                  ]),
            ),

             Divider(height: 1,color: Theme.of(context).hintColor.withOpacity(0.25),),

            Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: rideController.tripDetails?.vehicle != null ? Row(children: [

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(rideController.tripDetails!.vehicle != null ? rideController.tripDetails!.vehicle!.model!.name! : '',
                    style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColorDark),
                    overflow: TextOverflow.ellipsis,),

                  Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)), children:  [
                      TextSpan(text: rideController.tripDetails!.vehicle!.licencePlateNumber,
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    ],
                  ), overflow: TextOverflow.ellipsis),
                ]),

                const Spacer(),

                Container(decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).hintColor.withOpacity(0.25)),padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeThree),
                  child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusOverLarge),
                      child: ImageWidget(height: 50, width: 50,
                        image:rideController.tripDetails!.vehicle != null?
                        '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${rideController.tripDetails!.vehicle!.model!.image!}' : '',)),
                ),

              ]) : const SizedBox(),
            ),
          ]),
        );
      }
    );
  }
}
