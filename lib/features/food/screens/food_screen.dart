import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/food/screens/food_menu_screen.dart';
import 'package:ride_sharing_user_app/features/food/screens/food_orders_screen.dart';

/// Repas: liste des restaurants ouverts.
class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  ApiClient get _api => Get.find<ApiClient>();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await _api.getData('/api/customer/food/restaurants');
      if (r.statusCode == 200 && r.body is Map) _items = (r.body['restaurants'] as List?) ?? [];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium!.color!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repas'),
        actions: [TextButton(onPressed: () => Get.to(() => const FoodOrdersScreen()), child: const Text('Mes commandes'))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Aucun restaurant ouvert pour le moment.', textAlign: TextAlign.center, style: TextStyle(color: text))))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (c, i) {
                      final p = Map<String, dynamic>.from(_items[i] as Map);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Get.to(() => FoodMenuScreen(restaurant: p)),
                          child: Row(children: [
                            SizedBox(
                              width: 96,
                              height: 96,
                              child: p['logo'] != null
                                  ? Image.network('${p['logo']}', fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black12))
                                  : Container(color: Colors.black12, child: const Icon(Icons.restaurant, size: 36)),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${p['name']}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: text)),
                                  if ((p['cuisine'] ?? '').toString().isNotEmpty) Text('${p['cuisine']}', style: TextStyle(color: text.withOpacity(.7), fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('~${p['prep_minutes']} min · Livraison ${p['delivery_fee']} \$', style: TextStyle(color: text.withOpacity(.7), fontSize: 12.5)),
                                ]),
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
