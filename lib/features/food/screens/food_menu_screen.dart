import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/food/screens/food_checkout_screen.dart';

/// Menu d'un restaurant + panier.
class FoodMenuScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  const FoodMenuScreen({super.key, required this.restaurant});

  @override
  State<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  ApiClient get _api => Get.find<ApiClient>();
  List<dynamic> _sections = [];
  bool _loading = true;
  final Map<int, int> _qty = {};
  final Map<int, Map<String, dynamic>> _byId = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _api.getData('/api/customer/food/restaurants/${widget.restaurant['id']}');
      if (r.statusCode == 200 && r.body is Map) {
        _sections = (r.body['sections'] as List?) ?? [];
        for (final s in _sections) {
          for (final it in (s['items'] as List)) {
            final m = Map<String, dynamic>.from(it as Map);
            _byId[m['id'] as int] = m;
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  double get _subtotal => _qty.entries.fold(0.0, (a, e) => a + (_byId[e.key]!['price'] as num).toDouble() * e.value);
  int get _count => _qty.values.fold(0, (a, b) => a + b);

  void _add(int id, int d) {
    setState(() {
      final n = (_qty[id] ?? 0) + d;
      if (n <= 0) {
        _qty.remove(id);
      } else if (n <= 20) {
        _qty[id] = n;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium!.color!;
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.restaurant['name']}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              children: [
                if ((widget.restaurant['description'] ?? '').toString().isNotEmpty)
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('${widget.restaurant['description']}', style: TextStyle(color: text.withOpacity(.8)))),
                for (final s in _sections) ...[
                  Padding(padding: const EdgeInsets.only(top: 10, bottom: 6), child: Text('${s['name']}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: text))),
                  for (final raw in (s['items'] as List))
                    Builder(builder: (c) {
                      final it = Map<String, dynamic>.from(raw as Map);
                      final id = it['id'] as int;
                      final q = _qty[id] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(children: [
                            if (it['photo'] != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network('${it['photo']}', width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox(width: 72, height: 72))),
                              ),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${it['name']}', style: TextStyle(fontWeight: FontWeight.w700, color: text)),
                                if ((it['description'] ?? '').toString().isNotEmpty) Text('${it['description']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: text.withOpacity(.7))),
                                const SizedBox(height: 4),
                                Text('${(it['price'] as num).toStringAsFixed(2)} \$', style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
                              ]),
                            ),
                            if (q == 0)
                              IconButton(onPressed: () => _add(id, 1), icon: Icon(Icons.add_circle, color: primary, size: 32))
                            else
                              Row(children: [
                                IconButton(onPressed: () => _add(id, -1), icon: const Icon(Icons.remove_circle_outline)),
                                Text('$q', style: TextStyle(fontWeight: FontWeight.w700, color: text)),
                                IconButton(onPressed: () => _add(id, 1), icon: Icon(Icons.add_circle, color: primary)),
                              ]),
                          ]),
                        ),
                      );
                    }),
                ],
                if (_sections.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text('Aucun plat disponible.', textAlign: TextAlign.center, style: TextStyle(color: text))),
              ],
            ),
      bottomNavigationBar: _count == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => Get.to(() => FoodCheckoutScreen(
                          restaurant: widget.restaurant,
                          cart: _qty.entries.map((e) => {'id': e.key, 'qty': e.value, 'name': _byId[e.key]!['name'], 'price': _byId[e.key]!['price']}).toList(),
                        )),
                    child: Text('Voir le panier ($_count) · ${_subtotal.toStringAsFixed(2)} \$'),
                  ),
                ),
              ),
            ),
    );
  }
}
