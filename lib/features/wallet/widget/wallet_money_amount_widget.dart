import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/point_to_wallet_money_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';

class WalletMoneyAmountWidget extends StatelessWidget {
  final bool walletMoney;
  const  WalletMoneyAmountWidget({super.key,  this.walletMoney = false});

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<WalletController>(builder: (walletController) {
      return GetBuilder<ProfileController>(
        initState: (context){
          Get.find<ProfileController>().getProfileInfo();
        },
        builder: (profileController) {
          return InkWell(
            onTap: () {
              if(!walletMoney) {
                if(Get.find<ConfigController>().config?.conversionStatus ?? false) {
                  showDialog(barrierDismissible: false,
                    context: context, builder: (_) => const PointToWalletMoneyWidget(),
                  );
                }else {
                  showCustomSnackBar('point_conversion_is_currently_unavailable'.tr);
                }
              }
            },
            child: Padding(padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,0, Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall),
              child: DottedBorder(
                dashPattern: const [1, 1],
                borderType: BorderType.RRect, color : Theme.of(context).primaryColor,
                radius: const Radius.circular(Dimensions.paddingSizeDefault),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraLarge,
                        vertical: Dimensions.paddingSizeExtraLarge,
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [

                        Row(children: [
                          Image.asset(walletMoney ? Images.walletMoney : Images.loyaltyPoint, height: 25, width: 25),

                          if(!walletMoney)...[
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Text('${'your_points'.tr}:',style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)))
                          ],

                          walletMoney ?
                          const SizedBox(width: Dimensions.paddingSizeDefault) : const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            walletMoney ? PriceConverter.convertPrice(profileController.profileModel?.data?.wallet?.walletBalance ?? 0)
                                : (profileController.profileModel?.data?.loyaltyPoints ?? '0').toString(),
                            style: textRobotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                        ]),

                        walletMoney ? const SizedBox() :
                        Icon(
                          Icons.arrow_forward_ios,size: Dimensions.iconSizeMedium,
                          color: Theme.of(context).primaryColor,
                        ),

                      ]),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
