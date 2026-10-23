import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

/// Page sécurisée Stripe où le client entre sa carte. Aucun débit: l'argent est seulement réservé.
class CardHoldScreen extends StatefulWidget {
  final String url;
  const CardHoldScreen({super.key, required this.url});

  @override
  State<CardHoldScreen> createState() => _CardHoldScreenState();
}

class _CardHoldScreenState extends State<CardHoldScreen> {
  bool _done = false;

  void _check(String url) {
    if(_done) return;
    if(url.contains('/card-hold/return')) {
      _done = true;
      Get.back(result: true);
    } else if(url.contains('/card-hold/cancelled')) {
      _done = true;
      Get.back(result: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('card_payment'.tr),
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back(result: false)),
      ),
      body: SafeArea(child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
        onLoadStart: (c, url) => _check(url.toString()),
        onLoadStop: (c, url) => _check(url.toString()),
        shouldOverrideUrlLoading: (c, action) async {
          _check(action.request.url.toString());
          return NavigationActionPolicy.ALLOW;
        },
      )),
    );
  }
}
