import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/notification/domain/models/notification_model.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NotificationCard extends StatelessWidget {
  final Notifications notification;
  final Notifications? previousNotification;
  final Notifications? nextNotification;
  const NotificationCard({super.key, required this.notification, required this.nextNotification, required this.previousNotification});

  @override
  Widget build(BuildContext context) {
    int currentNotificationMinutes = calculateMinute(notification.createdAt!);
    return InkWell(
      onTap: () {
        Get.bottomSheet(Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.paddingSizeLarge),
              topRight: Radius.circular(Dimensions.paddingSizeLarge),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(mainAxisSize: MainAxisSize.min,children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Image.asset(
                  _isRefundIcon(notification.action ?? '') ? Images.parcelRefundIcon :
                  notification.action == 'referral_reward_received' ?
                  Images.notificationEarningIcon :
                  notification.action == 'someone_used_your_code' ?
                  Images.notificationReferralIcon :
                  Images.notificationCarIcon,
                  width: 20,height: 20,
                  fit: BoxFit.cover,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(notification.title ?? '',
                  style: textBold.copyWith(fontSize: 16,color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.9) : null),
                  textAlign: TextAlign.center
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                notification.description ?? '',textAlign: TextAlign.center,
                style: textRegular.copyWith(
                    color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

                InkWell(
                    onTap: (){
                      if(notification.action == 'referral_reward_received'){
                        Get.find<ReferAndEarnController>().updateCurrentTabIndex(1);
                        Get.to(() => const ReferAndEarnScreen());
                      }else if(notification.action == 'someone_used_your_code' && (Get.find<ConfigController>().config?.referralEarningStatus ?? false)){
                        Get.find<ReferAndEarnController>().updateCurrentTabIndex(0);
                        Get.to(() => const ReferAndEarnScreen());
                      }else if(notification.action == 'parcel_refund_request_approved' || notification.action == 'parcel_refund_request_denied'){
                        Get.to(() =>  TripDetailsScreen(tripId: notification.rideRequestId ?? ''));
                      }else if(notification.action == 'refunded_as_coupon'){
                        Get.to(() => MyOfferScreen(isCoupon: true));
                      }else{
                        Get.to(() => const WalletScreen());
                      }
                    },
                    child: Text(
                      notification.action == 'referral_reward_received' ?
                        'earning_history'.tr :
                      notification.action == 'someone_used_your_code' && (Get.find<ConfigController>().config?.referralEarningStatus ?? false) ?
                      'referral_details'.tr :
                      notification.action == 'parcel_refund_request_approved' || notification.action == 'parcel_refund_request_denied' ?
                      'parcel_details'.tr :
                      notification.action == 'refunded_as_coupon' ?
                      'coupons'.tr :
                      notification.action == 'refunded_to_wallet' ?
                      'my_wallet'.tr : '',
                        style: textRegular.copyWith(color: Theme.of(context).colorScheme.surfaceContainer,decoration: TextDecoration.underline),
                    )
                ),
              const SizedBox(height: 30),
            ]),
          ),
        ));
      },
      child: Column(children: [
        if(previousNotification == null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now()) ?
          'today'.tr :
          DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
          'last_day'.tr :
          DateConverter.isoDateTimeStringToDateOnly(notification.createdAt!),
          style: textRegular.copyWith(color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null)),
        ),

        Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode ?
              Theme.of(context).scaffoldBackgroundColor :
              Theme.of(context).primaryColor.withOpacity(0.07),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeLarge,
            ),
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ?
                  Theme.of(context).scaffoldBackgroundColor :
                  Theme.of(context).primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Image.asset(
                  _isRefundIcon(notification.action ?? '') ? Images.parcelRefundIcon :
                  notification.action == 'referral_reward_received' ?
                  Images.notificationEarningIcon :
                  notification.action == 'someone_used_your_code' ?
                  Images.notificationReferralIcon :
                  Images.notificationCarIcon,
                  width: 20,height: 20,
                  fit: BoxFit.cover,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraLarge),
                      child: Text(notification.title ?? '',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.9) : null
                        ),
                        maxLines: 1,overflow: TextOverflow.ellipsis,
                      ),
                    )),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text(
                          currentNotificationMinutes < 60 ?
                          '$currentNotificationMinutes ${'min_ago'.tr}' :
                          DateConverter.isoDateTimeStringToLocalTime(notification.createdAt!),
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Icon(
                          Icons.alarm,
                          size: Dimensions.fontSizeLarge,
                          color: Theme.of(context).hintColor.withOpacity(0.5),
                        ),
                      ]),
                    ),
                  ]),

                  Text(notification.description ?? '',maxLines: 1,overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null)
                  ),

                ]),
              ),
            ]),
          ),

          if(((nextNotification == null) && (previousNotification != null) &&
              (DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) != DateConverter.isoStringToLocalDateAndMonthOnly(previousNotification!.createdAt!))))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
              'last_day'.tr :
              DateConverter.isoDateTimeStringToDateOnly(notification.createdAt ?? '2024-07-13T04:59:40.000000Z'),
              style: textRegular.copyWith(color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null)),
            ),

          if((nextNotification != null) &&
              (DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) != DateConverter.isoStringToLocalDateAndMonthOnly(nextNotification!.createdAt!)))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(nextNotification!.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
              'last_day'.tr :
              DateConverter.isoDateTimeStringToDateOnly(nextNotification?.createdAt ?? '2024-07-13T04:59:40.000000Z'),
              style: textRegular.copyWith(color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8) : null)),
            ),
      ]),
    );
  }

  bool _isRefundIcon(String action) {
    List<String> actionList = [
      'parcel_refund_request_approved',
      'parcel_refund_request_denied',
      'refunded_as_coupon',
      'refunded_to_wallet'
    ];

    return actionList.contains(action);
  }
}

int calculateMinute(String isoDateTime){
  DateTime dateTime = DateConverter.isoStringToLocalDate(isoDateTime);
  return DateTime.now().difference(dateTime).inMinutes;
}

