
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/widget/offer_coupon_card_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/widgets/no_coupon_widget.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';


class DiscountAndCouponBottomSheet extends StatefulWidget {
  const DiscountAndCouponBottomSheet({super.key});

  @override
  State<DiscountAndCouponBottomSheet> createState() => _DiscountAndCouponBottomSheetState();
}

class _DiscountAndCouponBottomSheetState extends State<DiscountAndCouponBottomSheet> {
  bool isCoupon = false;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius:const BorderRadius.only(topRight: Radius.circular(Dimensions.paddingSizeLarge), topLeft: Radius.circular(Dimensions.paddingSizeLarge))
    ),
      child: SingleChildScrollView(controller: scrollController,
        child: Column(children: [

          InkWell(onTap: ()=> Get.back(),
            child: Align(alignment: Alignment.topRight,
                child: Container(decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50)),

                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Image.asset(Images.crossIcon,height: 10,width: 10,))),
          ),

          Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25),),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              InkWell(onTap: (){
                isCoupon = false;
                setState(() {});},
                child: Container( decoration: BoxDecoration(
                    color: isCoupon ? null : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50)),
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                      child: Text('discounts'.tr,style: textRegular.copyWith(color: isCoupon ? Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.65) : Theme.of(context).cardColor)),
                    )),
              ),

              InkWell(onTap: (){
                isCoupon = true;
                setState(() {});},
                child: Container( decoration: BoxDecoration(
                    color: isCoupon ? Theme.of(context).primaryColor : null,
                    borderRadius: BorderRadius.circular(50)),
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                      child: Text('coupons'.tr,style: textRegular.copyWith(color: !isCoupon ? Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.65) : Theme.of(context).cardColor)),
                    )),
              ),
            ],),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault,),
          !isCoupon ?
          GetBuilder<OfferController>(builder: (offerController){
            return (offerController.bestOfferModel!.data!= null && offerController.bestOfferModel!.data!.isNotEmpty) ?
             PaginatedListWidget(scrollController: scrollController,
                onPaginate: (int? offset) async {
                  await offerController.getOfferList(offset!);
                },
                totalSize: offerController.bestOfferModel?.totalSize,
                offset: int.parse(offerController.bestOfferModel!.offset.toString()),
                itemView: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: offerController.bestOfferModel!.data!.length,itemBuilder: (context, index){
                    return Container(width: Get.width, padding: const EdgeInsets.all(Dimensions.paddingSizeSmall ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).hintColor.withOpacity(0.15 )),
                      child:  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(offerController.bestOfferModel!.data![index].title ?? '',style: textBold,),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                        Text(offerController.bestOfferModel!.data![index].shortDescription ?? '',style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)),),

                        const SizedBox(height: Dimensions.paddingSizeDefault,),
                        Text('${'valid'.tr}: ${DateConverter.stringToLocalDateOnly(offerController.bestOfferModel!.data![index].endDate!)}',style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5)),),
                      ],),
                    );},

                  separatorBuilder: (context, index){
                    return const SizedBox(height: Dimensions.paddingSizeDefault,);
                  },)) : NoCouponWidget(
              title: 'no_discount_found'.tr,
              description: 'sorry_there_is_no_discount'.tr,
            );
          }) :
          GetBuilder<CouponController>(builder: (couponController){
            return (couponController.couponModel!.data != null && couponController.couponModel!.data!.isNotEmpty) ?
             PaginatedListWidget(scrollController: scrollController,
                 onPaginate: (int? offset) async {
                   await couponController.getCouponList(offset!);
                 },
                 totalSize: couponController.couponModel?.totalSize,
                 offset: int.parse(couponController.couponModel!.offset.toString()),
                 itemView: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                   itemCount: couponController.couponModel!.data!.length,itemBuilder: (context, index){
                     return OfferCouponCardWidget(fromCouponScree: false,coupon: couponController.couponModel!.data![index],index: index,);
                   },
                   separatorBuilder: (context, index){
                     return const SizedBox(height: Dimensions.paddingSizeDefault,);
                   },)) : NoCouponWidget(
              title: 'no_coupon_available'.tr,
              description: 'sorry_there_is_no_coupon'.tr,
            );})
        ],),
      ),
    );
  }
}
