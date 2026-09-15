import 'package:flutter/material.dart';

void main() => runApp(ScanSafeApp());

class ScanSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainSelector());
  }
}

class MainSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.shield, size: 80, color: Color(0xFF0D2C54)),
      Text("ScanSafeAfrica", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text("STAGE 3 FIX - GREEN", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      SizedBox(height: 30),
      _btn(context, "🛡️ ADMIN", Colors.indigo, LoginPage()),
      SizedBox(height: 12),
      _btn(context, "👥 CITIZEN SCAN", Colors.green, CitizenPage()),
      SizedBox(height: 12),
      _btn(context, "🏢 BRAND OWNER", Colors.orange, BrandOwnerLogin()),
    ]))));
  }
  Widget _btn(BuildContext c, String t, Color col, Widget p){ return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: col), onPressed: ()=> Navigator.push(c, MaterialPageRoute(builder: (_)=> p)), child: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))); }
}

class LoginPage extends StatefulWidget { @override _LoginPageState createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final u = TextEditingController(); final p = TextEditingController();
  int a=0, b=0;
  void login(){ if(b>0) return; if(u.text=="Scansafeadmin" && p.text=="SSA_86Primrose"){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> DashboardPage())); return; } setState((){ a++; if(a>=3) b=30; }); if(b>0){ Future.doWhile(() async { await Future.delayed(Duration(seconds:1)); if(mounted) setState(()=> b--); return b>0; }); } }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text("ADMIN LOGIN")), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [TextField(controller: u, decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder())), SizedBox(height:10), TextField(controller: p, obscureText:true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())), SizedBox(height:20), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: b>0?null:login, child: Text(b>0?"BLOCKED $b":"LOGIN")))]))); }
}

class BrandOwnerLogin extends StatelessWidget {
  @override Widget build(BuildContext c){ final u=TextEditingController(text:"brandowner"); final p=TextEditingController(text:"brand123"); return Scaffold(appBar: AppBar(title: Text("BRAND OWNER"), backgroundColor: Colors.orange), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [TextField(controller: u, decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder())), SizedBox(height:10), TextField(controller: p, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())), SizedBox(height:20), SizedBox(width: double.infinity, height:50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: (){ Navigator.push(c, MaterialPageRoute(builder: (_)=> DashboardPage())); }, child: Text("LOGIN AS BRAND OWNER", style: TextStyle(color: Colors.white))))]))); }
}

class CitizenPage extends StatefulWidget { @override _CitizenPageState createState() => _CitizenPageState(); }
class _CitizenPageState extends State<CitizenPage> {
  String brand="Coca-Cola 2L"; final bar=TextEditingController(); final lat=TextEditingController(text:"-33.8529"); final lng=TextEditingController(text:"25.5800");
  List<String> brands=["Coca-Cola 2L","Lays Tomato","Sunlight","Castle Lager","White Star","Ariel","Other"];
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text("CITIZEN SCAN"), backgroundColor: Colors.green, foregroundColor: Colors.white), body: SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(children: [TextField(controller: lat, decoration: InputDecoration(labelText: "Lat -33.8529", border: OutlineInputBorder())), SizedBox(height:8), TextField(controller: lng, decoration: InputDecoration(labelText: "Lng 25.5800", border: OutlineInputBorder())), SizedBox(height:10), DropdownButtonFormField(value: brand, isExpanded:true, decoration: InputDecoration(labelText: "Brand", border: OutlineInputBorder()), items: brands.map((e)=> DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=> setState(()=> brand=v!)), SizedBox(height:10), TextField(controller: bar, decoration: InputDecoration(labelText: "Barcode", border: OutlineInputBorder())), SizedBox(height:15), SizedBox(width: double.infinity, height:50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){ showDialog(context: context, builder: (_)=> AlertDialog(title: Text("THANK YOU!"), content: Text("SAPS Report: $brand - ${bar.text} at ${lat.text},${lng.text} - SAPS-${DateTime.now().millisecondsSinceEpoch}"), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text("CLOSE"))])); }, child: Text("REPORT SUSPECT", style: TextStyle(color: Colors.white))))]))); }
}

class DashboardPage extends StatefulWidget { @override _DashboardPageState createState() => _DashboardPageState(); }
class _DashboardPageState extends State<DashboardPage> {
  List<Map<String,String>> inc=[]; String brand="Coca-Cola 2L"; final bar=TextEditingController(text:"6001234567890"); final lat=TextEditingController(text:"-33.8529"); final lng=TextEditingController(text:"25.5800");
  List<String> brands50=["Coca-Cola 2L","Fanta","Sprite","Lays","Simba","Sunlight","Ariel","OMO","Colgate","Castle","White Star","Tastic","Koo","All Gold","Knorr","Weet-Bix","Oros","Energade","Pringle","Other - 50 total"];
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text("ADMIN - ${inc.length} SUSPECT"), backgroundColor: Color(0xFF0D2C54), foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.download), onPressed: (){ String csv="SAPS,Brand,Barcode,Lat,Lng\n"; for(var d in inc) csv+="${d['saps']},${d['brand']},${d['bar']},${d['lat']},${d['lng']}\n"; showDialog(context: context, builder: (_)=> AlertDialog(title: Text("EXPORT ${inc.length} CASES"), content: SingleChildScrollView(child: SelectableText(csv)))); })]), body: Column(children: [Padding(padding: EdgeInsets.all(10), child: Column(children: [Row(children: [Expanded(child: DropdownButtonFormField(value: brand, isExpanded:true, decoration: InputDecoration(labelText: "50 BRANDS", border: OutlineInputBorder()), items: brands50.map((e)=> DropdownMenuItem(value:e, child: Text(e, style: TextStyle(fontSize:11)))).toList(), onChanged: (v)=> setState(()=> brand=v!)), SizedBox(width:8), Expanded(child: TextField(controller: bar, decoration: InputDecoration(labelText: "Barcode", border: OutlineInputBorder()))) ]), SizedBox(height:8), Row(children: [Expanded(child: TextField(controller: lat, decoration: InputDecoration(labelText: "Lat", border: OutlineInputBorder()))), SizedBox(width:8), Expanded(child: TextField(controller: lng, decoration: InputDecoration(labelText: "Lng", border: OutlineInputBorder())))]), SizedBox(height:8), SizedBox(width: double.infinity, height:45, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: (){ setState(()=> inc.insert(0, {"brand":brand,"bar":bar.text,"lat":lat.text,"lng":lng.text,"saps":"SAPS-${DateTime.now().millisecondsSinceEpoch}","time":DateTime.now().toString().substring(0,19)})); }, child: Text("SCAN SUSPECT", style: TextStyle(color: Colors.white)))) ])), Expanded(child: ListView.builder(itemCount: inc.length, itemBuilder: (_,i){ var d=inc[i]; return Card(child: ListTile(title: Text(d['brand']!, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${d['bar']} | ${d['saps']}\n${d['lat']},${d['lng']} | ${d['time']}\nSUSPECT - VERIFICATION REQUIRED", style: TextStyle(fontSize:10)), trailing: Icon(Icons.warning, color: Colors.red))); }))]))); }
}
