import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/moving/screens/moving_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Grille de services de l'accueil (Transport, Repas, Colis, Déménagement, Location, Magasin).
/// L'admin active chaque service (On/Off). Un service éteint affiche « Bientôt ».
class ServicesGridWidget extends StatefulWidget {
  const ServicesGridWidget({super.key});

  @override
  State<ServicesGridWidget> createState() => _ServicesGridWidgetState();
}

class _ServicesGridWidgetState extends State<ServicesGridWidget> {
  // Valeurs par défaut si le serveur ne répond pas: seuls Transport et Colis sont actifs.
  Map<String, bool> _enabled = {'transport': true, 'parcel': true};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Get.find<ApiClient>().getData('/api/customer/services');
      if (res.statusCode == 200 && res.body is Map && res.body['services'] is List) {
        final Map<String, bool> m = {};
        for (final s in (res.body['services'] as List)) {
          if (s is Map && s['key'] != null) {
            m[s['key'].toString()] = s['enabled'] == true;
          }
        }
        if (m.isNotEmpty && mounted) setState(() => _enabled = m);
      }
    } catch (_) {}
  }

  void _info(String title, String msg) {
    Get.dialog(AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
    ));
  }

  void _rental() {
    Get.dialog(AlertDialog(
      title: const Text('Location de véhicules'),
      content: const Text('Les chauffeurs WolyGo louent des véhicules directement dans l\'app chauffeur. Vous avez un véhicule à louer (particulier, concessionnaire, bureau de location)? Devenez partenaire.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
        TextButton(
          onPressed: () {
            Get.back();
            launchUrl(Uri.parse('https://wolygo.com/location/inscription'), mode: LaunchMode.externalApplication);
          },
          child: const Text('Devenir partenaire'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final items = <_Service>[
      _Service('service_transport'.tr, Icons.directions_car_filled_outlined, _enabled['transport'] ?? false, () => Get.to(() => const SetDestinationScreen())),
      _Service('service_food'.tr, Icons.restaurant_outlined, _enabled['food'] ?? false, () => _info('service_food'.tr, 'Le service Repas ouvre bientôt dans votre ville.')),
      _Service('parcel'.tr, Icons.inventory_2_outlined, _enabled['parcel'] ?? false, () => Get.to(() => const ParcelScreen())),
      _Service('service_moving'.tr, Icons.local_shipping_outlined, _enabled['moving'] ?? false, () => Get.to(() => const MovingScreen())),
      _Service('service_rental'.tr, Icons.key_outlined, _enabled['rental'] ?? false, () => _rental()),
      _Service('service_store'.tr, Icons.storefront_outlined, _enabled['store'] ?? false, () => _info('service_store'.tr, 'Le service Magasin ouvre bientôt dans votre ville.')),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.1,
      children: [for (final s in items) _tile(context, s)],
    );
  }

  Widget _tile(BuildContext context, _Service s) {
    final soon = !s.enabled;
    final color = Theme.of(context).textTheme.bodyMedium!.color!;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: (s.enabled ? s.onTap : null) ?? () => Get.snackbar(s.label, 'service_coming_soon'.tr, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12)),
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
  final String label; final IconData icon; final bool enabled; final VoidCallback? onTap;
  _Service(this.label, this.icon, this.enabled, this.onTap);
}
