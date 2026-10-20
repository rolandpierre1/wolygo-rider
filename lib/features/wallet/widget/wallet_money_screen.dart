import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/transaction_card_widget.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/wallet_money_amount_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/custom_title.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';


class WalletMoneyScreen extends StatefulWidget {
  const WalletMoneyScreen({super.key});
  @override
  State<WalletMoneyScreen> createState() => _WalletMoneyScreenState();
}

class _WalletMoneyScreenState extends State<WalletMoneyScreen> {

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<WalletController>(builder: (walletController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),

        const WalletMoneyAmountWidget(walletMoney: true),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: CustomTitle(title: 'wallet_history'.tr,color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)),
        ),

        const Padding(
          padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child:  Divider(thickness: .25,),
        ),

        walletController.transactionModel?.data != null ?
        (walletController.transactionModel!.data!.isNotEmpty) ?
        Expanded(child: SingleChildScrollView(
          controller: Get.find<WalletController>().scrollController,
          child: PaginatedListWidget(
            scrollController: Get.find<WalletController>().scrollController,
            totalSize: walletController.transactionModel!.totalSize,
            offset: (walletController.transactionModel?.offset != null) ? int.parse(walletController.transactionModel!.offset.toString()) : null,
            onPaginate: (int? offset) async {
              await walletController.getTransactionList(offset!);
            },
            itemView: ListView.builder(
              itemCount: walletController.transactionModel!.data!.length,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return TransactionCard(transaction: walletController.transactionModel!.data![index]);
              },
            ),
          ),
        )) :
        const Expanded(child: NoDataWidget(title: 'no_transaction_found')) :
        const Expanded(child: NotificationShimmer()),

      ]);
    });
  }
}

