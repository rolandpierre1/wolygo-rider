import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/profile_type_button_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/loyality_point_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/animated_expanded_fab_button.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/animated_fab_button.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/wallet_money_screen.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}
class _WalletScreenState extends State<WalletScreen> {
  bool _isExpandBafButton = true;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getTransactionList(1);
    Get.find<WalletController>().getLoyaltyPointList(1);
    Get.find<ProfileController>().getProfileInfo();
    Get.find<WalletController>().scrollController.addListener((){
      if(Get.find<WalletController>().scrollController.offset > 20){
        setState(() {
          _isExpandBafButton = false;
        });
      }else{
        setState(() {
          _isExpandBafButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Get.find<ProfileController>().getProfileInfo();
      },
      child: CustomPopScopeWidget(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GetBuilder<WalletController>(builder: (walletController) {
            return Stack(children: [
              BodyWidget(
                  appBar: AppBarWidget(title: 'wallet'.tr, centerTitle: true),
                  body:Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeSignUp),

                    Expanded(
                        child: walletController.currentTabIndex == 0 ?
                        const WalletMoneyScreen() :
                        const LoyaltyPointScreen()
                    ),
                  ])
              ),

              Positioned( top: Dimensions.topSpace,left: Dimensions.paddingSizeSmall,
                child: SizedBox(height: Get.find<LocalizationController>().isLtr? 45 : 50,
                  width: Get.width-Dimensions.paddingSizeDefault,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: walletController.walletType.length,
                    itemBuilder: (context, index){
                      return SizedBox(width: Get.width/2.2, child: ProfileTypeButtonWidget(
                        profileTypeName : walletController.walletType[index], index: index,
                      ));

                    },
                  ),
                ),
              ),
            ]);
          }),
          floatingActionButton: GetBuilder<WalletController>(builder: (walletController){
            return (((Get.find<ConfigController>().config?.externalSystem ?? false) && Get.find<AuthController>().isLoggedIn()) && walletController.currentTabIndex == 0)?
            _isExpandBafButton ? AnimatedExpandedFabButton() : AnimatedFabButton() :
            const SizedBox();
          }),
        ),
      ),
    );
  }
}
