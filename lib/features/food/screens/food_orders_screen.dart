import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

/// Mes commandes Repas: suivi (mise à jour automatique), annulation avant acceptation.
class FoodOrdersScreen extends StatefulWidget {
  const FoodOrdersScreen({super.key});

  @override
  State<FoodOrdersScreen> createState() => _FoodOrdersScreenState();
}

class _FoodOrdersScreenState extends State<FoodOrdersScreen> {
  ApiClient get _api => Get.find<ApiClient>();
  List<dynamic> _items = [];
  bool _loading = true;
  Timer? _t;

  static const _status = {
    'placed': 'Envoyée au restaurant',
    'accepted': 'En préparation',
    'ready': 'Prête — le chauffeur arrive',
    'picked_up': 'En route vers toi',
    'delivered': 'Livrée',
    'rejected': 'Refusée par le restaurant (remboursée)',
    'cancelled': 'Annulée (remboursée)',
  };

  @override
  void initState() {
    super.initState();
    _load();
    _t = Timer.periodic(const Duration(seconds: 15), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final r = await _api.getData('/api/customer/food/orders');
      if (r.statusCode == 200 && r.body is Map) _items = (r.body['orders'] as List?) ?? [];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _cancel(Map o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text('Tu seras remboursé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Oui, annuler')),
        ],
      ),
    );
    if (ok != true) return;
    final r = await _api.postData('/api/customer/food/orders/${o['id']}/cancel', {});
    String msg = r.statusCode == 200 ? 'Commande annulée et remboursée.' : 'Annulation impossible.';
    try {
      if (r.statusCode != 200 && r.body is Map && r.body['message'] != null) msg = '${r.body['message']}';
    } catch (_) {}
    showCustomSnackBar(msg);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium!.color!;
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes Repas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text('Aucune commande.', style: TextStyle(color: text)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (c, i) {
                      final o = Map<String, dynamic>.from(_items[i] as Map);
                      final st = '${o['status']}';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${o['restaurant']}  ·  #${o['id']}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: text)),
                            const SizedBox(height: 4),
                            Text(_status[st] ?? st, style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            for (final it in (o['items'] as List)) Text('${it['qty']} × ${it['name']}', style: TextStyle(color: text)),
                            const SizedBox(height: 4),
                            Text('Total : ${(o['total'] as num).toStringAsFixed(2)} \$', style: TextStyle(fontWeight: FontWeight.w700, color: text)),
                            if (o['driver'] != null) Text('Chauffeur : ${o['driver']}', style: TextStyle(color: text)),
                            if (o['driver_phone'] != null && (st == 'picked_up' || st == 'ready' || st == 'accepted'))
                              TextButton.icon(onPressed: () => launchUrl(Uri.parse('tel:${o['driver_phone']}')), icon: const Icon(Icons.phone, size: 18), label: Text('${o['driver_phone']}')),
                            if (st == 'placed') Padding(padding: const EdgeInsets.only(top: 6), child: OutlinedButton(onPressed: () => _cancel(o), child: const Text('Annuler et me faire rembourser'))),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
