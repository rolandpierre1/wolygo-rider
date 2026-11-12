import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

/// Page sécurisée Stripe pour payer la commande.
class ShopPayScreen extends StatefulWidget {
  final String url;
  const ShopPayScreen({super.key, required this.url});

  @override
  State<ShopPayScreen> createState() => _ShopPayScreenState();
}

class _ShopPayScreenState extends State<ShopPayScreen> {
  bool _done = false;

  void _check(String url) {
    if (_done) return;
    if (url.contains('/customer/shop/pay/return')) {
      _done = true;
      Get.back(result: true);
    } else if (url.contains('/customer/shop/pay/cancelled')) {
      _done = true;
      Get.back(result: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement par carte'),
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back(result: false)),
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
          onLoadStart: (c, url) => _check(url.toString()),
          onLoadStop: (c, url) => _check(url.toString()),
          shouldOverrideUrlLoading: (c, action) async {
            _check(action.request.url.toString());
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
