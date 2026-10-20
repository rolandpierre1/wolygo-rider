import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';


class ResetPasswordScreen extends StatefulWidget {
  final bool fromChangePassword;
  final String phoneNumber;
  const ResetPasswordScreen({super.key,  this.fromChangePassword = false, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode oldPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(appBar: AppBarWidget(title: widget.fromChangePassword ? 'change_password'.tr : 'reset_password'.tr,
        showBackButton: true, centerTitle: true,
        onBackPressed: (){
          if(widget.fromChangePassword){
            Get.back();
          }else{
            Get.off(()=> const ForgotPasswordScreen());
          }
        },
      ),
        body: SingleChildScrollView(
          child: GetBuilder<AuthController>(builder: (authController){
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          
                widget.fromChangePassword ?
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextFieldTitle(title: 'old_password'.tr),
                  CustomTextField(
                    hintText: 'password_hint'.tr,
                    inputType: TextInputType.text,
                    prefixIcon: Images.password,
                    isPassword: true,
                    controller: oldPasswordController,
                    focusNode: oldPasswordFocus,
                    nextFocus: passwordFocusNode,
                    inputAction: TextInputAction.next,
                  ),
                ]) : const SizedBox(),
          
                TextFieldTitle(title: 'new_password'.tr),
                CustomTextField(
                  hintText: 'password_hint'.tr,
                  inputType: TextInputType.text,
                  prefixIcon: Images.password,
                  isPassword: true,
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  nextFocus: confirmPasswordFocusNode,
                  inputAction: TextInputAction.next,
                ),
          
                TextFieldTitle(title: 'confirm_new_password'.tr),
                CustomTextField(
                  hintText: 'confirm_password'.tr,
                  inputType: TextInputType.text,
                  prefixIcon: Images.password,
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  inputAction: TextInputAction.done,
                  isPassword: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault * 3),
          
                authController.isLoading ? Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0,)) : ButtonWidget(
                  buttonText: widget.fromChangePassword? 'update'.tr : 'save'.tr,
                  onPressed: () {
                    String oldPassword = oldPasswordController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;
          
                    if(password.isEmpty) {
                      showCustomSnackBar('password_is_required'.tr);
                    }else if(password.length < 6) {
                      showCustomSnackBar('minimum_password_length_is_8'.tr);
                    }else if(confirmPassword.isEmpty) {
                      showCustomSnackBar('confirm_password_is_required'.tr);
                    }else if(password != confirmPassword) {
                      showCustomSnackBar('password_is_mismatch'.tr);
                    }else if(oldPassword.isEmpty && widget.fromChangePassword) {
                      showCustomSnackBar('previous_password_is_required'.tr);
                    }else {
                      if(widget.fromChangePassword) {
                        authController.changePassword(oldPassword, password);
                      }else{
                        authController.resetPassword(widget.phoneNumber, password);
                      }
                    }
                  },
                  radius: 50,
                ),
          
              ]),
            );
          }),
        ),

      ),
    );
  }
}
