import 'package:flutter/material.dart';

void main() => runApp(ScanSafeBoardApp());

class ScanSafeBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

List<String> allBrands = ["COKE","FANTA","SPRITE","PEPSI","STONEY","LUCOZADE","SASKO","ALBANY","BLUE RIBBON","SASKO SAM","KOO","LUCKY STAR","RHODES","ALL GOLD","HUGO","OMO","SUNLIGHT","MAQ","STAYSOFT","HANDY ANDY","CASTLE","BLACK LABEL","HUNTERS","SAVANNA","HEINEKEN","NESTLE","MAGGI","CERELAC","NESCAFE","KITKAT","SIMBA","LAYS","DORITOS","NIK NAKS","CHEETOS","KNORR","ROBERTSONS","RAJAH","BENNY","IMBO","COLGATE","AQUAFRESH","SHIELD","DOVE","VASLINE","SAFARI","CLOVER","PARMALAT","FAIR CAPE","WOOLWORTHS"];
List<Map<String, dynamic>> allDepts = [
  {"code": "CIPC", "name": "CIPC - Companies", "icon": Icons.business, "color": Colors.blue},
  {"code": "HEALTH", "name": "Dept of Health", "icon": Icons.health_and_safety, "color": Colors.teal},
  {"code": "SARS", "name": "SARS Tax", "icon": Icons.receipt_long, "color": Colors.black87},
  {"code": "VAT", "name": "VAT Fraud Unit", "icon": Icons.request_quote, "color": Colors.green},
  {"code": "SAPS", "name": "SAPS - Crime", "icon": Icons.local_police, "color": Colors.indigo},
  {"code": "SABS", "name": "SABS Standards", "icon": Icons.verified, "color": Colors.orange},
  {"code": "NRCS", "name": "NRCS Regulator", "icon": Icons.gavel, "color": Colors.brown},
  {"code": "DAFF", "name": "Agriculture Food Safety", "icon": Icons.agriculture, "color": Colors.green},
  {"code": "DHA", "name": "Home Affairs", "icon": Icons.badge, "color": Colors.purple},
  {"code": "DTIC", "name": "Trade & Industry", "icon": Icons.store, "color": Colors.blueGrey},
  {"code": "NCC", "name": "Consumer Commission", "icon": Icons.support_agent, "color": Colors.red},
  {"code": "SANAS", "name": "SANAS Labs", "icon": Icons.science, "color": Colors.cyan},
  {"code": "ICASA", "name": "ICASA", "icon": Icons.signal_cellular_alt, "color": Colors.amber},
  {"code": "FSCA", "name": "FSCA Finance", "icon": Icons.account_balance, "color": Colors.indigo},
  {"code": "BORDER", "name": "Border Management", "icon": Icons.travel_explore, "color": Colors.deepOrange},
  {"code": "CUSTOMS", "name": "Customs", "icon": Icons.local_shipping, "color": Colors.brown},
  {"code": "MUNICIPAL", "name": "Municipal Health", "icon": Icons.location_city, "color": Colors.teal},
  {"code": "COUNTERFEIT", "name": "Anti-Counterfeit", "icon": Icons.copyright, "color": Colors.red},
  {"code": "BRAND_PROT", "name": "Brand Protection", "icon": Icons.shield, "color": Color(0xFF0A2A5E)},
  {"code": "HAWKS", "name": "HAWKS", "icon": Icons.security, "color": Colors.black},
];
List<Map<String, dynamic>> allScans = [
  {"brand": "COKE", "dept": "HEALTH", "location": "Bethelsdorp", "status": "FAKE", "type": "PERSON", "time": "10:22 AM"},
  {"brand": "SASKO", "dept": "CIPC", "location": "Booysens Park", "status": "EXPIRED", "type": "INSPECTOR", "time": "09:14 AM"},
  {"brand": "KOO", "dept": "SARS", "location": "Motherwell", "status": "VAT FRAUD", "type": "PERSON", "time": "08:30 AM"},
];

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2A5E),
      body: SingleChildScrollView(child: Center(child: Container(
        margin: EdgeInsets.all(16), padding: EdgeInsets.all(20), width: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          // YOUR LOGO HERE!
          Image.asset("assets/logo.png", height: 120, fit: BoxFit.contain),
          SizedBox(height: 10),
          Text("50 BRANDS + 20 DEPTS - CONTRACT READY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 15),
          ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 45)), icon: Icon(Icons.admin_panel_settings), label: Text("BOSS BOARD (YOU) - SEE ALL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>BoardPage(role: "ADMIN", isBrand: false)))),
          Divider(),
          Text("BRAND BOARDS - Give ID: BRAND_001", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          SizedBox(height: 5),
          Wrap(spacing: 6, runSpacing: 6, children: allBrands.map((b) => SizedBox(width: 115, height: 32, child: ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>BoardPage(role: b, isBrand: true))), child: Text(b, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100, foregroundColor: Colors.black, padding: EdgeInsets.all(2))))).toList()),
          Divider(),
          Text("DEPT BOARDS - Give ID: DEPT_001", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          SizedBox(height: 5),
         ...allDepts.map((d) => Container(margin: EdgeInsets.only(bottom: 4), child: ElevatedButton.icon(icon: Icon(d["icon"], size: 14), label: Text("${d["code"]} - ${d["name"]}", style: TextStyle(fontSize: 9)), style: ElevatedButton.styleFrom(backgroundColor: d["color"], foregroundColor: Colors.white, minimumSize: Size(double.infinity, 36), alignment: Alignment.centerLeft), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>BoardPage(role: d["code"], isBrand: false))))).toList(),
        ]),
      )))),
    );
  }
}

class BoardPage extends StatefulWidget {
  final String role; final bool isBrand;
  BoardPage({required this.role, required this.isBrand});
  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = allScans.where((s) {
      if (widget.role == "ADMIN") return true;
      if (widget.isBrand) return s["brand"] == widget.role;
      return s["dept"] == widget.role;
    }).toList();

    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF0A2A5E), title: Row(children: [Image.asset("assets/logo.png", height: 28), SizedBox(width: 8), Text("${widget.role} BOARD - ID: ${widget.role}_001", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]), actions: [Padding(padding: EdgeInsets.all(8), child: CircleAvatar(backgroundColor: Colors.green, radius: 6))]),
      body: Column(children: [
        Container(color: Color(0xFF0D5CFF), padding: EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat("${filtered.length}", "ALERTS"),
          _stat(widget.isBrand? "ONLY ${widget.role}" : widget.role, "FILTERED"),
          _stat("LIVE GPS", "BETHELSDORP"),
          _stat("${widget.role}_001", "YOUR ID"),
        ])),
        Container(height: 110, color: Colors.blue.shade50, child: Stack(alignment: Alignment.center, children: [
          Opacity(opacity: 0.1, child: Image.asset("assets/logo.png", height: 90)),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.map, size: 30, color: Colors.blue.shade300),
            Text("LIVE MAP - ${widget.role} - Bethelsdorp • Motherwell • Booysens Park\nRED = FAKE DETECTED | Auto Brand + Date + Location", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ])
        ])),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) {
          var s = filtered[i];
          return Card(child: ListTile(leading: Image.asset("assets/logo.png", width: 30, height: 30), title: Text("${s["brand"]} | ${s["status"]} | ${s["location"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), subtitle: Text("Auto Alert -> Brand: ${s["brand"]}, Date: ${s["time"]}, Location: ${s["location"]}, Suspected: ${s["status"]}, Dept: ${s["dept"]} | From: ${s["type"]} App", style: TextStyle(fontSize: 8)), trailing: ElevatedButton(onPressed: (){}, child: Text("VIEW", style: TextStyle(fontSize: 7)))));
        }))
      ]),
    );
  }
  Widget _stat(String n, String l) => Column(children: [Text(n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)), Text(l, style: TextStyle(color: Colors.white70, fontSize: 6))]);
}
