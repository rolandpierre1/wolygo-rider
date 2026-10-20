import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/widget/coupon_widget.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<CouponController>().getCouponList(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BodyWidget(
      appBar: AppBarWidget(title: 'coupon'.tr, centerTitle: true),
      body: GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponModel != null ? (couponController.couponModel!.data != null && couponController.couponModel!.data!.isNotEmpty) ?
        SingleChildScrollView(
          controller: scrollController,
          child: PaginatedListWidget(
            scrollController: scrollController,
            totalSize: couponController.couponModel?.totalSize,
            offset: int.parse(couponController.couponModel!.offset.toString()),
            onPaginate: (int? offset) async {
              await couponController.getCouponList(offset!);
            },
            itemView: ListView.builder(
              itemCount: couponController.couponModel!.data!.length,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return CouponWidget(coupon: couponController.couponModel!.data![index]);
              },
            ),
          ),
        ) : const NoDataWidget(title: 'no_coupon_found',): const NotificationShimmer();
      }),
    ));
  }
}
