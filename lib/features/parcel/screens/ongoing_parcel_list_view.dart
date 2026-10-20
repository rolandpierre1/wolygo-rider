import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_item.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class OngoingParcelListView extends StatefulWidget {
  final String title;
  const OngoingParcelListView({super.key, required this.title});

  @override
  State<OngoingParcelListView> createState() => _OngoingParcelListViewState();
}

class _OngoingParcelListViewState extends State<OngoingParcelListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: widget.title.tr),
        body: GetBuilder<ParcelController>(builder: (parcelController){
          return parcelController.parcelListModel == null || parcelController.parcelListModel!.data!.isEmpty ?
          const NoDataWidget(title: 'no_trip_found') :
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: parcelController.parcelListModel!.data!.length,
              itemBuilder: (context, index){
                return ParcelItem(rideRequest: parcelController.parcelListModel!.data![index],index: index);
              }
          );
        }),
      ),
    );
  }
}
