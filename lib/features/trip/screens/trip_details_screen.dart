import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/auth/domain/enums/refund_status_enum.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/refund_request/screens/image_Video_viewer.dart';
import 'package:ride_sharing_user_app/features/refund_request/screens/refund_request_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/customer_note_view_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/parcel_details_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_info.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_details.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_item_view.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  final bool fromNotification;
  const TripDetailsScreen({super.key, required this.tripId,this.fromNotification = false});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {

  @override
  void initState() {
    if(!widget.fromNotification){
      Get.find<RideController>().getRideDetails(widget.tripId, isUpdate: false);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        body: GetBuilder<RideController>(builder: (rideController){
          return PopScope(
            onPopInvokedWithResult: (didPop, val){
              rideController.clearRideDetails();
            },
            child: BodyWidget(
              appBar: AppBarWidget(
                title: rideController.tripDetails?.type == 'parcel' ? 'parcel_details'.tr : 'trip_details'.tr,
                subTitle: rideController.tripDetails?.refId,
                showBackButton: true, centerTitle: true,
              ),
              body: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: GetBuilder<TripController>(builder: (activityController) {
                  return rideController.tripDetails != null ? Column(children: [
                    Expanded(child: SingleChildScrollView(
                      child: Column( children: [
                        TripItemView(tripDetails: rideController.tripDetails!,isDetailsScreen: true),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        if(rideController.tripDetails?.currentStatus == 'returning' && rideController.tripDetails?.returnTime != null)...[
                          Container(width: Get.width,
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeThree,horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeThree),
                                  color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.15)
                              ),
                              child: Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)), children:  [

                                TextSpan(text: 'parcel_return_estimated_time_is'.tr,
                                    style: textRegular.copyWith(color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.8),
                                        fontSize: Dimensions.fontSizeSmall)),

                                TextSpan(text: ' ${DateConverter.stringToLocalDateTime(rideController.tripDetails!.returnTime!)}',
                                    style: textSemiBold.copyWith(color: Theme.of(context).colorScheme.inverseSurface, fontSize: Dimensions.fontSizeSmall)),
                              ]), textAlign: TextAlign.center)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall)
                        ],

                        rideController.tripDetails?.type == 'parcel' ?
                        ParcelDetailsWidget(tripDetails: rideController.tripDetails!) :
                        TripDetailWidget(tripDetails: rideController.tripDetails!),

                        if(rideController.tripDetails?.currentStatus == 'returning' && rideController.tripDetails?.type == 'parcel')...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Center(child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: const Offset(0,1)
                                  )
                                ]
                            ),
                            child: Column(children: [
                              Text('${rideController.tripDetails?.otp?[0]}  ${rideController.tripDetails?.otp?[1]}  ${rideController.tripDetails?.otp?[2]}  ${rideController.tripDetails?.otp?[3]}',style: textBold.copyWith(fontSize: 20)),

                              Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)), children:  [

                                TextSpan(text: 'please_share_the'.tr,
                                    style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                                        fontSize: Dimensions.fontSizeDefault)),

                                TextSpan(text: ' OTP '.tr,
                                    style: textSemiBold.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault)),

                                TextSpan(text: 'with_the_driver'.tr, style: textRegular.copyWith(
                                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                                    fontSize: Dimensions.fontSizeDefault)),]), textAlign: TextAlign.center),
                            ]),
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          rideController.isLoading ?
                          SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0) :
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                            child: Center(child: SliderButton(
                              action: (){
                                rideController.parcelReturned(rideController.tripDetails?.id ?? '').then((value){
                                  if(value.statusCode == 200){
                                    showDialog(context: Get.context!, builder: (_){
                                      return parcelReceivedDialog();
                                    });
                                  }
                                });
                              },
                              label: Text('parcel_received'.tr,style: TextStyle(color: Theme.of(context).primaryColor)),
                              dismissThresholds: 0.5, dismissible: false, shimmer: false,
                              width: 1170, height: 40, buttonSize: 40, radius: 20,
                              icon: Center(child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                                child: Center(child: Icon(
                                  Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                                  color: Colors.grey, size: 20.0,
                                )),
                              )),
                              isLtr: Get.find<LocalizationController>().isLtr,
                              boxShadow: const BoxShadow(blurRadius: 0),
                              buttonColor: Colors.transparent,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                              baseColor: Theme.of(context).primaryColor,
                            )),
                          )
                        ],
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        if(rideController.tripDetails?.parcelRefund != null)...[
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              child: Text('refund_details'.tr, style: textSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColor,
                              )),
                            ),
                          ]),

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25))
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withOpacity(0.07),
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(Dimensions.paddingSizeDefault),topLeft: Radius.circular(Dimensions.paddingSizeDefault)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(
                                    rideController.tripDetails?.parcelRefund?.status == RefundStatus.pending ?
                                    'refund_request_send'.tr :
                                    rideController.tripDetails?.parcelRefund?.status == RefundStatus.approved ?
                                    'refund_request_approved'.tr :
                                    rideController.tripDetails?.parcelRefund?.status == RefundStatus.denied ?
                                    'refund_request_denied'.tr :
                                    rideController.tripDetails?.parcelRefund?.refundMethod == 'coupon' ?
                                    'refund_to_coupon'.tr :
                                    rideController.tripDetails?.parcelRefund?.refundMethod == 'wallet' ?
                                    'refund_to_wallet'.tr :
                                    'refund_to_manually'.tr ,
                                    style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),

                                  Text('ID# ${rideController.tripDetails?.parcelRefund?.readableId}'.tr,style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                ]),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              if(rideController.tripDetails?.parcelRefund?.status != RefundStatus.pending) CustomerNoteViewWidget(
                                title: rideController.tripDetails?.parcelRefund?.status == RefundStatus.approved ?
                                'approval_note'.tr :
                                rideController.tripDetails?.parcelRefund?.status == RefundStatus.denied ?
                                'denied_note'.tr :
                                'refund_note'.tr,

                                details: rideController.tripDetails?.parcelRefund?.status == RefundStatus.approved ?
                                rideController.tripDetails?.parcelRefund?.approvalNote ?? '' :
                                rideController.tripDetails?.parcelRefund?.status == RefundStatus.denied ?
                                rideController.tripDetails?.parcelRefund?.denyNote ?? '' :
                                rideController.tripDetails?.parcelRefund?.note ?? '',
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall)),
                                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25))
                                ),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('product_approximate_price'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                                      Text(PriceConverter.convertPrice(rideController.tripDetails?.parcelRefund?.parcelApproximatePrice ?? 0),style: textRobotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    ]),
                                  ),

                                  if(rideController.tripDetails?.parcelRefund?.status == RefundStatus.refunded)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text('refunded_amount'.tr,style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)),

                                        Text(PriceConverter.convertPrice(rideController.tripDetails?.parcelRefund?.refundAmountByAdmin ?? 0),style: textRobotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                      ]),
                                    ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  if(rideController.tripDetails?.parcelRefund?.refundMethod == 'coupon')
                                    InkWell(
                                      onTap: (){
                                        Get.find<CouponController>().getCouponList(1, isUpdate: false);
                                        Get.to(()=> MyOfferScreen(isCoupon: true));
                                      },
                                      child: Container(
                                        width: Get.width,
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).hintColor.withOpacity(0.07),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(Dimensions.paddingSizeExtraSmall),
                                            bottomRight: Radius.circular(Dimensions.paddingSizeExtraSmall),
                                          ),
                                        ),
                                        child: Center(child: Text(
                                          (rideController.tripDetails?.parcelRefund?.isCouponUsed ?? false) ?
                                          'coupon_used'.tr : 'check_coupon'.tr,
                                          style: textRegular.copyWith(color: Theme.of(context).colorScheme.surfaceContainer),
                                        )),
                                      ),
                                    )

                                ]),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              if(rideController.tripDetails?.parcelRefund?.reason?.isNotEmpty ?? false) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: Text('refund_reason'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).colorScheme.secondaryFixedDim)),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: Text(rideController.tripDetails?.parcelRefund?.reason ?? '',style: textSemiBold),
                                ),
                              ],
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              if(rideController.tripDetails?.parcelRefund?.customerNote?.isNotEmpty ?? false) CustomerNoteViewWidget(
                                title: 'customer_note'.tr,
                                details: rideController.tripDetails?.parcelRefund?.customerNote ?? '',
                                edgeInsets: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeSmall,left: Dimensions.paddingSizeSmall,
                                    right: Dimensions.paddingSizeSmall
                                ),
                                child: Text('uploaded_medias'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).colorScheme.secondaryFixedDim)),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: rideController.tripDetails?.parcelRefund?.attachments?.length,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, // number of items in each row
                                        mainAxisSpacing: Dimensions.paddingSizeSmall, // spacing between rows
                                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                                        childAspectRatio: 2// spacing between columns
                                    ),
                                    itemBuilder: (context, index){
                                      return InkWell(
                                        onTap: ()=> Get.to(()=> ImageVideoViewer(attachments: rideController.tripDetails?.parcelRefund?.attachments,fromNetwork: true,clickedIndex: index)),
                                        child: Stack(children: [
                                          Container(
                                            height: 100,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.secondaryFixedDim.withOpacity(0.05),
                                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                              child: (rideController.tripDetails?.parcelRefund?.attachments?[index].file ?? '').contains('.mp4') ?
                                              Image.file(File(rideController.thumbnailPaths![index]), fit: BoxFit.cover, errorBuilder: (_, __, ___)=> const SizedBox(),) :
                                              ImageWidget(
                                                image: rideController.tripDetails?.parcelRefund?.attachments?[index].file ?? '',
                                                fit: BoxFit.fitHeight,
                                              ),
                                            ),
                                          ),

                                          if((rideController.tripDetails?.parcelRefund?.attachments?[index].file ?? '').contains('.mp4'))
                                            Align(alignment: Alignment.center, child: Image.asset(Images.playButtonIcon))
                                        ]),
                                      );
                                    }
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          if(rideController.tripDetails?.parcelRefund?.status == RefundStatus.pending)
                            ButtonWidget(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                              buttonText: 'refund_request_send'.tr,
                              textColor: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5) : null,
                            )
                        ],

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        if(rideController.tripDetails?.driver != null) ...[
                          RiderInfo(tripDetails: rideController.tripDetails!)
                        ],

                        if((Get.find<ConfigController>().config?.parcelRefundStatus ?? false) &&
                            _refundTimeValidity(rideController.tripDetails?.parcelCompleteTime ?? '2000-09-21 14:42:07') &&
                            rideController.tripDetails?.type == 'parcel' && rideController.tripDetails?.currentStatus == 'completed' &&
                            rideController.tripDetails?.parcelRefund == null
                        )...[

                          Text('if_your_parcel_is_damaged'.tr,style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).colorScheme.secondaryFixedDim
                          ),textAlign: TextAlign.center),
                          const SizedBox(height: Dimensions.paddingSizeSeven),

                          InkWell(
                            onTap: ()=> Get.to(()=> RefundRequestScreen(tripId: widget.tripId)),
                            child: Text(
                              'refund_request'.tr,
                              style: textRegular.copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Theme.of(context).colorScheme.inverseSurface,
                                  color: Theme.of(context).colorScheme.inverseSurface
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ]),
                    )),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    (Get.find<ConfigController>().config!.reviewStatus! &&
                        ! (rideController.tripDetails?.isReviewed ?? false) &&
                        rideController.tripDetails?.driver != null &&
                        rideController.tripDetails?.paymentStatus == 'paid' &&
                        _isReviewButtonShown(rideController.tripDetails?.parcelRefund?.status)) ?
                    ButtonWidget(
                      buttonText: 'give_review'.tr,
                      onPressed: () => Get.to(() => ReviewScreen(tripId: widget.tripId)),
                    ) : const SizedBox()
                  ]) : const LoaderWidget();

                }),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _isReviewButtonShown(RefundStatus? refundStatus){
    return refundStatus == RefundStatus.pending
        ? false
        : refundStatus == RefundStatus.approved
        ? false
        : true;
  }

  Widget parcelReceivedDialog(){
    return Dialog(
      surfaceTintColor:Get.isDarkMode ? Theme.of(context).hintColor  : Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,
          vertical: 10,
        ),
        child: SizedBox(width: Get.width,
          child: Column(mainAxisSize:MainAxisSize.min, children: [
            Align(alignment: Alignment.topRight,
              child: InkWell(onTap: ()=> Get.back(), child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Image.asset(
                  Images.crossIcon,
                  height: Dimensions.paddingSizeSmall,
                  width: Dimensions.paddingSizeSmall,
                  color: Theme.of(context).cardColor,
                ),
              )),
            ),

            Image.asset(Images.parcelReturnSuccessIcon,height: 80,width: 80),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.2),
              child: Text('your_parcel_returned_successfully'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),textAlign: TextAlign.center),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge)

          ]),
        ),
      ),
    );
  }

  bool _refundTimeValidity(String stringDateTime){
    int time = Get.find<ConfigController>().config?.parcelRefundValidityType == 'hour' ?
    DateTime.now().difference(DateConverter.dateTimeStringToDate(stringDateTime)).inHours :
    DateTime.now().difference(DateConverter.dateTimeStringToDate(stringDateTime)).inDays;
    return time > (Get.find<ConfigController>().config?.parcelRefundValidity ?? 0) ? false : true;
  }


}

