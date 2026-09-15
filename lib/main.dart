import 'package:flutter/material.dart';

void main() => runApp(ScanSafeAfricaApp());

class ScanSafeAfricaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

List<String> allBrands = ["SAPS","CIPC","SPIRTE","PEPSI","STOREY","LUCOZADE","SASKO","ALBANY","BLUE RIBBON","SASKO LAB","C..."];
List<Map<String, dynamic>> allDepts = [
  {"code": "CIPC", "name": "CIPC - Companies", "icon": Icons.business, "color": Colors.blue},
  {"code": "HEALTH", "name": "Dept of Health", "icon": Icons.health_and_safety, "color": Colors.teal},
  {"code": "SAPS", "name": "SAPS Task Team", "icon": Icons.local_police, "color": Colors.blueGrey},
  {"code": "VAT", "name": "VAT Fraud Unit", "icon": Icons.request_quote, "color": Colors.green},
  {"code": "SARS", "name": "SARS - Crime", "icon": Icons.account_balance, "color": Colors.indigo},
  {"code": "MUNICIPAL", "name": "MESS Standards", "icon": Icons.verified, "color": Colors.orange},
  {"code": "NCRS", "name": "NCRS Regulator", "icon": Icons.gavel, "color": Colors.brown},
  {"code": "DAFF", "name": "Agriculture Food Safety", "icon": Icons.agriculture, "color": Colors.green},
  {"code": "SABS", "name": "SABS - Standards", "icon": Icons.shield, "color": Colors.blue},
  {"code": "DTIC", "name": "Trade & Industry", "icon": Icons.store, "color": Colors.blueGrey},
  {"code": "NCC", "name": "Consumer Commission", "icon": Icons.support_agent, "color": Colors.red},
  {"code": "NRCS", "name": "NRCS Regulator", "icon": Icons.security, "color": Colors.deepPurple},
  {"code": "ICASA", "name": "ICASA", "icon": Icons.signal_cellular_alt, "color": Colors.amber},
  {"code": "FSCA", "name": "FSCA Finance", "icon": Icons.account_balance, "color": Colors.indigo},
  {"code": "CUSTOMS", "name": "Border Management", "icon": Icons.travel_explore, "color": Colors.deepOrange},
  {"code": "TRADE", "name": "Customs Border", "icon": Icons.local_shipping, "color": Colors.brown},
  {"code": "MUNICIPAL", "name": "Municipal Health", "icon": Icons.location_city, "color": Colors.teal},
  {"code": "COUNTERFEIT", "name": "Anti-Counterfeit", "icon": Icons.copyright, "color": Colors.red},
  {"code": "BRAND", "name": "Brand Protection", "icon": Icons.shield, "color": Colors.blue},
  {"code": "NPA", "name": "NPA Crime", "icon": Icons.security, "color": Colors.black},
];

List<Map<String, dynamic>> allScans = [
  {"brand": "COKE", "dept": "HEALTH", "location": "Bethelsdorp", "status": "FAKE", "type": "PERSON", "time": "TO 22 AP"},
  {"brand": "SASKO", "dept": "CIPC", "location": "Booysens Park", "status": "EXPIRED", "type": "INSPECTION", "time": "20:14"},
  {"brand": "NSP", "dept": "SAPS", "location": "Motherwell", "status": "VAT FRAUD", "type": "PERSON", "time": "02:30 AM"},
];

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SingleChildScrollView(child: Center(child: Container(
        margin: EdgeInsets.all(10), padding: EdgeInsets.all(20), width: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          // YOUR LOGO HERE - FIXED PATH
          Image.asset("assets/logo.png", height: 120, fit: BoxFit.contain),
          SizedBox(height: 10),
          Text("50 BRANDS - 20 DEPTS - CONTRACT READY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
          SizedBox(height: 10),
          ElevatedButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard())); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: Text("LOGIN TO ScanSafeAfrica"))
        ])
      )))
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [Image.asset("assets/logo.png", height: 30), SizedBox(width: 10), Text("ScanSafeAfrica - LIVE")]), backgroundColor: Colors.red),
      body: ListView.builder(
        itemCount: allScans.length,
        itemBuilder: (c,i){ var s=allScans[i]; return ListTile(leading: Icon(Icons.warning, color: Colors.red), title: Text("${s['brand']} - ${s['status']}"), subtitle: Text("${s['location']} | ${s['dept']} | ${s['time']}")); }
      )
    );
  }
}
