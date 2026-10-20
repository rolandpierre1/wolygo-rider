import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/support/widgets/contact_with_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Center(child: Image.asset(Images.helpAndSupport, width: 172, height: 129)),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ContactWithWidget(
            title: 'contact_us_through_email',
            subTitle: 'you_can_send_us_email_through',
            message: "typically_the_support_team_send_you_any_feedback",
            data: Get.find<ConfigController>().config!.businessContactEmail!,
          ),
          const SizedBox(height: Dimensions.paddingSizeSignUp),

          ContactWithWidget(
            title: 'contact_us_through_phone',
            subTitle: 'contact_us_through_our_customer_care_number',
            message: "talk_with_our_customer",
            data: Get.find<ConfigController>().config!.businessContactPhone!,
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ButtonWidget(
            width: Get.width/2.65,
            radius: Dimensions.radiusExtraLarge,
            buttonText: 'email'.tr,
            icon: Icons.email,
            onPressed: () async {
              await launchUrl(
                Uri(scheme: 'mailto', path: Get.find<ConfigController>().config!.businessContactEmail!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width / 20),
          ButtonWidget(
            width: Get.width/2.65,
            radius: Dimensions.radiusExtraLarge,
            buttonText: 'call'.tr,
            icon: Icons.call,
            onPressed: () async {
              await launchUrl(
                Uri(scheme: 'tel', path: Get.find<ConfigController>().config!.businessContactPhone!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ]),

      ]),
    );
  }
}