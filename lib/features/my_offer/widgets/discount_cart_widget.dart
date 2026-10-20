import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/domain/models/best_offer_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DiscountCartWidget extends StatelessWidget {
  final OfferModel offerModel;
  const DiscountCartWidget({super.key, required this.offerModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          width: Get.width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusOverLarge),
            child: ImageWidget(image: offerModel.image!,fit: BoxFit.cover),
          ),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(width: Get.width *0.8,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(offerModel.title ?? '',
                  style: Get.isDarkMode ? textBold.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.9)) : textBold,
                  overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                offerModel.shortDescription ?? '',
                style: Get.isDarkMode ? textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7)) :
                textRegular.copyWith(color: Theme.of(context).hintColor),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                '${'valid'.tr}: ${DateConverter.stringToLocalDateOnly(offerModel.endDate!)}',
                style: Get.isDarkMode ?
                textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7)) :
                textRegular.copyWith(color: Theme.of(context).hintColor),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),

          Icon(Icons.arrow_forward_ios_outlined,color: Theme.of(context).primaryColor)
        ])
      ]),
    );
  }
}
