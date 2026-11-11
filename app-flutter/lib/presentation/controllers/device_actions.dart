import 'package:url_launcher/url_launcher.dart';

Future<void> callShop() async {
  if (!await launchUrl(Uri(scheme: 'tel', path: '+959771234567'))) {
    throw StateError('Calling is unavailable on this device');
  }
}

Future<void> directions() async {
  if (!await launchUrl(
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '24 Inya Road, Bahan, Yangon',
    }),
    mode: LaunchMode.externalApplication,
  )) {
    throw StateError('Maps are unavailable on this device');
  }
}
