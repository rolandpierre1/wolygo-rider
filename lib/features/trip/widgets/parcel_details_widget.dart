import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/parcel_item_info_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_route_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ParcelDetailsWidget extends StatelessWidget {
  final TripDetails tripDetails;
  const ParcelDetailsWidget({super.key,required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    String firstRoute = '';
    String secondRoute = '';
    List<dynamic> extraRoute = [];
    if(tripDetails.intermediateAddresses != null && tripDetails.intermediateAddresses != '[[, ]]'){
      extraRoute = jsonDecode(tripDetails.intermediateAddresses!);

      if(extraRoute.isNotEmpty){
        firstRoute = extraRoute[0];
      }
      if(extraRoute.isNotEmpty && extraRoute.length>1){
        secondRoute = extraRoute[1];
      }

    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('trip_details'.tr,style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColor),),
          const SizedBox(height: Dimensions.paddingSizeSmall,),

          TripRouteWidget(pickupAddress: tripDetails.pickupAddress!,
            destinationAddress: tripDetails.destinationAddress!,
            extraOne: firstRoute,extraTwo: secondRoute,entrance: tripDetails.entrance,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault,),

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Image.asset(Images.profileMyWallet,height: 15,width: 15,),
                const SizedBox(width: Dimensions.paddingSizeSmall,),
                Text('total_distance'.tr,
                  style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ]),
              Text('${tripDetails.actualDistance!}km',
                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                  fontSize: Dimensions.fontSizeSmall,
                ),
              )
            ]
            ),
          )
        ],
        ),
      ),

      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25))
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(children: [
          ParcelItemInfoWidget(icon: Images.deliveryDetailsIcon,title: 'delivery_fee'.tr,amount: tripDetails.distanceWiseFare??0),
          if(tripDetails.currentStatus == 'returning' || tripDetails.currentStatus == 'returned')
          ParcelItemInfoWidget(icon: Images.returnDetailsIcon,title: 'return_fee'.tr,amount: tripDetails.returnFee??0),
          ParcelItemInfoWidget(icon: Images.coupon, title: 'coupon'.tr, amount: tripDetails.couponAmount??0, discount: true,),
          ParcelItemInfoWidget(icon: Images.coupon, title: 'discount'.tr, amount: tripDetails.discountAmount??0, discount: true,),
          ParcelItemInfoWidget(icon: Images.farePrice,title: 'tips'.tr,amount: tripDetails.tips??0),
          ParcelItemInfoWidget(icon: Images.farePrice,title: 'vat_tax'.tr,amount: tripDetails.vatTax??0),
          Divider(color: Theme.of(context).hintColor.withOpacity(0.15)),
          ParcelItemInfoWidget(title: 'total'.tr,amount: tripDetails.paidFare??0, isSubTotal: true),
          if(tripDetails.currentStatus == 'returning')...[
            ParcelItemInfoWidget(icon: Images.farePrice,title: 'paid'.tr,amount: (tripDetails.paidFare??0) - (tripDetails.dueAmount??0 )),
            ParcelItemInfoWidget(icon: Images.farePrice,title: 'due'.tr,amount: tripDetails.dueAmount??0),
          ],

          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Image.asset(Images.profileMyWallet,height: 15,width: 15,),
              const SizedBox(width: Dimensions.paddingSizeSmall,),
              Text('payment'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeSmall))
            ]),

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    tripDetails.paymentMethod!.tr,
                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).primaryColor)
                )
            )
          ]),

          _ParcelTrackWidget(tripDetails: tripDetails),

        ],
        ),
      )
    ],
    );
  }

}

class _ParcelTrackWidget extends StatelessWidget {
  final TripDetails tripDetails;
  const _ParcelTrackWidget({
    super.key, required this.tripDetails,
  });

  @override
  Widget build(BuildContext context) {
    return tripDetails.type == 'parcel' ? Column(children: [
      const SizedBox(height: Dimensions.paddingSizeDefault),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryFixedDim.withOpacity(0.05),
          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text('parcel_track'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            InkWell(
              onTap: (){
                showCustomSnackBar('copied'.tr,isError: false);
                Clipboard.setData(ClipboardData(text: _getParcelTrackUrl(tripDetails.refId)));
              },
              child: const Icon(Icons.copy, size: Dimensions.iconSizeSmall),
            ),
          ]),

          ButtonWidget(
            fontSize: Dimensions.fontSizeSmall,
            buttonText: 'track_now'.tr,
            width: 80, height: 32,
            onPressed: ()=> launchUrl(Uri.parse(_getParcelTrackUrl(tripDetails.refId))),
          ),
        ]),
      ),

    ]) : const SizedBox();
  }
  String _getParcelTrackUrl(String? refId) => '${AppConstants.baseUrl}/track-parcel/$refId';

}
