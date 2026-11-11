import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

/// Code du colis (à donner au chauffeur) + preuve de remise une fois le colis livré.
class ParcelCodeBox extends StatefulWidget {
  const ParcelCodeBox({super.key});

  @override
  State<ParcelCodeBox> createState() => _ParcelCodeBoxState();
}

class _ParcelCodeBoxState extends State<ParcelCodeBox> {
  Map<String, dynamic>? _d;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _load();
    _t = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final id = Get.find<RideController>().tripDetails?.id;
      if (id == null) return;
      final r = await Get.find<ApiClient>().getData('/api/customer/parcel-proof/$id');
      if (r.statusCode == 200 && r.body is Map && mounted) setState(() => _d = Map<String, dynamic>.from(r.body as Map));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final d = _d;
    if (d == null || '${d['code'] ?? ''}'.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Code de ton colis (le livreur le présente avec ton nom)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))),
          Text('${d['code']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.black)),
        ]),
        if (d['has_proof'] == true && d['mode'] == 'hand') const Padding(padding: EdgeInsets.only(top: 6), child: Text('Remis en main propre', style: TextStyle(color: Colors.black87))),
        if (d['has_proof'] == true && d['mode'] == 'dropped') ...[
          Padding(padding: const EdgeInsets.only(top: 6), child: Text('Déposé${(d['note'] ?? '').toString().isNotEmpty ? ' : ${d['note']}' : ''}', style: const TextStyle(color: Colors.black87))),
          if (d['photo'] != null)
            TextButton.icon(onPressed: () => launchUrl(Uri.parse('${d['photo']}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.photo_outlined, size: 18), label: const Text('Voir la photo de remise')),
        ],
      ]),
    );
  }
}
