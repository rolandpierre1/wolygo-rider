import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/food/screens/food_orders_screen.dart';
import 'package:ride_sharing_user_app/features/food/screens/food_pay_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

/// Adresse de livraison, résumé et paiement par carte.
class FoodCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final List<Map<String, dynamic>> cart;
  const FoodCheckoutScreen({super.key, required this.restaurant, required this.cart});

  @override
  State<FoodCheckoutScreen> createState() => _FoodCheckoutScreenState();
}

class _FoodCheckoutScreenState extends State<FoodCheckoutScreen> {
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  ApiClient get _api => Get.find<ApiClient>();
  double get _subtotal => widget.cart.fold(0.0, (a, e) => a + (e['price'] as num).toDouble() * (e['qty'] as int));
  double get _fee => ((widget.restaurant['delivery_fee'] ?? 0) as num).toDouble();

  Future<void> _pay() async {
    if (_address.text.trim().length < 5) return showCustomSnackBar('Entre ton adresse de livraison.');
    if (_phone.text.trim().length < 7) return showCustomSnackBar('Entre ton numéro de téléphone.');
    setState(() => _busy = true);
    final res = await _api.postData('/api/customer/food/checkout', {
      'partner_id': widget.restaurant['id'],
      'items': widget.cart.map((e) => {'id': e['id'], 'qty': e['qty']}).toList(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'note': _note.text.trim(),
    });
    if (!mounted) return;
    if (res.statusCode != 200 || res.body is! Map || res.body['checkout_url'] == null) {
      setState(() => _busy = false);
      String msg = 'Commande impossible. Réessaie.';
      try {
        if (res.body is Map && res.body['message'] != null) msg = '${res.body['message']}';
      } catch (_) {}
      return showCustomSnackBar(msg);
    }
    final token = '${res.body['token']}';
    await Get.to(() => FoodPayScreen(url: '${res.body['checkout_url']}'));
    bool paid = false;
    for (int i = 0; i < 3 && !paid; i++) {
      final v = await _api.postData('/api/customer/food/checkout/verify', {'token': token});
      paid = v.statusCode == 200;
      if (!paid) await Future.delayed(const Duration(seconds: 2));
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (paid) {
      Get.offAll(() => const FoodOrdersScreen(), predicate: (r) => r.isFirst);
    } else {
      showCustomSnackBar('Paiement non confirmé. Aucune commande créée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium!.color!;
    final primary = Theme.of(context).primaryColor;
    InputDecoration dec(String l) => InputDecoration(labelText: l, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
    final style = TextStyle(color: text);
    return Scaffold(
      appBar: AppBar(title: const Text('Ma commande')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${widget.restaurant['name']}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: text)),
        const SizedBox(height: 8),
        for (final e in widget.cart)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Expanded(child: Text('${e['qty']} × ${e['name']}', style: style)),
              Text('${((e['price'] as num) * (e['qty'] as int)).toStringAsFixed(2)} \$', style: style),
            ]),
          ),
        const Divider(height: 24),
        Row(children: [Expanded(child: Text('Plats', style: style)), Text('${_subtotal.toStringAsFixed(2)} \$', style: style)]),
        Row(children: [Expanded(child: Text('Livraison', style: style)), Text('${_fee.toStringAsFixed(2)} \$', style: style)]),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: text))),
          Text('${(_subtotal + _fee).toStringAsFixed(2)} \$', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: primary)),
        ]),
        const SizedBox(height: 18),
        TextField(controller: _address, style: style, cursorColor: primary, decoration: dec('Adresse de livraison')),
        const SizedBox(height: 12),
        TextField(controller: _phone, style: style, cursorColor: primary, keyboardType: TextInputType.phone, decoration: dec('Téléphone')),
        const SizedBox(height: 12),
        TextField(controller: _note, style: style, cursorColor: primary, maxLines: 2, decoration: dec('Note pour le restaurant ou le chauffeur (facultatif)')),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _pay,
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: _busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Payer et commander'),
          ),
        ),
      ]),
    );
  }
}
