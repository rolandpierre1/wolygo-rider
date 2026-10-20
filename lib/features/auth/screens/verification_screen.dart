import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final bool fromOtpLogin;
  final String? session;
  const VerificationScreen({super.key,required this.number,  this.fromOtpLogin = false, this.session});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().updateVerificationCode('',isUpdate: false);
    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<ConfigController>().config!.otpResendTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: 'verification'.tr, showBackButton: true, centerTitle: true),
        body: Center(child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeLarge),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(Images.verification, width: 120),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                Text('enter_verification_code'.tr,style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                (Get.find<ConfigController>().config?.isDemo ?? true) ? Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(
                    bottom: Dimensions.paddingSizeOverLarge,
                  ),
                  child: Text('for_demo_purpose_use'.tr, style: textSemiBold.copyWith(
                    color: Theme.of(context).disabledColor,
                  )),
                ) : const SizedBox(height:  Dimensions.paddingSizeExtraLarge,),

                SizedBox(
                  width: Get.width - 60,
                  child: PinCodeTextField(
                    length: 6,
                    appContext: context,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.slide,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      fieldHeight: 40,
                      fieldWidth: 40,
                      borderWidth: 1,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      selectedFillColor: Get.isDarkMode?Colors.grey.withOpacity(0.6):Colors.white,
                      inactiveFillColor: Theme.of(context).cardColor,
                      inactiveColor: Theme.of(context).hintColor,
                      activeColor: Theme.of(context).hintColor,
                      activeFillColor: Theme.of(context).cardColor,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: authController.updateVerificationCode,
                    beforeTextPaste: (text) => true,
                    textStyle: textSemiBold.copyWith(),

                    pastedTextStyle: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
                  ),
                ),

                _seconds! <= 0 ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('did_not_receive_the_code'.tr,style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.6)),),
                    TextButton(
                      onPressed: () async {
                        if(Get.find<ConfigController>().config?.isFirebaseOtpVerification ?? false){

                          await authController.firebaseOtpSend(widget.number,canRoute: false);
                          showCustomSnackBar('otp_sent_successfully'.tr, isError: false);

                          _startTimer();

                        }else if(Get.find<ConfigController>().config?.isSmsGateway ?? false){
                          authController.sendOtp(widget.number).then((value){
                            if(value.statusCode == 200) {
                              _startTimer();
                            }
                          });
                        }else{
                          showCustomSnackBar('sms_gateway_not_integrate'.tr);
                        }
                      },
                      child: Text('resend_it'.tr,style: textBold.copyWith(color: Theme.of(context).primaryColorDark.withOpacity(.6)),
                          textAlign: TextAlign.end),
                    ),
                  ],
                ) : const SizedBox(),

                _seconds! > 0 ? Text(
                  '${'resend_it'.tr} ${'after'.tr} ${_seconds! > 0 ? '($_seconds)' : ''} ${'sec'.tr}',
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                authController.verificationCode.length == 6 ? !authController.otpVerifying ?  Padding(
                  padding:  const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge,),
                  child: ButtonWidget(
                    buttonText: 'submit'.tr,
                    radius: 50,
                    onPressed: () {
                      authController.otpVerification(
                        widget.number, authController.verificationCode, accountVerification: widget.fromOtpLogin,
                        session: widget.session
                      );
                    },
                  ),
                ) :  SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0,) : const SizedBox.shrink(),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              ],
            );
          }),
        )),
      ),
    );
  }
}
