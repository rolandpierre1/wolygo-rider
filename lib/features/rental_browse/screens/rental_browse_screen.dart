import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/rental_browse/screens/rental_detail_screen.dart';
import 'package:ride_sharing_user_app/features/rental_browse/screens/my_rentals_screen.dart';

/// Location de véhicules (côté client): on voit les véhicules proposés.
/// Touche un véhicule pour le louer.
class RentalBrowseScreen extends StatefulWidget {
  const RentalBrowseScreen({super.key});

  @override
  State<RentalBrowseScreen> createState() => _RentalBrowseScreenState();
}

class _RentalBrowseScreenState extends State<RentalBrowseScreen> {
  ApiClient get _api => Get.find<ApiClient>();
  List<dynamic> _items = [];
  bool _loading = true;
  String _cat = '';

  static const _cats = {'': 'Tous', 'car': 'Voiture', 'suv': 'SUV', 'van': 'Van', 'minibus': 'Minibus', 'truck': 'Camion'};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await _api.getData('/api/customer/rental/vehicles', query: _cat.isEmpty ? null : {'category': _cat});
      if (r.statusCode == 200 && r.body is Map) _items = (r.body['vehicles'] as List?) ?? [];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium!.color!;
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Location de véhicules'), actions: [
        TextButton(onPressed: () => Get.to(() => const MyRentalsScreen()), child: const Text('Mes locations')),
      ]),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: primary.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Choisis un véhicule pour le louer.', style: TextStyle(color: text, fontSize: 13)),
          ]),
        ),
        SizedBox(
          height: 54,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final e in _cats.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _cat == e.key,
                    onSelected: (_) {
                      _cat = e.key;
                      _load();
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? Center(child: Text('Aucun véhicule pour le moment.', style: TextStyle(color: text)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        itemBuilder: (c, i) {
                          final v = Map<String, dynamic>.from(_items[i] as Map);
                          final photos = (v['photos'] as List?) ?? [];
                          return InkWell(
                            onTap: () => Get.to(() => RentalDetailScreen(vehicle: v)),
                            child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            clipBehavior: Clip.antiAlias,
                            child: Row(children: [
                              SizedBox(
                                width: 120,
                                height: 100,
                                child: photos.isNotEmpty
                                    ? Image.network('${photos.first}', fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black12))
                                    : Container(color: Colors.black12, child: const Icon(Icons.directions_car, size: 40)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('${v['brand']} ${v['model']} ${v['year'] ?? ''}', style: TextStyle(fontWeight: FontWeight.w700, color: text)),
                                    Text('${v['owner'] ?? ''}${(v['city'] ?? '').toString().isNotEmpty ? ' · ${v['city']}' : ''}', style: TextStyle(fontSize: 12.5, color: text.withOpacity(.7))),
                                    const SizedBox(height: 6),
                                    Text('${v['price_day']} \$/jour · ${v['price_week']} \$/sem.', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                                    Text('Dépôt : ${v['deposit']} \$', style: TextStyle(fontSize: 12, color: text)),
                                  ]),
                                ),
                              ),
                            ]),
                          ));
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}
