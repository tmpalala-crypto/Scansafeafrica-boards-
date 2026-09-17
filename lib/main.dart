import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ScanSafeAfricaApp());
}

// ================== SUPER APP WITH 5 TABS ==================
class ScanSafeAfricaApp extends StatefulWidget {
  const ScanSafeAfricaApp({super.key});
  @override
  State<ScanSafeAfricaApp> createState() => _ScanSafeAfricaAppState();
}

class _ScanSafeAfricaAppState extends State<ScanSafeAfricaApp> {
  int _index = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const BrandBoard(),
    const DeptBoard(),
    const MapBoard(),
    const SapsBoard(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QINISO - National Board',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          selectedItemColor: Colors.green[800],
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.factory), label: 'V1 Factory'),
            BottomNavigationBarItem(icon: Icon(Icons.branding_watermark), label: '50 Brands'),
            BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Depts'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map Alert'),
            BottomNavigationBarItem(icon: Icon(Icons.local_police), label: 'SAPS Case'),
          ],
        ),
      ),
    );
  }
}

// ================== TAB 1: HOME + V1 FACTORY (YOUR FIRST IDEA SAVED!) ==================
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset('assets/logo.png', height: 40),
          const SizedBox(width: 8),
          const Text('QINISO - FINAL SYSTEM'),
        ]),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 10),
            const Text('QINISO SCAN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('Anti-Fake SA - Brand Protection', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrFactoryPage())),
              child: const Text('1. QR FACTORY - Generate 100 QRS (V1 SAVED)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandBoard())),
              child: const Text('2. 50 BRANDS BOARD'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeptBoard())),
              child: const Text('3. DEPARTMENTS - Health CIPC SARS'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapBoard())),
              child: const Text('4. MAP - Suspect Location Alert'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55), backgroundColor: Colors.black),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SapsBoard())),
              child: const Text('5. SAPS - Case Proof Evidence', style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ================== QR FACTORY V1 - YOUR ORIGINAL ENGINE ==================
class QrFactoryPage extends StatefulWidget {
  const QrFactoryPage({super.key});
  @override
  State<QrFactoryPage> createState() => _QrFactoryPageState();
}

class _QrFactoryPageState extends State<QrFactoryPage> {
  final productCtrl = TextEditingController(text: 'MANGO JUICE 500ml');
  final batchCtrl = TextEditingController(text: 'B001');
  final branchCtrl = TextEditingController(text: 'SPAR-BETHEL-101');
  final allincCtrl = TextEditingController(text: 'SPAR Bethelsdorp');
  final qtyCtrl = TextEditingController(text: '100');
  final mfgCtrl = TextEditingController(text: '2026-09-01');
  final expCtrl = TextEditingController(text: '2027-03-01');
  List<String> generatedIds = [];
  bool loading = false;

  String genSecret() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ23456789';
    String c = '';
    for (int i = 0; i < 4; i++) {
      c += chars[DateTime.now().microsecondsSinceEpoch % 32];
    }
    final r = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    return 'QIN-${batchCtrl.text}-$c-$r';
  }

  Future<void> generateAndSave() async {
    setState(() => loading = true);
    final qty = int.tryParse(qtyCtrl.text)?? 100;
    final List<String> ids = [];
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < qty; i++) {
      final secret = genSecret();
      final docId = '${batchCtrl.text}_$i';
      ids.add(secret);
      // Save QR
      batch.set(FirebaseFirestore.instance.collection('qrcodes').doc(docId), {
        'secret': secret,
        'product': productCtrl.text,
        'batch': batchCtrl.text,
        'branch': branchCtrl.text,
        'allinc': allincCtrl.text,
        'mfg': mfgCtrl.text,
        'exp': expCtrl.text,
        'brand': 'KOO',
        'created': FieldValue.serverTimestamp(),
        'scans': 0,
        'status': 'active',
      });
      // Auto Alert to Boards - V2 Vision!
      batch.set(FirebaseFirestore.instance.collection('scans').doc(docId), {
        'brand': 'KOO',
        'product': productCtrl.text,
        'shop': allincCtrl.text,
        'branch': branchCtrl.text,
        'gps': '-33.9249, 25.5736',
        'status': 'SUSPECT',
        'departments': ['HEALTH', 'CIPC', 'SAPS'],
        'caseNo': '',
        'date': DateTime.now().toString(),
        'alertSent': true,
        'secret': secret,
      });
    }
    await batch.commit();
    setState(() {
      generatedIds = ids;
      loading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$qty QRs Generated + Auto Alert to Brands + Depts + Map + SAPS!')));
    }
  }

  Future<void> printPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (ctx) => pw.GridView(
        crossAxisCount: 4,
        children: generatedIds.map((id) => pw.Column(children: [
          pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: id, width: 80, height: 80),
          pw.Text(id, style: const pw.TextStyle(fontSize: 6))
        ])).toList(),
      ),
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR FACTORY V1 - SAVED'), backgroundColor: Colors.green[800]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Image.asset('assets/logo.png', height: 60),
          TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
          TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch ID')),
          TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Branch Code')),
          TextField(controller: allincCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
          TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          if (loading) const Center(child: CircularProgressIndicator()) else ElevatedButton(onPressed: generateAndSave, child: const Text('GENERATE 100 + AUTO ALERT ALL BOARDS')),
          const SizedBox(height: 10),
          if (generatedIds.isNotEmpty) ElevatedButton(onPressed: printPdf, child: const Text('PRINT PDF')),
          if (generatedIds.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('${generatedIds.length} Codes Generated + Sent to Brand + Dept + Map + SAPS Boards!')),
        ]),
      ),
    );
  }
}

// ================== TAB 2: 50 BRANDS BOARD ==================
class BrandBoard extends StatefulWidget {
  const BrandBoard({super.key});
  @override
  State<BrandBoard> createState() => _BrandBoardState();
}

class _BrandBoardState extends State<BrandBoard> {
  String selectedBrand = 'KOO';
  final List<String> brands = ['KOO', 'COKE', 'SASKO', 'TIGER', 'LUCKYSTAR', 'SHOPRITE', 'SPAR', 'OMO', 'KNORR', 'SIMBA', 'SUNLIGHT', 'COLGATE', 'NESTLE', 'PEPSI', 'CADBURY'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$selectedBrand BOARD - Private ID'), backgroundColor: Colors.green[800]),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/logo.png', height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedBrand,
              isExpanded: true,
              items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => selectedBrand = v!),
            ),
          ),
          Text('Showing ONLY $selectedBrand alerts', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('scans').where('brand', isEqualTo: selectedBrand).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No $selectedBrand alerts yet - Clean! ✅\nAdd your sheet via Factory'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final d = docs[i].data();
                    return Card(
                      color: d['status'] == 'FAKE'? Colors.red[50] : Colors.yellow[50],
                      child: ListTile(
                        leading: Image.asset('assets/logo.png', width: 40),
                        title: Text('${d['product']} - ${d['status']}'),
                        subtitle: Text('Shop: ${d['shop']}\nGPS: ${d['gps']}\nDate: ${d['date'].toString().substring(0, 16)}\nCase: ${d['caseNo']}'),
                        trailing: const Icon(Icons.visibility),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================== TAB 3: DEPARTMENTS BOARD ==================
class DeptBoard extends StatefulWidget {
  const DeptBoard({super.key});
  @override
  State<DeptBoard> createState() => _DeptBoardState();
}

class _DeptBoardState extends State<DeptBoard> {
  String selectedDept = 'HEALTH';
  final depts = ['HEALTH', 'CIPC', 'SARS', 'VAT', 'SAPS', 'NCC'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$selectedDept DEPARTMENT - Auto Alerts'), backgroundColor: Colors.blue[800]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedDept,
              isExpanded: true,
              items: depts.map((d) => DropdownMenuItem(value: d, child: Text('$d Profile'))).toList(),
              onChanged: (v) => setState(() => selectedDept = v!),
            ),
          ),
          Text('AUTO ALERTS for $selectedDept', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('scans').where('departments', arrayContains: selectedDept).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No alerts for this dept'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final d = docs[i].data();
                    return Card(
                      child: ListTile(
                        title: Text('${d['brand']} - ${d['product']}'),
                        subtitle: Text('Shop: ${d['shop']} | GPS: ${d['gps']} | Status: ${d['status']}'),
                        trailing: ElevatedButton(onPressed: () {}, child: Text('Action $selectedDept')),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================== TAB 4: MAP BOARD ==================
class MapBoard extends StatelessWidget {
  const MapBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LIVE SUSPECT MAP - Follow Up'), backgroundColor: Colors.orange[800]),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('scans').where('status', whereIn: ['FAKE', 'SUSPECT']).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return Column(
            children: [
              Container(
                color: Colors.black,
                height: 180,
                width: double.infinity,
                child: const Center(
                  child: Text('🗺️ LIVE MAP\nRed dots = Fake alerts\nBethelsdorp, PE, JHB, CPT\nAuto alert active!', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${docs.length} Suspect Locations - Auto Alert', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final d = docs[i].data();
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        title: Text('${d['brand']} at ${d['shop']}'),
                        subtitle: Text('GPS: ${d['gps']}\nDate: ${d['date'].toString().substring(0, 16)}\nSAPS Case: ${d['caseNo'] == ''? 'Not yet - Will auto create if chain break' : d['caseNo']}'),
                        trailing: const Icon(Icons.warning, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================== TAB 5: SAPS CASE BOARD ==================
class SapsBoard extends StatelessWidget {
  const SapsBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SAPS - CASE, PROOF, EVIDENCE'), backgroundColor: Colors.black),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Chain Break = Automatic Police Case\nScan Papers + Stock -> If mismatch -> SAPS Case', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('cases').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No cases yet - Scan operation to create case'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final d = docs[i].data();
                    return Card(
                      color: Colors.grey[300],
                      child: ListTile(
                        title: Text('CASE ${d['caseNo']} - ${d['brand']}'),
                        subtitle: Text('Shop: ${d['shop']}\nChain Break: ${d['chainBreak']}\nEvidence: ${d['evidence']}\nStatus: ${d['status']}\nGPS: ${d['gps']}'),
                        trailing: ElevatedButton(onPressed: () {}, child: const Text('Submit to Brand')),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          FirebaseFirestore.instance.collection('cases').add({
            'caseNo': 'SAPS-${DateTime.now().millisecondsSinceEpoch}',
            'brand': 'KOO',
            'shop': 'Spaza Bethelsdorp',
            'chainBreak': true,
            'evidence': 'Papers scanned + Stock scanned - Mismatch! Operation proof attached',
            'status': 'OPEN - Auto alert sent to brand + SAPS',
            'gps': '-33.9249, 25.5736',
            'created': FieldValue.serverTimestamp(),
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
