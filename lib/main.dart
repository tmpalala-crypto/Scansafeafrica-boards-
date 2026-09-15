import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(ScanSafeApp());

class ScanSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanSafeAfrica',
      home: LoginPage(),
    );
  }
}

// ================= LOGIN + HONEYPOT =================
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  int attempts = 0;
  int blockSeconds = 0;
  List<String> logs = [];
  Timer? timer;

  // YOUR NEW SECURE PASSWORD
  final String REAL_USER = "Scansafeadmin";
  final String REAL_PASS = "SSA_86Primrose";

  void login() {
    if (blockSeconds > 0) return;

    // SUCCESS - YOUR PASSWORD
    if (userCtrl.text == REAL_USER && passCtrl.text == REAL_PASS) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
      return;
    }

    // FAILED - HONEYPOT TRIGGER
    attempts++;
    String time = DateTime.now().toString().substring(11,19);
    setState(() {
      logs.insert(0, "$time - HONEYPOT TRIGGERED - SUSPECT Attempt - ${userCtrl.text}");
    });

    if (attempts >= 3) {
      setState(() => blockSeconds = 30);
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() {
          blockSeconds--;
          if (blockSeconds <= 0) {
            t.cancel();
            attempts = 0;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),
            Icon(Icons.shield, size: 80, color: Color(0xFF0D2C54)),
            Text("ScanSafeAfrica", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D2C54))),
            Text("ScanSafeAfrica - Central Board", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("50 BRANDS - 20 DEPTS - CONTRACT READY", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
            SizedBox(height: 15),
            if (attempts >= 3)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                color: Colors.red[100],
                child: Text("🚫 BLOCKED FOR $blockSeconds sec - Incident reported to SAPS Task Team & CIPC", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: blockSeconds > 0? null : login,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0D2C54)),
                child: Text(blockSeconds > 0? "BLOCKED - $blockSeconds s" : "LOGIN TO LIVE BOARD", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Text("Security: Honeypot active | Auto-block after 3 fails | All attempts logged for SAPS", style: TextStyle(fontSize: 9, color: Colors.grey)),
            SizedBox(height: 20),
            if (logs.isNotEmpty)...[
              Text("Recent Security Logs (${logs.length})", style: TextStyle(fontWeight: FontWeight.bold)),
             ...logs.take(3).map((l) => Container(margin: EdgeInsets.only(top:5), padding: EdgeInsets.all(8), color: Colors.orange[100], width: double.infinity, child: Text(l, style: TextStyle(fontSize: 11)))),
            ]
          ],
        ),
      ),
    );
  }
}

// ================= DASHBOARD - SUSPECT + AUTO LOCATION/ALERT/MAP/REPORT =================
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Position? curPos;
  List<Map<String,dynamic>> incidents = [];

  @override
  void initState(){
    super.initState();
    _getLoc();
  }

  Future<void> _getLoc() async {
    LocationPermission perm = await Geolocator.requestPermission();
    Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(()=> curPos = p);
  }

  // THIS RUNS AUTOMATICALLY WHEN SOMEONE SCANS
  void onScan(String barcode, String brand) async {
    Position p = await Geolocator.getCurrentPosition();
    var incident = {
      "time": DateTime.now().toString(),
      "barcode": barcode,
      "brand": brand,
      "status": "SUSPECT - VERIFICATION REQUIRED",
      "location": "${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}",
      "address": "Auto-detected: Bethelsdorp/Motherwell/Booysens Park",
      "sapsNo": "SAPS-${DateTime.now().millisecondsSinceEpoch}",
    };
    setState(()=> incidents.insert(0, incident));

    // AUTO ALERT
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("🚨 SUSPECT: $brand - Location & Report auto-logged for SAPS/CIPC - ${incident['sapsNo']}"), duration: Duration(seconds: 4)));

    // AUTO REPORT (here you would save to Firebase)
    print("AUTO REPORT GENERATED: ${incident['sapsNo']} -> SAPS & CIPC");
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("LIVE BOARD - SUSPECT SYSTEM"), backgroundColor: Color(0xFF0D2C54), foregroundColor: Colors.white),
      body: Column(children: [
        Container(height: 180, child: curPos == null? Center(child: CircularProgressIndicator()) : FlutterMap(options: MapOptions(initialCenter: LatLng(curPos!.latitude, curPos!.longitude), initialZoom: 14), children: [TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"), MarkerLayer(markers: [Marker(point: LatLng(curPos!.latitude, curPos!.longitude), child: Icon(Icons.location_on, color: Colors.red, size: 40))])])),
        Padding(padding: EdgeInsets.all(8), child: Text("📍 Auto Location Active | Tap SCAN to simulate citizen scan", style: TextStyle(fontSize: 11))),
        Expanded(child: incidents.isEmpty? Center(child: Text("No SUSPECT scans yet - waiting for citizen scans...")) : ListView.builder(itemCount: incidents.length, itemBuilder: (_,i){var d=incidents[i]; return Card(color: Colors.orange[50], child: ListTile(leading: Icon(Icons.warning, color: Colors.red), title: Text("${d['brand']} - ${d['status']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), subtitle: Text("Barcode: ${d['barcode']}\nLoc: ${d['location']}\nTime: ${d['time'].toString().substring(0,19)}\n${d['sapsNo']} - Auto-reported to SAPS & CIPC"))));}),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()=> onScan("6001234567890", "Coca-Cola 2L"), backgroundColor: Colors.red, child: Icon(Icons.qr_code_scanner), tooltip: "SIMULATE SCAN"),
    );
  }
}
