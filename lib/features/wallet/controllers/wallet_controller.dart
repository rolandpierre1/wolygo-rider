import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/loyalty_point_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/transaction_model.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/services/wallet_service.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/payment/screens/card_hold_screen.dart';


class WalletController extends GetxController implements GetxService{
  final WalletService walletService;

  WalletController({required this.walletService});

  TextEditingController inputController = TextEditingController();
  FocusNode inputNode = FocusNode();
  ScrollController scrollController = ScrollController();

  bool isLoading = false;

  List<String> walletType = ['wallet_money','loyalty_point'];

  TransactionModel? transactionModel;
  Future<Response> getTransactionList(int offset) async {
    isLoading = true;
    update();
    Response? response = await walletService.getTransactionList(offset);
    if (response!.statusCode == 200) {
      isLoading = false;
      if(offset == 1){
        transactionModel = TransactionModel.fromJson(response.body);
      }else{
        transactionModel!.data!.addAll(TransactionModel.fromJson(response.body).data!);
        transactionModel!.offset = TransactionModel.fromJson(response.body).offset;
        transactionModel!.totalSize = TransactionModel.fromJson(response.body).totalSize;
      }

    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }


  LoyaltyPointModel? loyaltyPointModel;
  Future<Response> getLoyaltyPointList(int offset) async {
    isLoading = true;
    update();
    Response? response = await walletService.getLoyaltyPointList(offset);
    if (response!.statusCode == 200) {
      isLoading = false;
      if(offset == 1){
        loyaltyPointModel = LoyaltyPointModel.fromJson(response.body);
      }else{
        loyaltyPointModel!.data!.addAll(LoyaltyPointModel.fromJson(response.body).data!);
        loyaltyPointModel!.offset = LoyaltyPointModel.fromJson(response.body).offset;
        loyaltyPointModel!.totalSize = LoyaltyPointModel.fromJson(response.body).totalSize;
      }
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }



  Future<Response> convertPoint(String point) async {
    isLoading = true;
    update();
    Response? response = await walletService.convertPoint(point);
    if (response!.statusCode == 200) {
     Get.find<ProfileController>().getProfileInfo();
     getTransactionList(1);
      isLoading = false;
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  bool topupLoading = false;

  /// Recharge le portefeuille par carte (page sécurisée Stripe), puis rafraîchit le solde.
  Future<void> topUp(double amount) async {
    if(amount < 5 || amount > 500) {
      showCustomSnackBar('topup_amount_range'.tr);
      return;
    }
    topupLoading = true;
    update();
    try {
      Response response = await walletService.createTopup(amount);
      if(response.statusCode != 200 || response.body['content'] == null) {
        ApiChecker.checkApi(response);
        return;
      }
      final String id = response.body['content']['topup_id'];
      final String url = response.body['content']['url'];
      await Get.to(() => CardHoldScreen(url: url));
      bool paid = false;
      for(int i = 0; i < 8; i++) {
        Response st = await walletService.getTopup(id);
        final String status = st.statusCode == 200 ? '${st.body['content']?['status']}' : '';
        if(status == 'paid') { paid = true; break; }
        if(status == 'expired') { break; }
        await Future.delayed(const Duration(seconds: 1));
      }
      if(paid) {
        inputController.clear();
        showCustomSnackBar('topup_success'.tr, isError: false);
      } else {
        showCustomSnackBar('topup_not_completed'.tr);
      }
      Get.find<ProfileController>().getProfileInfo();
      getTransactionList(1);
    } finally {
      topupLoading = false;
      update();
    }
  }

  int currentTabIndex = 0;

  void updateCurrentTabIndex(int index){
    currentTabIndex = index;
    if(index == 0){
      getTransactionList(1);
    }else{
      getLoyaltyPointList(1);
    }
    update();
  }

  Future<void> transferWalletMoney(String balance) async{
    isLoading = true;
    update();
    Response response = await walletService.transferWalletMoney(balance);
    if(response.statusCode == 200){
      isLoading = false;
      getTransactionList(1);
      Get.find<ProfileController>().getProfileInfo();
      Get.back();
      showCustomSnackBar('transfer_successfully'.tr,isError: false);
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

}