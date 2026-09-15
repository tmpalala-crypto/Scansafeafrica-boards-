import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanSafeAfrica',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;
  final _pages = [const PplScanPage(), const InspectionPage(), const BoardPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'PPL SCAN'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'INSPECTION'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'BOARD'),
        ],
      ),
    );
  }
}

// ================= PPL SCAN =================
class PplScanPage extends StatefulWidget {
  const PplScanPage({super.key});
  @override
  State<PplScanPage> createState() => _PplScanPageState();
}

class _PplScanPageState extends State<PplScanPage> {
  final brandCtrl = TextEditingController();
  final shopCtrl = TextEditingController();
  String lat = "";
  String lng = "";
  String status = "Ready to scan";
  bool loading = false;

  Future<void> getLocation() async {
    setState(() { loading = true; status = "Getting GPS..."; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() { status = "Please turn ON location"; loading = false; }); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) { setState(() { status = "Location denied forever"; loading = false; }); return; }
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { lat = pos.latitude.toString(); lng = pos.longitude.toString(); status = "GPS Locked!"; loading = false; });
    } catch (e) {
      setState(() { status = "GPS Error: $e"; loading = false; });
    }
  }

  Future<void> saveToFirebase() async {
    if (brandCtrl.text.isEmpty || shopCtrl.text.isEmpty) { setState(() => status = "Fill Brand & Shop!"); return; }
    if (lat.isEmpty) { setState(() => status = "Get Location first!"); return; }
    setState(() { loading = true; status = "Saving to cloud..."; });
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'brand': brandCtrl.text.trim(),
        'shop': shopCtrl.text.trim(),
        'latitude': lat,
        'longitude': lng,
        'mapLink': "https://maps.google.com/?q=$lat,$lng",
        'timestamp': FieldValue.serverTimestamp(),
        'result': 'FAKE - ScanSafeAfrica',
      });
      setState(() { status = "✅ SAVED TO CLOUD FOREVER!"; loading = false; });
      brandCtrl.clear(); shopCtrl.clear();
    } catch (e) {
      setState(() { status = "Firebase Error: $e\nCheck Firestore Rules!"; loading = false; });
    }
  }

  Future<void> sendWhatsApp() async {
    if (lat.isEmpty) { setState(() => status = "Get Location first!"); return; }
    String msg = "🚨 SCANSAFEAFRICA FAKE ALERT 🚨\n\nBrand: ${brandCtrl.text}\nShop: ${shopCtrl.text}\nGPS: $lat, $lng\nMap: https://maps.google.com/?q=$lat,$lng\n\nSent from Bethelsdorp";
    final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PPL SCAN - CITIZEN"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: "Brand Name (e.g. Coke)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: shopCtrl, decoration: const InputDecoration(labelText: "Shop Name (e.g. Spar Bethelsdorp)", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: loading ? null : getLocation, icon: const Icon(Icons.my_location), label: const Text("📍 GET MY LOCATION"), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50))),
            const SizedBox(height: 12),
            if (lat.isNotEmpty) Container(padding: const EdgeInsets.all(12), color: Colors.green.shade50, child: Column(children: [Text("Lat: $lat"), Text("Lng: $lng"), SelectableText("https://maps.google.com/?q=$lat,$lng")])),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: loading ? null : saveToFirebase, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)), child: const Text("☁️ SAVE TO FIREBASE", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: sendWhatsApp, style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, minimumSize: const Size(double.infinity, 50)), child: const Text("💬 SEND WHATSAPP TO SAPS", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 16),
            Text(status, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ================= INSPECTION =================
class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("INSPECTION - LIVE"), backgroundColor: Colors.orange),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Error: ${snap.error}\n\nFix Firestore Rules!"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.docs.isEmpty) return const Center(child: Text("No reports yet.\nScan something!"));
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (c, i) {
              var d = snap.data!.docs[i];
              var data = d.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${data['brand']} @ ${data['shop']}"),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("GPS: ${data['latitude']}, ${data['longitude']}"),
                    InkWell(onTap: () async { final url = Uri.parse(data['mapLink'] ?? "https://maps.google.com/?q=${data['latitude']},${data['longitude']}"); if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }, child: const Text("📍 Open in Google Maps", style: TextStyle(color: Colors.blue))),
                  ]),
                  trailing: Text(data['result'] ?? "FAKE"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= BOARD =================
class BoardPage extends StatelessWidget {
  const BoardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BOARD - ADMIN LIVE"), backgroundColor: Colors.blue),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, snap) {
          int total = snap.hasData ? snap.data!.docs.length : 0;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dashboard, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text("TOTAL REPORTS: $total", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("ScanSafeAfrica - Anti-Fake SA 🇿🇦"),
                const SizedBox(height: 20),
                Text("Last update: ${DateTime.now()}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
