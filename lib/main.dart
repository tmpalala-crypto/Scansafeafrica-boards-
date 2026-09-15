// Inside your CitizenScan widget
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// Add these functions inside _CitizenScanState:

Future<void> getLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  Position pos = await Geolocator.getCurrentPosition();
  setState(() {
    latController.text = pos.latitude.toString();
    lngController.text = pos.longitude.toString();
  });
}

void sendWhatsApp() {
  final msg = "*SCANSAFEAFRICA FAKE REPORT*%0ABrand: ${brandController.text}%0AShop: ${shopController.text}%0AGPS: ${latController.text}, ${lngController.text}%0AMaps: https://maps.google.com/?q=${latController.text},${lngController.text}";
  final url = "https://wa.me/27?text=$msg";
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

// In your build(), add this button BEFORE lat/lng fields:
ElevatedButton(
  onPressed: getLocation,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  child: Text("📍 GET MY LOCATION", style: TextStyle(color: Colors.white)),
),
SizedBox(height: 10),
ElevatedButton(
  onPressed: sendWhatsApp,
  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366)),
  child: Text("📲 SEND TO SAPS WHATSAPP", style: TextStyle(color: Colors.white)),
),
