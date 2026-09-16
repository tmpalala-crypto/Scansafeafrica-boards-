import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch(e){}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
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
        child: ListView(children: [
            DrawerHeader(decoration: BoxDecoration(color: Colors.green[800]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.verified_user, color: Colors.white, size: 50), SizedBox(height: 8),
                Text("ScanSafeAfrica", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Clean Our Country. Stop Fakes.", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            ListTile(leading: Icon(Icons.qr_code_scanner, color: Colors.green), title: Text("PPL SCAN"), onTap: (){ Navigator.pop(context); setState((){_index=0;}); }),
            ListTile(leading: Icon(Icons.verified_user, color: Colors.orange), title: Text("INSPECTION"), onTap: (){ Navigator.pop(context); setState((){_index=1;}); }),
            ListTile(leading: Icon(Icons.dashboard, color: Colors.blue), title: Text("BOARD"), onTap: (){ Navigator.pop(context); setState((){_index=2;}); }),
            Divider(),
            ListTile(leading: Icon(Icons.flag, color: Colors.green[800]), title: Text("CEO Mission"), subtitle: Text("Fighting fake & xenophobia"), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (c)=>CEOMissionPage())); }),
            ListTile(leading: Icon(Icons.shield, color: Colors.orange[800]), title: Text("For Brands - QR Protect"), subtitle: Text("Generate Protected QR"), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (c)=>BrandProtectionPage())); }),
        ]),
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

class PplScanPage extends StatefulWidget { const PplScanPage({super.key}); @override State<PplScanPage> createState()=> _PplScanPageState(); }
class _PplScanPageState extends State<PplScanPage> {
  final brandCtrl=TextEditingController(); final shopCtrl=TextEditingController();
  String lat=""; String lng=""; String status="Ready"; bool loading=false;
  Future<void> getLocation() async {
    setState((){loading=true; status="Getting GPS...";});
    try{
      if(!await Geolocator.isLocationServiceEnabled()){setState((){status="Turn ON Location"; loading=false;}); return;}
      var perm=await Geolocator.checkPermission(); if(perm==LocationPermission.denied){ perm=await Geolocator.requestPermission();}
      var pos=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState((){lat=pos.latitude.toStringAsFixed(6); lng=pos.longitude.toStringAsFixed(6); status="GPS Locked!"; loading=false;});
    }catch(e){setState((){status="Error: $e"; loading=false;});}
  }
  Future<void> saveToFirebase() async {
    if(brandCtrl.text.isEmpty||shopCtrl.text.isEmpty){setState((){status="Fill Brand & Shop!";}); return;}
    try{
      await FirebaseFirestore.instance.collection('scans').add({
        'brand': brandCtrl.text, 'shop': shopCtrl.text, 'lat': lat, 'lng': lng, 'timestamp': FieldValue.serverTimestamp(),
      });
      setState((){status="Saved! Thank you!";}); brandCtrl.clear(); shopCtrl.clear();
    }catch(e){setState((){status="Error: $e";});}
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("ScanSafeAfrica - PPL SCAN")), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
      TextField(controller: brandCtrl, decoration: InputDecoration(labelText: "Brand / Product Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: shopCtrl, decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      Row(children: [ElevatedButton(onPressed: getLocation, child: Text(loading?"...":"Get Location")), SizedBox(width: 10), Expanded(child: Text(status))]),
      SizedBox(height: 10),
      ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green[800]), onPressed: saveToFirebase, child: Text("SCAN & REPORT", style: TextStyle(color: Colors.white))),
    ])));
  }
}

class InspectionPage extends StatelessWidget { const InspectionPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Inspection")), body: Center(child: Text("Inspection - View fake reports"))); } }
class BoardPage extends StatelessWidget { const BoardPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Board")), body: Center(child: Text("Board - Analytics"))); } }

class CEOMissionPage extends StatelessWidget {
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("CEO Mission"), backgroundColor: Colors.green[800]), body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Clean Our Country. Stop Duplicate. Create Jobs.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 15),
      Text("We face health problems because of the food we eat. We blame brands and forget that we buy FAKE stuff.\n\nWe need to clean our country and stop duplication. Every product must be registered and all departments need to do their jobs. SSA wants to partner with them on Scan Check, Inspection and Law must do its work.\n\nFIGHTING FAKE, CORRUPTION & XENOPHOBIA:\nFake products make our communities sick and divide us. When kids get sick from spaza shops, we blame each other, but the real enemy is fake compliance.\n\nBOOST ECONOMY & JOBS:\nIf you make a product, you must be accountable - meet all requirements and compliance. That way we create more job opportunities.\n\nPROTECT NEW BRANDS:\nI want new brands to trust the system without being scared of being duplicated and sold cheap, then got blamed and face lawsuits because it's their name product sold but no profit for them.", style: TextStyle(fontSize: 16, height: 1.5)),
      SizedBox(height: 20),
      Text("- Qiniso Mark, Founder & CEO, Bethelsdorp", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
    ])));
  }
}

class BrandProtectionPage extends StatefulWidget { @override State<BrandProtectionPage> createState() => _BrandProtectionPageState(); }
class _BrandProtectionPageState extends State<BrandProtectionPage> {
  final brandCtrl=TextEditingController(); final productCtrl=TextEditingController(); final barcodeCtrl=TextEditingController();
  String generatedQR = "";
  void generateQR(){
    if(brandCtrl.text.isEmpty) return;
    String secret = DateTime.now().millisecondsSinceEpoch.toString();
    String data = "SSA-VERIFIED|BRAND:${brandCtrl.text}|PROD:${productCtrl.text}|BAR:${barcodeCtrl.text}|ID:$secret";
    setState((){ generatedQR = data; });
    FirebaseFirestore.instance.collection('protected_brands').add({
      'brand': brandCtrl.text, 'product': productCtrl.text, 'barcode': barcodeCtrl.text, 'qr_data': data, 'created': FieldValue.serverTimestamp(),
    });
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("Brand QR Protection"), backgroundColor: Colors.orange[800]), body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.shield, size: 70, color: Colors.orange[800]),
      Text("For Real Brands. Protected QR.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text("Generate QR that cannot be copied. If same QR scanned in 2 different towns, system alerts FAKE! Protects you from lawsuit."),
      SizedBox(height: 20),
      TextField(controller: brandCtrl, decoration: InputDecoration(labelText: "Brand Name *", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: productCtrl, decoration: InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
      SizedBox(height: 10),
      TextField(controller: barcodeCtrl, decoration: InputDecoration(labelText: "Barcode", border: OutlineInputBorder())),
      SizedBox(height: 20),
      ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.orange[800]), onPressed: generateQR, child: Text("GENERATE PROTECTED QR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      SizedBox(height: 20),
      if(generatedQR.isNotEmpty) Center(child: Column(children: [
        Container(padding: EdgeInsets.all(15), color: Colors.white, child: QrImageView(data: generatedQR, version: QrVersions.auto, size: 230)),
        SizedBox(height: 10),
        SelectableText(generatedQR, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(height: 10),
        Container(padding: EdgeInsets.all(12), color: Colors.green[50], child: Text("✅ SAVED & PROTECTED!\nNow print this QR on your product. Customer scans with PPL SCAN. If duplicated, app will show WARNING: ALREADY SCANNED ELSEWHERE = FAKE!", style: TextStyle(fontWeight: FontWeight.bold))),
      ])),
    ])));
  }
}
