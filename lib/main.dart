import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch(e){ debugPrint(e.toString()); }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'ScanSafeAfrica', theme: ThemeData(primarySwatch: Colors.green), home: const MainNav());
  }
}

class MainNav extends StatefulWidget { const MainNav({super.key}); @override State<MainNav> createState() => _MainNavState(); }
class _MainNavState extends State<MainNav> {
  int _index=0;
  final _pages=[const PplScanPage(), const InspectionPage(), const BoardPage()];
  @override Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[800]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.verified_user, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Clean Our Country. Stop Fakes.", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            ListTile(leading: Icon(Icons.qr_code_scanner, color: Colors.green), title: Text("PPL SCAN"), onTap: (){ Navigator.pop(context); setState((){_index=0;}); }),
            ListTile(leading: Icon(Icons.verified_user, color: Colors.orange), title: Text("INSPECTION"), onTap: (){ Navigator.pop(context); setState((){_index=1;}); }),
            ListTile(leading: Icon(Icons.dashboard, color: Colors.blue), title: Text("BOARD"), onTap: (){ Navigator.pop(context); setState((){_index=2;}); }),
            Divider(),
            ListTile(leading: Icon(Icons.flag, color: Colors.green[800]), title: Text("CEO Mission - Clean SA"), subtitle: Text("Fighting fake, corruption, xenophobia"), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (c)=>CEOMissionPage())); }),
            ListTile(leading: Icon(Icons.shield, color: Colors.orange[800]), title: Text("For Brands - Get Protected"), subtitle: Text("Stop duplicate, avoid lawsuit"), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (c)=>BrandProtectionPage())); }),
          ],
        ),
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (i){ setState((){_index=i;}); }, items: [
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'PPL SCAN'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'INSPECTION'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'BOARD'),
      ]),
    );
  }
}

// --- YOUR ORIGINAL SCAN PAGE (kept) ---
class PplScanPage extends StatefulWidget { const PplScanPage({super.key}); @override State<PplScanPage> createState()=> _PplScanPageState(); }
class _PplScanPageState extends State<PplScanPage> {
  final brandCtrl=TextEditingController(); final shopCtrl=TextEditingController();
  String lat=""; String lng=""; String status="Ready to scan"; bool loading=false;
  Future<void> getLocation() async {
    setState((){loading=true; status="Getting GPS...";});
    try{
      if(!await Geolocator.isLocationServiceEnabled()){setState((){status="Turn ON Location"; loading=false;}); return;}
      var perm=await Geolocator.checkPermission(); if(perm==LocationPermission.denied){ perm=await Geolocator.requestPermission(); if(perm==LocationPermission.denied){setState((){status="Location denied forever"; loading=false;}); return;}}
      var pos=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState((){lat=pos.latitude.toString(); lng=pos.longitude.toString(); status="GPS Locked!"; loading=false;});
    }catch(e){setState((){status="GPS Error: $e"; loading=false;});}
  }
  Future<void> saveToFirebase() async {
    if(brandCtrl.text.isEmpty||shopCtrl.text.isEmpty){setState((){status="Fill Brand & Shop!";}); return;}
    try{
      await FirebaseFirestore.instance.collection('scans').add({
        'brand': brandCtrl.text, 'shop': shopCtrl.text, 'lat': lat, 'lng': lng, 'timestamp': FieldValue.serverTimestamp(),
        'status': 'reported', 'isFake': false,
      });
      setState((){status="Saved! Thank you for cleaning SA!";}); brandCtrl.clear(); shopCtrl.clear();
    }catch(e){setState((){status="Error: $e";});}
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("ScanSafeAfrica - PPL Scan")), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: brandCtrl, decoration: InputDecoration(labelText: "Brand / Product Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: shopCtrl, decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      Row(children: [ElevatedButton(onPressed: getLocation, child: Text(loading?"...":"Get Location")), SizedBox(width: 10), Text(status)]),
      SizedBox(height: 10),
      ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green[800]), onPressed: saveToFirebase, child: Text("SCAN & REPORT", style: TextStyle(color: Colors.white))),
    ])));
  }
}

class InspectionPage extends StatelessWidget { const InspectionPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Inspection")), body: Center(child: Text("Inspection Dashboard - Dept can view reports here"))); } }
class BoardPage extends StatelessWidget { const BoardPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Board")), body: Center(child: Text("Board - Analytics of fakes in SA"))); } }

// --- NEW CEO MISSION PAGE ---
class CEOMissionPage extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("CEO Mission"), backgroundColor: Colors.green[800]), body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Clean Our Country. Stop Duplicate. Create Jobs.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 15),
      Text("We face health problems because of the food we eat. We blame brands and forget that we buy FAKE stuff.\n\nWe need to clean our country and stop duplication. Every product must be registered and all departments need to do their jobs. SSA wants to partner with them on Scan Check, Inspection and Law must do their work.\n\nFIGHTING FAKE, CORRUPTION & XENOPHOBIA:\nFake products make our communities sick and divide us. When kids get sick from spaza shops, we blame each other, but the real enemy is fake compliance. We must decrease xenophobia in our society.\n\nBOOST ECONOMY & JOBS:\nTo boost the economy, we help real brands not be faked. If you make a product, you must be accountable - meet all requirements and compliance. That way we create more job opportunities.\n\nPROTECT NEW BRANDS:\nI want new brands to trust the system without being scared of being duplicated and sold cheap, then got blamed and face lawsuits because it's their name product sold but no profit for them. It's small percentage real, then a lot of stock outside is duplicate.\n\nOur solution is traceability - every real product gets a protected identity.", style: TextStyle(fontSize: 16, height: 1.5)),
      SizedBox(height: 20),
      Text("- Qiniso Mark, Founder & CEO, Bethelsdorp, Gqeberha", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
    ])));
  }
}

// --- NEW BRAND PROTECTION PAGE ---
class BrandProtectionPage extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("Brand Protection"), backgroundColor: Colors.orange[800]), body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.shield, size: 70, color: Colors.orange[800]),
      Text("For Real Brands. We Protect You From Fakes.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text("Scared your brand will be duplicated, sold cheap, and you face lawsuits when people get sick? Even though it's not your product and you made no profit? We fix that."),
      SizedBox(height: 20),
      TextField(decoration: InputDecoration(labelText: "Brand Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(decoration: InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(decoration: InputDecoration(labelText: "Barcode", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(decoration: InputDecoration(labelText: "Compliance (SABS / Dept Health)", border: OutlineInputBorder())),
      SizedBox(height: 20),
      Container(padding: EdgeInsets.all(15), color: Colors.orange[50], child: Text("✓ Protected QR that cannot be duplicated\n✓ Traceable batch ID\n✓ Legal proof - protect from lawsuit\n✓ Customer can verify REAL")),
      SizedBox(height: 20),
      ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.orange[800]), onPressed: (){}, child: Text("REGISTER PRODUCT - BE SAFE", style: TextStyle(color: Colors.white))),
      SizedBox(height: 10),
      Center(child: Text("Partner: Health | SAPS | SARS | Trade | SSA Scan Check", style: TextStyle(fontSize: 11, color: Colors.grey))),
    ])));
  }
}
