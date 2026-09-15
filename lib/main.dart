import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  final screens = [CitizenScanFirebase(), InspectorFirebase(), AdminBoardFirebase()];
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

class CitizenScanFirebase extends StatefulWidget {
  @override
  _CitizenScanFirebaseState createState() => _CitizenScanFirebaseState();
}

class _CitizenScanFirebaseState extends State<CitizenScanFirebase> {
  final brandController = TextEditingController();
  final shopController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  bool loading = false;

  Future<void> getLocation() async {
    setState(()=>loading=true);
    try{
      LocationPermission p = await Geolocator.checkPermission();
      if(p==LocationPermission.denied) p = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState((){
        latController.text = pos.latitude.toString();
        lngController.text = pos.longitude.toString();
        loading=false;
      });
    }catch(e){ setState(()=>loading=false); }
  }

  Future<void> submitReport() async {
    if(brandController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('scansafrica_reports').add({
      "brand": brandController.text,
      "shop": shopController.text,
      "lat": latController.text,
      "lng": lngController.text,
      "time": DateTime.now().toString(),
      "status": "PENDING",
      "town": "Bethelsdorp, EC"
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SAVED TO CLOUD FOREVER!"), backgroundColor: Colors.green));
    brandController.clear(); shopController.clear();
  }

  void sendWhatsApp(){
    final msg = "*SCANSAFEAFRICA FAKE*%0ABrand: ${brandController.text}%0AShop: ${shopController.text}%0AGPS: ${latController.text},${lngController.text}%0AMap: https://maps.google.com/?q=${latController.text},${lngController.text}";
    launchUrl(Uri.parse("https://wa.me/27815555555?text=$msg"), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("CITIZEN SCAN - FIREBASE LIVE"), backgroundColor: Colors.green),
      body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(children: [
        Icon(Icons.cloud_done, size:80, color: Colors.green),
        Text("Firebase Connected!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height:15),
        ElevatedButton(onPressed: loading?null:getLocation, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity,50)), child: Text(loading?"GETTING GPS...":"📍 GET MY LOCATION", style: TextStyle(color: Colors.white))),
        SizedBox(height:10),
        TextField(controller: latController, decoration: InputDecoration(labelText: "Latitude", border: OutlineInputBorder())),
        SizedBox(height:10),
        TextField(controller: lngController, decoration: InputDecoration(labelText: "Longitude", border: OutlineInputBorder())),
        SizedBox(height:10),
        TextField(controller: brandController, decoration: InputDecoration(labelText: "Brand", border: OutlineInputBorder())),
        SizedBox(height:10),
        TextField(controller: shopController, decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder())),
        SizedBox(height:20),
        ElevatedButton(onPressed: submitReport, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity,50)), child: Text("☁️ SAVE TO FIREBASE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        SizedBox(height:10),
        ElevatedButton(onPressed: sendWhatsApp, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), minimumSize: Size(double.infinity,50)), child: Text("📲 SEND SAPS WHATSAPP", style: TextStyle(color: Colors.white))),
      ])),
    );
  }
}

class InspectorFirebase extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("INSPECTION - LIVE FIREBASE"), backgroundColor: Colors.orange),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('scansafrica_reports').orderBy('time', descending: true).snapshots(),
        builder: (ctx, snap){
          if(!snap.hasData) return Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs;
          if(docs.isEmpty) return Center(child: Text("No reports yet - Scan first!"));
          return ListView.builder(itemCount: docs.length, itemBuilder: (c,i){
            var r = docs[i].data() as Map<String,dynamic>;
            return Card(margin: EdgeInsets.all(8), child: ListTile(title: Text("${r['brand']} @ ${r['shop']}"), subtitle: Text("GPS: ${r['lat']}, ${r['lng']}\n${r['time']}\nStatus: ${r['status']}"), trailing: Icon(Icons.check_circle, color: Colors.green),));
          });
        },
      ),
    );
  }
}

class AdminBoardFirebase extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("BOARD - ADMIN LIVE"), backgroundColor: Colors.black87),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('scansafrica_reports').orderBy('time', descending: true).snapshots(),
        builder: (ctx, snap){
          if(!snap.hasData) return Center(child: CircularProgressIndicator());
          return Column(children: [
            Container(color: Colors.black, padding: EdgeInsets.all(15), width: double.infinity, child: Text("TOTAL REPORTS: ${snap.data!.docs.length} | LIVE FROM FIREBASE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))),
            Expanded(child: ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (c,i){
              var r = snap.data!.docs[i].data() as Map<String,dynamic>;
              return ListTile(leading: Icon(Icons.location_on, color: Colors.red), title: Text("${r['brand']} - ${r['shop']}"), subtitle: Text("${r['town']}\n${r['time']}"), trailing: ElevatedButton(onPressed: (){ launchUrl(Uri.parse("https://maps.google.com/?q=${r['lat']},${r['lng']}"), mode: LaunchMode.externalApplication); }, child: Text("MAP")));
            }))
          ]);
        },
      ),
    );
  }
}
