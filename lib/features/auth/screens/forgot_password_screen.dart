import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController phoneController = TextEditingController();

  FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().countryDialCode =
    CountryCode.fromCountryCode(Get.find<ConfigController>().config!.countryCode!).dialCode!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: 'forget_password'.tr),
        body: Center(child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeLarge),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Center(child: Image.asset(Images.forgotPasswordLogo, width: 150)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ]),

                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text('forgot_password'.tr,
                      style: textBold.copyWith(color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeExtraLarge),
                    ),
                    Text(
                      'enter_your_verified_phone_number'.tr,
                      style: textRegular.copyWith(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge)
                  ]),
                ]),

                CustomTextField(
                  isCodePicker: true,
                  hintText: 'phone'.tr,
                  inputType: TextInputType.number,
                  countryDialCode: Get.find<AuthController>().countryDialCode,
                  prefixHeight: 70,
                  controller: phoneController,
                  focusNode: phoneNode,
                  inputAction: TextInputAction.done,
                  onCountryChanged: (CountryCode countryCode){
                    Get.find<AuthController>().countryDialCode = countryCode.dialCode!;
                    Get.find<AuthController>().setCountryCode(Get.find<AuthController>().countryDialCode);

                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                authController.isOtpSending ?
                Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0)) :
                ButtonWidget(
                  buttonText: 'send_otp'.tr,
                  onPressed: () {
                    String phoneNumber = phoneController.text;
                    if(phoneNumber.isEmpty) {
                      showCustomSnackBar('enter_your_phone_number'.tr);
                      FocusScope.of(context).requestFocus(phoneNode);
                    }else if(!GetUtils.isPhoneNumber(Get.find<AuthController>().countryDialCode + phoneNumber)) {
                      showCustomSnackBar('phone_number_is_not_valid'.tr);
                    }else {

                      if(Get.find<ConfigController>().config?.isFirebaseOtpVerification ?? false){
                        authController.firebaseOtpSend(authController.countryDialCode + phoneNumber, isLogin: false);
                      }else if (Get.find<ConfigController>().config?.isSmsGateway ?? false){
                        authController.sendOtp(authController.countryDialCode + phoneNumber).then((value) {
                          if(value.statusCode == 200) {
                            Get.to(() =>  VerificationScreen(
                              number: authController.countryDialCode + phoneNumber,
                              fromOtpLogin: false,
                            ));
                          }
                        });
                      }else{
                        showCustomSnackBar('sms_gateway_not_integrate'.tr);
                      }
                    }
                  },
                  radius: 50,
                ),
              ],
            );
          }),
        )),
      ),
    );
  }
}
