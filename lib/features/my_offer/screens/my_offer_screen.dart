import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/widget/offer_coupon_card_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/discount_screen.dart';
import 'package:ride_sharing_user_app/features/my_offer/widgets/discount_cart_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/widgets/no_coupon_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MyOfferScreen extends StatefulWidget {
  bool isCoupon;
  MyOfferScreen({super.key, this.isCoupon = false});

  @override
  State<MyOfferScreen> createState() => _MyOfferScreenState();
}

class _MyOfferScreenState extends State<MyOfferScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    if(Get.find<OfferController>().bestOfferModel == null){
      Get.find<OfferController>().getOfferList(1);
    }
    if(Get.find<CouponController>().couponModel == null){
      Get.find<CouponController>().getCouponList(1,isUpdate: false);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(title: 'my_offer'.tr,showBackButton: true),
          body: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Stack(children: [
              Column(children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25)),
                    borderRadius: const  BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    InkWell(
                      onTap: (){
                        widget.isCoupon = false;
                        setState(() {});
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isCoupon ?
                          null : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Text(
                            'discounts'.tr,
                            style: textRegular.copyWith(color: widget.isCoupon ?
                            Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.65) :
                            Theme.of(context).colorScheme.errorContainer,
                            ),
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        widget.isCoupon = true;
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isCoupon ? Theme.of(context).primaryColor : null,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Text(
                            'coupons'.tr,
                            style: textRegular.copyWith(
                              color: !widget.isCoupon ?
                              Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.65) :
                              Theme.of(context).colorScheme.errorContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                Expanded(child: SingleChildScrollView(controller: scrollController,
                  child: Column(children: [
                    !widget.isCoupon ?
                    GetBuilder<OfferController>(builder: (offerController){
                      return (offerController.bestOfferModel!.data!= null && offerController.bestOfferModel!.data!.isNotEmpty) ?
                      PaginatedListWidget(
                        scrollController: scrollController,
                        onPaginate: (int? offset) async {
                          await offerController.getOfferList(offset!);
                        },
                        totalSize: offerController.bestOfferModel?.totalSize,
                        offset: int.parse(offerController.bestOfferModel!.offset.toString()),
                        itemView: ListView.separated(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          itemCount: offerController.bestOfferModel!.data!.length,
                          itemBuilder: (context, index){
                            return InkWell(
                              onTap: (){
                                Get.to(()=>  DiscountScreen(offerModel: offerController.bestOfferModel!.data![index]));
                              },

                              child: DiscountCartWidget(offerModel: offerController.bestOfferModel!.data![index]),
                            );
                          },
                          separatorBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSeven),
                              child: Divider(color: Theme.of(context).hintColor.withOpacity(0.25)),
                            );
                          },
                        ),
                      ) :
                      NoCouponWidget(
                        title: 'no_discount_found'.tr,
                        description: 'sorry_there_is_no_discount'.tr,
                      );
                    }) :

                    GetBuilder<CouponController>(builder: (couponController){
                      return
                        (couponController.couponModel!.data != null &&
                            couponController.couponModel!.data!.isNotEmpty) ?
                        PaginatedListWidget(
                          scrollController: scrollController,
                          onPaginate: (int? offset) async {
                            await couponController.getCouponList(offset!);
                          },
                          totalSize: couponController.couponModel?.totalSize,
                          offset: int.parse(couponController.couponModel!.offset.toString()),
                          itemView:  ListView.separated(shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                            itemCount: couponController.couponModel!.data!.length,
                            itemBuilder: (context, index){
                              return OfferCouponCardWidget(
                                fromCouponScree: true,
                                coupon: couponController.couponModel!.data![index],
                                index: index,
                              );
                            },
                            separatorBuilder: (context, index){
                              return const SizedBox(height: Dimensions.paddingSizeDefault);
                            },
                          ),
                        ) :
                        NoCouponWidget(
                          title: 'no_coupon_available'.tr,
                          description: 'sorry_there_is_no_coupon'.tr,
                        );
                    })
                  ]),
                ))
              ]),

              !widget.isCoupon ?
              Align(alignment: Alignment.topRight,
                child: Padding(padding: EdgeInsets.only(top: Get.height * 0.02),
                  child: InkWell(
                    onTap: ()=> Get.bottomSheet(
                      SizedBox(width: Get.width,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(height: 30),

                          Text('we_do_the_best_for_you'.tr,style: textSemiBold),

                          Divider(color: Theme.of(context).hintColor.withOpacity(0.15)),

                          Text(
                            'if_you_have_multiple_eligible_discounts_we_will_automatically_apply_the_discount_that_will_save_you_the_most_to_your_next_trip'.tr,
                            style: textRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 50)
                        ]),
                      ) ,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    child: Icon(Icons.info,color: Theme.of(context).primaryColor),
                  ),
                ),
              ) :
              const SizedBox()
            ]),
          ),
        ),
      ),
    );
  }
}
