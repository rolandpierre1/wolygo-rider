import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Carte « Recharger mon portefeuille » : montant + bouton Ajouter (paiement sécurisé Stripe).
class WalletTopupWidget extends StatelessWidget {
  const WalletTopupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      final primary = Theme.of(context).primaryColor;
      return Container(
        margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          border: Border.all(color: primary.withOpacity(0.4), width: .75),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('topup_title'.tr, style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: primary)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(child: TextField(
              controller: walletController.inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'topup_amount'.tr,
                suffixText: '\$',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
              ),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            walletController.topupLoading ?
            SizedBox(width: 48, child: SpinKitCircle(color: primary, size: 32)) :
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 14),
              ),
              onPressed: () {
                final double? amount = double.tryParse(walletController.inputController.text.replaceAll(',', '.'));
                if(amount == null) {
                  walletController.topUp(0);
                } else {
                  walletController.topUp(amount);
                }
              },
              icon: const Icon(Icons.add),
              label: Text('topup_add'.tr),
            ),
          ]),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text('topup_hint'.tr, style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Wrap(spacing: Dimensions.paddingSizeSmall, children: [10, 25, 50, 100].map((v) => ActionChip(
            label: Text('\$$v'),
            onPressed: walletController.topupLoading ? null : () {
              walletController.inputController.text = '$v';
            },
          )).toList()),
        ]),
      );
    });
  }
}
