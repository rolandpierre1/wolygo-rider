import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Écran « Déménagement » : choix du forfait, articles en plus, adresses, date, prix, confirmation.
class MovingScreen extends StatefulWidget {
  const MovingScreen({super.key});

  @override
  State<MovingScreen> createState() => _MovingScreenState();
}

class _Place {
  String address;
  double lat;
  double lng;
  _Place(this.address, this.lat, this.lng);
}

class _MovingScreenState extends State<MovingScreen> {
  final ApiClient _api = Get.find<ApiClient>();

  bool _loading = true;
  bool _sending = false;
  List<dynamic> _packages = [];
  List<dynamic> _items = [];
  int? _packageId;
  final Map<int, int> _qty = {};

  final TextEditingController _fromCtrl = TextEditingController();
  final TextEditingController _toCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  _Place? _from;
  _Place? _to;
  List<dynamic> _suggestions = [];
  String _suggestFor = '';
  Timer? _debounce;

  bool _roundTrip = false;
  DateTime? _date;
  TimeOfDay? _time;

  Map<String, dynamic>? _quote;
  bool _quoting = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final res = await _api.getData('/api/customer/moving/catalog');
    if (!mounted) return;
    if (res.statusCode == 200 && res.body is Map) {
      setState(() {
        _packages = (res.body['packages'] as List?) ?? [];
        _items = (res.body['items'] as List?) ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      showCustomSnackBar('Impossible de charger les forfaits. Réessaie.');
    }
  }

  String _money(num v) => '${v.toStringAsFixed(2)} \$';

  Map<String, dynamic>? _selectedPackage() {
    for (final p in _packages) {
      if (p['id'] == _packageId) return Map<String, dynamic>.from(p as Map);
    }
    return null;
  }

  Map<String, dynamic> _quoteBody() => {
        'package_id': _packageId,
        'items': _qty.entries.where((e) => e.value > 0).map((e) => {'id': e.key, 'qty': e.value}).toList(),
        'pickup_lat': _from!.lat,
        'pickup_lng': _from!.lng,
        'dropoff_lat': _to!.lat,
        'dropoff_lng': _to!.lng,
        'round_trip': _roundTrip,
      };

  Future<void> _refreshQuote() async {
    if (_packageId == null || _from == null || _to == null) {
      setState(() => _quote = null);
      return;
    }
    setState(() => _quoting = true);
    final res = await _api.postData('/api/customer/moving/quote', _quoteBody());
    if (!mounted) return;
    setState(() {
      _quoting = false;
      _quote = (res.statusCode == 200 && res.body is Map) ? Map<String, dynamic>.from(res.body as Map) : null;
    });
  }

  void _onTyping(String which, String text) {
    if (which == 'from') {
      _from = null;
    } else {
      _to = null;
    }
    _quote = null;
    _debounce?.cancel();
    if (text.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final res = await _api.getData('${AppConstants.searchLocationUri}?search_text=${Uri.encodeQueryComponent(text.replaceAll('#', ''))}');
      if (!mounted) return;
      if (res.statusCode == 200 && res.body is Map && res.body['data'] is Map) {
        setState(() {
          _suggestions = (res.body['data']['predictions'] as List?) ?? [];
          _suggestFor = which;
        });
      }
    });
    setState(() {});
  }

  Future<void> _pick(String which, dynamic prediction) async {
    final String desc = (prediction['description'] ?? '').toString();
    final String placeId = (prediction['place_id'] ?? '').toString();
    setState(() => _suggestions = []);
    final res = await _api.getData('${AppConstants.placeApiDetails}?placeid=$placeId');
    if (!mounted) return;
    try {
      final loc = res.body['data']['result']['geometry']['location'];
      final place = _Place(desc, (loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
      setState(() {
        if (which == 'from') {
          _from = place;
          _fromCtrl.text = desc;
        } else {
          _to = place;
          _toCtrl.text = desc;
        }
      });
      FocusScope.of(context).unfocus();
      _refreshQuote();
    } catch (_) {
      showCustomSnackBar('Adresse introuvable. Essaie une autre adresse.');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0));
    if (t != null) setState(() => _time = t);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _submit() async {
    if (_packageId == null) {
      showCustomSnackBar('Choisis un forfait.');
      return;
    }
    if (_from == null || _to == null) {
      showCustomSnackBar('Choisis les adresses de départ et d\'arrivée dans la liste.');
      return;
    }
    if (_date == null) {
      showCustomSnackBar('Choisis la date du déménagement.');
      return;
    }
    setState(() => _sending = true);
    final body = _quoteBody()
      ..addAll({
        'pickup_address': _from!.address,
        'dropoff_address': _to!.address,
        'move_date': '${_date!.year}-${_two(_date!.month)}-${_two(_date!.day)}',
        'move_time': _time == null ? null : '${_two(_time!.hour)}:${_two(_time!.minute)}',
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      });
    final res = await _api.postData('/api/customer/moving/order', body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (res.statusCode == 200) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Demande envoyée ✅'),
          content: const Text('Ta demande de déménagement est enregistrée. Un déménageur WolyGo sera assigné bientôt.'),
          actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } else if (res.statusCode == 401) {
      showCustomSnackBar('Connecte-toi pour envoyer ta demande.');
    } else {
      showCustomSnackBar('Envoi impossible. Vérifie les informations et réessaie.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déménagement'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                children: [
                  _title('1. Choisis ton forfait'),
                  for (final p in _packages) _packageCard(p),
                  const SizedBox(height: 16),
                  _title('2. Articles en plus (facultatif)'),
                  _itemsSection(),
                  const SizedBox(height: 16),
                  _title('3. Adresses'),
                  _addressField('from', _fromCtrl, 'Adresse de départ', Icons.my_location),
                  if (_suggestions.isNotEmpty && _suggestFor == 'from') _suggestionList('from'),
                  const SizedBox(height: 10),
                  _addressField('to', _toCtrl, 'Adresse d\'arrivée', Icons.place_outlined),
                  if (_suggestions.isNotEmpty && _suggestFor == 'to') _suggestionList('to'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aller-retour'),
                    value: _roundTrip,
                    onChanged: (v) {
                      setState(() => _roundTrip = v);
                      _refreshQuote();
                    },
                  ),
                  const SizedBox(height: 8),
                  _title('4. Date et heure'),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(_date == null ? 'Date' : '${_date!.year}-${_two(_date!.month)}-${_two(_date!.day)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(_time == null ? 'Heure' : '${_two(_time!.hour)}:${_two(_time!.minute)}'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes (étage, ascenseur, accès…)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  _summary(primary),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: _sending ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirmer la demande'),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(t, style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      );

  Widget _thumb(String? url, double size, IconData fallback) {
    if (url == null || url.isEmpty) {
      return Container(width: size, height: size, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)), child: Icon(fallback, color: Colors.black38));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(url, width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(width: size, height: size, color: Colors.black12, child: Icon(fallback, color: Colors.black38))),
    );
  }

  Widget _packageCard(dynamic p) {
    final bool selected = p['id'] == _packageId;
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () {
        setState(() => _packageId = p['id'] as int);
        _refreshQuote();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : Colors.black12, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          _thumb(p['image'] as String?, 64, Icons.local_shipping_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['name']}', style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: 2),
              Text('${_money(p['base_price'] as num)} + ${_money(p['per_km_price'] as num)}/km', style: textRegular.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
          if (selected) Icon(Icons.check_circle, color: primary),
        ]),
      ),
    );
  }

  Widget _itemsSection() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(_qty.values.fold<int>(0, (a, b) => a + b) == 0 ? 'Ajouter des articles' : '${_qty.values.fold<int>(0, (a, b) => a + b)} article(s) ajouté(s)'),
      children: [
        for (final it in _items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _thumb(it['image'] as String?, 44, Icons.chair_alt_outlined),
            title: Text('${it['name']}'),
            subtitle: Text(_money(it['price'] as num)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: (_qty[it['id'] as int] ?? 0) > 0
                    ? () {
                        setState(() => _qty[it['id'] as int] = (_qty[it['id'] as int] ?? 0) - 1);
                        _refreshQuote();
                      }
                    : null,
              ),
              Text('${_qty[it['id'] as int] ?? 0}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() => _qty[it['id'] as int] = (_qty[it['id'] as int] ?? 0) + 1);
                  _refreshQuote();
                },
              ),
            ]),
          ),
      ],
    );
  }

  Widget _addressField(String which, TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
      onChanged: (t) => _onTyping(which, t),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: (which == 'from' ? _from : _to) != null ? const Icon(Icons.check_circle, color: Colors.green) : null,
      ),
    );
  }

  Widget _suggestionList(String which) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(children: [
        for (final s in _suggestions.take(5))
          ListTile(
            dense: true,
            leading: const Icon(Icons.place_outlined, size: 20),
            title: Text('${s['description']}', maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => _pick(which, s),
          ),
      ]),
    );
  }

  Widget _summary(Color primary) {
    final p = _selectedPackage();
    if (p == null) {
      return const SizedBox();
    }
    if (_quote == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
        child: Text(_quoting ? 'Calcul du prix…' : 'Choisis les deux adresses pour voir le prix.'),
      );
    }
    final q = _quote!;
    Widget row(String a, String b, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(a, style: bold ? textSemiBold : textRegular),
            Text(b, style: bold ? textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge) : textRegular),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        row('Forfait ${p['name']}', _money(q['base_price'] as num)),
        row('Distance (${q['distance_km']} km)', _money(q['distance_price'] as num)),
        if ((q['items_total'] as num) > 0) row('Articles', _money(q['items_total'] as num)),
        const Divider(),
        row('Total', _money(q['total'] as num), bold: true),
      ]),
    );
  }
}
