import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Grille de services de l'accueil (Transport, Repas, Colis, Déménagement, Location, Magasin).
/// Transport et Colis ouvrent les écrans existants; les autres affichent « Bientôt » pour l'instant.
class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Service>[
      _Service('service_transport'.tr, Icons.directions_car_filled_outlined, () => Get.to(() => const SetDestinationScreen())),
      _Service('service_food'.tr, Icons.restaurant_outlined, null),
      _Service('parcel'.tr, Icons.inventory_2_outlined, () => Get.to(() => const ParcelScreen())),
      _Service('service_moving'.tr, Icons.local_shipping_outlined, null),
      _Service('service_rental'.tr, Icons.key_outlined, null),
      _Service('service_store'.tr, Icons.storefront_outlined, null),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.1,
      children: [for (final s in items) _tile(context, s)],
    );
  }

  Widget _tile(BuildContext context, _Service s) {
    final soon = s.onTap == null;
    final color = Theme.of(context).textTheme.bodyMedium!.color!;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: s.onTap ?? () => Get.snackbar(s.label, 'service_coming_soon'.tr, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.2)),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(soon ? .08 : .15), shape: BoxShape.circle),
            child: Icon(s.icon, size: 19, color: Theme.of(context).primaryColor.withOpacity(soon ? .5 : 1)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: color.withOpacity(soon ? .6 : .9))),
            if (soon) Text('soon'.tr, style: textRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor)),
          ])),
        ]),
      ),
    );
  }
}

class _Service {
  final String label; final IconData icon; final VoidCallback? onTap;
  _Service(this.label, this.icon, this.onTap);
}
