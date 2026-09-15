import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// GLOBAL REPORTS LIST - Will be Firebase in Stage 5
List<Map<String, dynamic>> allReports = [];

void main() {
  runApp(ScanSafeAfricaApp());
}

class ScanSafeAfricaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanSafeAfrica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainSelector(),
    );
  }
}

class MainSelector extends StatefulWidget {
  @override
  _MainSelectorState createState() => _MainSelectorState();
}

class _MainSelectorState extends State<MainSelector> {
  int selectedIndex = 0;

  final screens = [
    CitizenScanStage4(),
    InspectorScreen(),
    AdminBoardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "PPL SCAN"),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: "INSPECTION"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "BOARD"),
        ],
      ),
    );
  }
}

// ================== 1. CITIZEN SCAN STAGE 4 ==================
class CitizenScanStage4 extends StatefulWidget {
  @override
  _CitizenScanStage4State createState() => _CitizenScanStage4State();
}

class _CitizenScanStage4State extends State<CitizenScanStage4> {
  final brandController = TextEditingController();
  final shopController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  bool loading = false;

  Future<void> getLocation() async {
    setState(() => loading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latController.text = pos.latitude.toString();
        lngController.text = pos.longitude.toString();
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("GPS Locked: ${pos.latitude}, ${pos.longitude}"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("GPS Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void sendWhatsApp() {
    if (brandController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill brand first")));
      return;
    }
    final msg = "*SCANSAFEAFRICA FAKE REPORT*%0A%0A*Brand:* ${brandController.text}%0A*Shop:* ${shopController.text}%0A*GPS:* ${latController.text}, ${lngController.text}%0A*Maps:* https://maps.google.com/?q=${latController.text},${lngController.text}%0A%0AReported via ScanSafeAfrica";
    final url = Uri.parse("https://wa.me/27815555555?text=$msg");
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void submitReport() {
    if (brandController.text.isEmpty || shopController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill Brand + Shop")));
      return;
    }
    setState(() {
      allReports.add({
        "brand": brandController.text,
        "shop": shopController.text,
        "lat": latController.text,
        "lng": lngController.text,
        "time": DateTime.now().toString(),
        "status": "PENDING"
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("REPORT SAVED GREEN! + Board Linked!"), backgroundColor: Colors.green),
    );
    brandController.clear();
    shopController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CITIZEN SCAN - STAGE 4"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.shield, size: 80, color: Colors.green),
            Text("Report Fake Goods in 10 Sec", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading? null : getLocation,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
              child: Text(loading? "GETTING GPS..." : "📍 GET MY LOCATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            TextField(controller: latController, decoration: InputDecoration(labelText: "Latitude (auto)", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: lngController, decoration: InputDecoration(labelText: "Longitude (auto)", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: brandController, decoration: InputDecoration(labelText: "Brand (Nike, Coca-Cola)", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: shopController, decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder())),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitReport,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50)),
              child: Text("✅ SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendWhatsApp,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), minimumSize: Size(double.infinity, 50)),
              child: Text("📲 SEND TO SAPS WHATSAPP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            Text("Reports: ${allReports.length} linked to Board", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ================== 2. INSPECTION APP ==================
class InspectorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("INSPECTION APP"), backgroundColor: Colors.orange),
      body: allReports.isEmpty
         ? Center(child: Text("No reports yet. Citizen reports will appear here LIVE"))
          : ListView.builder(
              itemCount: allReports.length,
              itemBuilder: (ctx, i) {
                var r = allReports[i];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${r['brand']} @ ${r['shop']}"),
                    subtitle: Text("GPS: ${r['lat']}, ${r['lng']}\nStatus: ${r['status']}"),
                    trailing: Icon(Icons.verified, color: Colors.orange),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verify on ground - Stage 5 will add photo evidence")));
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ================== 3. BOARD (ADMIN WEB) ==================
class AdminBoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BOARD - ADMIN"), backgroundColor: Colors.black87),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(15),
            width: double.infinity,
            child: Column(
              children: [
                Text("SCANSAFEAFRICA BOARD", style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Total Reports: ${allReports.length} | Hotspot: Bethelsdorp", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: allReports.isEmpty
               ? Center(child: Text("No reports yet. Linked to Citizen + Inspection"))
                : ListView.builder(
                    itemCount: allReports.length,
                    itemBuilder: (ctx, i) {
                      var r = allReports[i];
                      return ListTile(
                        leading: Icon(Icons.location_on, color: Colors.red),
                        title: Text("${r['brand']} - ${r['shop']}"),
                        subtitle: Text("Map: https://maps.google.com/?q=${r['lat']},${r['lng']}\nTime: ${r['time']}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            final url = Uri.parse("https://maps.google.com/?q=${r['lat']},${r['lng']}");
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                          child: Text("VIEW MAP"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
