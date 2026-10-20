import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_category_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class ParcelDetailInputView extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const ParcelDetailInputView({super.key, required this.expandableKey});

  @override
  State<ParcelDetailInputView> createState() => _ParcelDetailInputViewState();
}
class _ParcelDetailInputViewState extends State<ParcelDetailInputView> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: GetBuilder<ParcelController>(builder: (parcelController){
        return GetBuilder<RideController>(
          builder: (rideController) {
            return Stack(clipBehavior: Clip.none, children: [

                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  const ParcelCategoryView(isDetails: true),

                  TextFieldTitle(title: 'category'.tr, textOpacity: 0.8),
                  CustomTextField(prefixIcon: Images.editProfilePhone,
                    borderRadius: 50, showBorder: false,
                    hintText: 'category'.tr, isEnabled: false,
                    fillColor: Theme.of(context).primaryColor.withOpacity(0.04),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    controller: parcelController.parcelTypeController,
                    prefix: false),

                  // TextFieldTitle(title: 'parcel_weight'.tr, textOpacity: 0.8),
                  // CustomTextField(
                  //   prefixIcon: Images.editProfilePhone,
                  //   borderRadius: 50,
                  //   showBorder: false,
                  //   hintText: 'parcel_weight_hint'.tr,
                  //   fillColor: Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withOpacity(0.04),
                  //   controller: parcelController.parcelWeightController,
                  //   focusNode: parcelController.parcelWeightNode,
                  //   inputType: TextInputType.number,
                  //   inputAction: TextInputAction.done,
                  //   isAmount: true,
                  //   prefix: false,
                  //   onTap: () => parcelController.focusOnBottomSheet(widget.expandableKey)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  rideController.isEstimate ?  Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0,)) : ButtonWidget(
                    buttonText: "save_details".tr,
                    onPressed: () {

                      // if(parcelController.parcelWeightController.text.trim().isEmpty) {
                      //   FocusScope.of(context).requestFocus(parcelController.parcelWeightNode);
                      //   parcelController.focusOnBottomSheet(widget.expandableKey);
                      //   showCustomSnackBar('parcel_weight_is_required'.tr);
                      // }else{
                      //   rideController.getEstimatedFare(true).then((value) {
                      //     if(value.statusCode == 200) {
                      //       parcelController.updateParcelState(ParcelDeliveryState.parcelInfoDetails);
                      //       parcelController.updateParcelDetailsStatus();
                      //     }
                      //   });
                      // }

                      rideController.getEstimatedFare(true).then((value) {
                        if(value.statusCode == 200) {
                          parcelController.updateParcelState(ParcelDeliveryState.parcelInfoDetails);
                          parcelController.updateParcelDetailsStatus();
                        }
                      });

                    },
                  ),

                ]),

                 Positioned(right: 0, child: Align(
                   child: InkWell(onTap: () => parcelController.updateParcelState(ParcelDeliveryState.initial),
                         child: Container(decoration: BoxDecoration(color: Get.isDarkMode? Theme.of(context).primaryColorDark : Theme.of(context).cardColor,
                             borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),

                           child: Padding(padding: const EdgeInsets.all(8.0),
                             child: Icon(Icons.keyboard_backspace, color: Theme.of(context).hintColor)))),
                 )),
              ],
            );
          }
        );
      }),
    );
  }
}
