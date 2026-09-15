import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() => runApp(ScanSafeApp());

class ScanSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'ScanSafeAfrica Stage2', home: LoginPage());
  }
}

// LOGIN
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  int attempts = 0, blockSeconds = 0;
  List<String> logs = [];
  Timer? timer;
  final String REAL_USER = "Scansafeadmin";
  final String REAL_PASS = "SSA_86Primrose";

  void login() {
    if (blockSeconds > 0) return;
    if (userCtrl.text == REAL_USER && passCtrl.text == REAL_PASS) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
      return;
    }
    attempts++;
    String time = DateTime.now().toString().substring(11,19);
    setState(() => logs.insert(0, "$time - HONEYPOT - ${userCtrl.text}"));
    if (attempts >= 3) {
      setState(() => blockSeconds = 30);
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() { blockSeconds--; if (blockSeconds <= 0) { t.cancel(); attempts = 0; } });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(children: [
        SizedBox(height: 40),
        Icon(Icons.shield, size: 80, color: Color(0xFF0D2C54)),
        Text("ScanSafeAfrica", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D2C54))),
        Text("STAGE 2: REAL GPS + 50 BRANDS + SAPS EXPORT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
        SizedBox(height: 20),
        TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
        SizedBox(height: 10),
        TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
        SizedBox(height: 15),
        if (attempts >= 3) Container(width: double.infinity, padding: EdgeInsets.all(12), color: Colors.red[100], child: Text("🚫 BLOCKED $blockSeconds sec", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: blockSeconds>0?null:login, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0D2C54)), child: Text(blockSeconds>0?"BLOCKED":"LOGIN STAGE 2", style: TextStyle(color: Colors.white)))),
        SizedBox(height: 20),
        if (logs.isNotEmpty)...[Text("Logs"),...logs.take(3).map((l)=>Container(margin: EdgeInsets.only(top:5), padding: EdgeInsets.all(8), color: Colors.orange[100], width: double.infinity, child: Text(l, style: TextStyle(fontSize: 11))))]
      ])),
    );
  }
}

// DASHBOARD STAGE 2 - REAL GPS NO PACKAGE
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? lat, lng;
  double? accuracy;
  String gpsStatus = "Tap GPS button to get REAL location";
  List<Map<String,dynamic>> incidents = [];
  String selectedBrand = "Coca-Cola 2L";
  final barcodeCtrl = TextEditingController(text: "6001234567890");

  final List<String> brands50 = [
    "Coca-Cola 2L","Coca-Cola 500ml","Fanta Orange","Sprite","Stoney",
    "Lays Salt & Vinegar","Lays Tomato","Simba Chips","Doritos","Nik Naks",
    "Sunlight Dish 750ml","Sunlight Bar","Stay Soft","Domestos","Ariel Washing",
    "OMO Washing","Colgate Toothpaste","Always Pads","Pampers","Nivea Lotion",
    "Vaseline Blue Seal","Lux Soap","Dove Soap","Shield Roll-on","Head & Shoulders",
    "Castle Lager","Black Label","Savanna Cider","Hunters Gold","Heineken",
    "White Star Maize","Iwisa Maize","Tastic Rice","Koo Baked Beans","Lucky Star Pilchards",
    "All Gold Tomato","Crosse & Blackwell Mayo","Robertsons Spice","Knorr Soup","Maggi Noodles",
    "Weet-Bix","Corn Flakes Kelloggs","Jungle Oats","Oros","Energade",
    "Amarula","Glenfiddich (FAKE ALERT)","Johnnie Walker Black","Hennessy Cognac","Pringle Original"
  ];

  @override
  void initState(){ super.initState(); _getRealGPS(); }

  void _getRealGPS() {
    setState(()=> gpsStatus = "🔍 Getting REAL phone GPS... Allow permission!");
    try{
      html.window.navigator.geolocation.getCurrentPosition().then((pos){
        setState(){
          lat = pos.coords!.latitude!.toDouble();
          lng = pos.coords!.longitude!.toDouble();
          accuracy = pos.coords!.accuracy!.toDouble();
          gpsStatus = "${lat!.toStringAsFixed(6)}, ${lng!.toStringAsFixed(6)} - Accurate: ${accuracy!.toStringAsFixed(1)}m - REAL PHONE GPS!";
        }
      }).catchError((e){
        setState(()=> gpsStatus = "GPS Error: $e - Allow location in browser! Using Bethelsdorp fallback");
        lat = -33.8529; lng = 25.5800;
      });
    }catch(e){
      setState(){ gpsStatus = "Browser GPS not supported - Fallback Bethelsdorp"; lat=-33.8529; lng=25.5800; }
    }
  }

  void onScan() {
    if(barcodeCtrl.text.isEmpty) return;
    double useLat = lat?? -33.8529;
    double useLng = lng?? 25.5800;
    var incident = {
      "time": DateTime.now(),
      "barcode": barcodeCtrl.text,
      "brand": selectedBrand,
      "status": "SUSPECT - VERIFICATION REQUIRED",
      "lat": useLat, "lng": useLng,
      "sapsNo": "SAPS-${DateTime.now().millisecondsSinceEpoch}",
      "mapsUrl": "https://www.google.com/maps/search/?api=1&query=$useLat,$useLng"
    };
    setState(()=> incidents.insert(0, incident));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("🚨 SUSPECT: $selectedBrand - Real GPS: $useLat,$useLng - ${incident['sapsNo']}")));
  }

  void exportSAPS() {
    if(incidents.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No incidents"))); return; }
    String csv = "SAPS No,Time,Brand,Barcode,Lat,Lng,Maps,Status\n";
    for(var d in incidents){ csv += "${d['sapsNo']},${d['time']},${d['brand']},${d['barcode']},${d['lat']},${d['lng']},${d['mapsUrl']},${d['status']}\n"; }
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text("SAPS EXPORT - ${incidents.length} CASES"),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("COPY FOR SAPS & CIPC:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        SizedBox(height:10),
        Container(padding: EdgeInsets.all(8), color: Colors.grey[200], child: SelectableText(csv, style: TextStyle(fontSize:8, fontFamily:'monospace'))),
        SizedBox(height:10),
        Text("Total: ${incidents.length} | Brands: ${incidents.map((e)=>e['brand']).toSet().length}/50 | Ready for submission", style: TextStyle(fontSize:11))
      ])),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("CLOSE"))]
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("STAGE 2 - ${incidents.length} SUSPECT"), backgroundColor: Color(0xFF0D2C54), foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.download), onPressed: exportSAPS), IconButton(icon: Icon(Icons.my_location), onPressed: _getRealGPS)]),
      body: Column(children: [
        Container(width: double.infinity, color: lat==null? Colors.orange[50]: Colors.green[50], padding: EdgeInsets.all(10), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.gps_fixed, color: lat==null? Colors.orange: Colors.green, size:18), SizedBox(width:5), Text(lat==null?"REAL GPS - TAP BUTTON":"✅ REAL PHONE GPS ACTIVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))]),
          SizedBox(height:4),
          Text(gpsStatus, style: TextStyle(fontSize:11), textAlign: TextAlign.center),
          if(lat!=null) SelectableText("https://www.google.com/maps/search/?api=1&query=$lat,$lng", style: TextStyle(fontSize:9, color: Colors.blue)),
        ])),
        Container(padding: EdgeInsets.all(10), child: Column(children: [
          Row(children: [
            Expanded(flex:3, child: DropdownButtonFormField<String>(value: selectedBrand, isExpanded: true, decoration: InputDecoration(labelText: "50 BRANDS", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal:10, vertical:5)), items: brands50.map((b)=>DropdownMenuItem(value:b, child: Text(b, style: TextStyle(fontSize:11)))).toList(), onChanged: (v)=>setState(()=>selectedBrand=v!))),
            SizedBox(width:8),
            Expanded(flex:2, child: TextField(controller: barcodeCtrl, decoration: InputDecoration(labelText: "Barcode", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal:10, vertical:5)), style: TextStyle(fontSize:12))),
          ]),
          SizedBox(height:8),
          SizedBox(width: double.infinity, height:45, child: ElevatedButton.icon(icon: Icon(Icons.qr_code_scanner), label: Text("SCAN SUSPECT & REPORT"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: onScan)),
        ])),
        if(incidents.isNotEmpty) Container(padding: EdgeInsets.symmetric(horizontal:10, vertical:5), color: Colors.blue[50], child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total: ${incidents.length}", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold)), Text("Brands: ${incidents.map((e)=>e['brand']).toSet().length}/50", style: TextStyle(fontSize:11)), TextButton(onPressed: exportSAPS, child: Text("EXPORT SAPS", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold)))])),
        Expanded(child: incidents.isEmpty? Center(child: Text("No SUSPECT yet - Select brand + SCAN")) : ListView.builder(itemCount: incidents.length, itemBuilder: (_,i){ var d=incidents[i]; return Card(color: Colors.orange[50], margin: EdgeInsets.symmetric(horizontal:8, vertical:4), child: ListTile(leading: Icon(Icons.warning, color: Colors.red), title: Text(d['brand'], style: TextStyle(fontWeight: FontWeight.bold, fontSize:13)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Barcode: ${d['barcode']} | ${d['sapsNo']}", style: TextStyle(fontSize:10)), Text("📍 ${d['lat'].toStringAsFixed(6)}, ${d['lng'].toStringAsFixed(6)}", style: TextStyle(fontSize:10)), Text("${d['status']}", style: TextStyle(fontSize:9, color: Colors.red, fontWeight: FontWeight.bold)), Text("${d['mapsUrl']}", style: TextStyle(fontSize:8, color: Colors.blue))]))); })),
      ]),
    );
  }
}
