import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';

class TollTipWidget extends StatefulWidget {
  
  final String title;
  final bool showInsight;
  const TollTipWidget({super.key, required this.title,  this.showInsight = true});

  @override
  State<TollTipWidget> createState() => _TollTipWidgetState();
}

class _TollTipWidgetState extends State<TollTipWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.title.tr, style: textMedium.copyWith(color: Theme.of(context).primaryColor)),
       if(widget.showInsight)
        InkWell(onTap: () => Get.to(() => const PolicyScreen(htmlType: HtmlType.termsAndConditions)),
          child: Container(decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor.withOpacity(0.1)),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
                Text('insight'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),),
                const SizedBox(width: 3,),
                Icon(Icons.info,color: Theme.of(context).primaryColor.withOpacity(0.6),size: 15)])))
      ],
    );
  }
}
