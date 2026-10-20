import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ContactWithWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String message;
  final String data;
  const ContactWithWidget({super.key, required this.title, required this.subTitle, required this.message, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
      child: Column(children: [
        Text(
          title.tr,
          style: textSemiBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(subTitle.tr, style: textRegular.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                fontSize: Dimensions.fontSizeSmall
            )),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(title == 'contact_us_through_email' ? Icons.email : Icons.phone_enabled,size: 14),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(data,style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              message.tr,style: textRegular.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                fontSize: Dimensions.fontSizeExtraSmall),
              textAlign: TextAlign.center,
            ),

          ]),
        ),

      ]),
    );
  }
}
