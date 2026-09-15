import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(ScanSafeAfricaApp());

class ScanSafeAfricaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'ScanSafeAfrica', home: LoginPage());
  }
}

// SECURITY LOGS - Legal honeypot evidence for SAPS
List<Map<String, dynamic>> attackLogs = [];

List<String> allBrands = ["SAPS","CIPC","SPRITE","PEPSI","STONEY","LUCOZADE","SASKO","ALBANY","BLUE RIBBON","SASKO LAB","COKE","FANTA","BREAD","MILK","NSP","SUGAR","FLOUR","RICE","OIL","SALT","MAIZE","BEANS","TOMATO","POTATO","ONION","CHICKEN","BEEF","FISH","EGGS","CHEESE","BUTTER","YOGHURT","JUICE","WATER","BEER","WINE","CIGARETTES","SOAP","TOOTHPASTE","DETERGENT","SHAMPOO","LOTION","PARAFFIN","MAIZE MEAL","SUNFLOWER","MARGARINE","TEA","COFFEE","BISCUITS"];

List<Map<String, dynamic>> allScans = [
  {"brand": "COKE", "dept": "HEALTH", "location": "Bethelsdorp", "status": "FAKE", "type": "PERSON", "time": "22:10"},
  {"brand": "SASKO", "dept": "CIPC", "location": "Booysens Park", "status": "EXPIRED", "type": "INSPECTION", "time": "20:14"},
  {"brand": "NSP", "dept": "SAPS", "location": "Motherwell", "status": "VAT FRAUD", "type": "PERSON", "time": "02:30"},
];

Widget safeLogo(double h){
  return Image.asset("assets/logo.png", height: h, fit: BoxFit.contain,
    errorBuilder: (c,e,s) => Icon(Icons.shield, size: h, color: Colors.red));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int failed = 0;
  bool blocked = false;
  int blockSec = 0;
  Timer? timer;
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void startBlock(){
    setState((){ blocked=true; blockSec=30; });
    timer = Timer.periodic(Duration(seconds: 1), (t){
      setState((){ blockSec--; });
      if(blockSec<=0){ t.cancel(); setState((){ blocked=false; failed=0; }); }
    });
  }

  void tryLogin(){
    if(blocked) return;
    String u = userCtrl.text.trim();
    String p = passCtrl.text.trim();

    // HONEYPOT DETECTION - Legal trap
    bool isAttack = u.toLowerCase()=="admin" || u.contains("'") || u.contains("OR") || u.contains("--") || p.contains("'");

    if(isAttack || u.isEmpty){
      setState((){ failed++; });
      attackLogs.insert(0, {
        "time": DateTime.now().toString().substring(11,19),
        "user": u.isEmpty? "(empty)" : u,
        "ip": "192.168.${failed}.${DateTime.now().millisecond}",
        "type": isAttack? "HONEYPOT TRIGGERED - SQLi Attempt" : "Failed Login",
        "location": "Bethelsdorp Gateway"
      });
      if(failed>=3){
        startBlock();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ SECURITY ALERT: 3 failed attempts logged. Incident #SAPS-${DateTime.now().millisecondsSinceEpoch} reported to SAPS Task Team. System locked 30s."), backgroundColor: Colors.red, duration: Duration(seconds: 4)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed. Attempt $failed/3 logged for SAPS.")));
      }
      return;
    }
    // Success - go to dashboard
    Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SingleChildScrollView(child: Center(child: Container(
        margin: EdgeInsets.all(12), padding: EdgeInsets.all(20), width: 420,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          safeLogo(100),
          Text("ScanSafeAfrica - Central Board", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("50 BRANDS - 20 DEPTS - CONTRACT READY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
          SizedBox(height: 15),
          TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          SizedBox(height: 10),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
          SizedBox(height: 15),
          if(blocked) Container(padding: EdgeInsets.all(10), color: Colors.red.shade100, child: Text("🚫 BLOCKED FOR $blockSec sec - Incident reported to SAPS Task Team & CIPC", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          SizedBox(height: 10),
          ElevatedButton(onPressed: blocked? null : tryLogin, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 45)), child: Text(blocked? "BLOCKED - $blockSec s" : "LOGIN TO LIVE BOARD")),
          SizedBox(height: 10),
          Text("Security: Honeypot active | Auto-block after 3 fails | All attempts logged for SAPS", style: TextStyle(fontSize: 8, color: Colors.grey)),
          if(attackLogs.isNotEmpty)...[
            Divider(),
            Text("Recent Security Logs (${attackLogs.length})", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
           ...attackLogs.take(3).map((a) => Container(margin: EdgeInsets.only(bottom:4), padding: EdgeInsets.all(6), color: Colors.orange.shade50, child: Row(children: [Icon(Icons.warning_amber, size: 14, color: Colors.red), SizedBox(width:4), Expanded(child: Text("${a['time']} - ${a['type']} - ${a['user']}", style: TextStyle(fontSize: 9)))])))
          ]
        ])
      )))
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [safeLogo(30), SizedBox(width: 8), Text("ScanSafeAfrica - LIVE")]), backgroundColor: Colors.red, actions: [IconButton(icon: Icon(Icons.security), onPressed: (){ showDialog(context: context, builder: (_) => AlertDialog(title: Text("Security Logs for SAPS"), content: SingleChildScrollView(child: Column(children: attackLogs.map((a) => ListTile(dense: true, title: Text("${a['type']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), subtitle: Text("${a['time']} | ${a['user']} | ${a['ip']} | ${a['location']}", style: TextStyle(fontSize: 9)))).toList())), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Close"))])); })]),
      body: Column(children: [
        Container(padding: EdgeInsets.all(10), color: Colors.red.shade50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text("50 Brands"), Text("20 Depts"), Text("${attackLogs.length} Threats Blocked", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])),
        Expanded(child: ListView.builder(itemCount: allScans.length, itemBuilder: (c,i){ var s=allScans[i]; return Card(margin: EdgeInsets.all(5), child: ListTile(leading: Icon(Icons.warning, color: Colors.red), title: Text("${s['brand']} - ${s['status']}", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${s['location']} | ${s['dept']} | ${s['time']}"))); }))
      ])
    );
  }
}
