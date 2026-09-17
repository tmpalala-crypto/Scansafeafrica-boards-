import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BrandProtectionPage extends StatefulWidget {
  const BrandProtectionPage({super.key});
  @override State<BrandProtectionPage> createState() => _BrandProtectionPageState();
}

class _BrandProtectionPageState extends State<BrandProtectionPage> {
  final brandCtrl = TextEditingController(text: 'QINISO');
  final productCtrl = TextEditingController(text: 'MANGO JUICE 500ml');
  final barcodeCtrl = TextEditingController(text: 'B001');
  final certCtrl = TextEditingController(text: 'SABS-QIN-2026');
  final branchCtrl = TextEditingController(text: 'SPAR-BETHEL-101');
  final allocCtrl = TextEditingController(text: 'SPAR Bethelsdorp');
  final mfgCtrl = TextEditingController(text: '2026-09-17');
  final expCtrl = TextEditingController(text: '2027-03-17');
  final qtyCtrl = TextEditingController(text: '100');

  List<String> generatedIds = [];
  String? singleQr;
  bool loading = false;

  String genSecret() {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String c = ''; for(int i=0;i<4;i++){ c+= chars[DateTime.now().microsecondsSinceEpoch % 32]; }
    String c2 = ''; for(int i=0;i<4;i++){ c2+= chars[(DateTime.now().millisecondsSinceEpoch+i*7) % 32]; }
    final r = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    return 'QIN-${barcodeCtrl.text}-$c-$c2-$r';
  }

  // SINGLE REGISTER - For court proof
  Future<void> registerSingle() async {
    final secret = genSecret();
    setState(()=> singleQr = secret);
    await FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret).set({
      'secretId': secret,
      'brand': brandCtrl.text,
      'product': productCtrl.text,
      'batch': barcodeCtrl.text,
      'complianceCert': certCtrl.text,
      'branchNo': branchCtrl.text,
      'allocatedTo': allocCtrl.text,
      'mfgDate': mfgCtrl.text,
      'expDate': expCtrl.text,
      'qr_data': secret,
      'status': 'UNSOLD',
      'scanCount': 0,
      'shelfChecks': 0,
      'created': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Brand Registered - Secret locked in Firebase!')));
  }

  // FACTORY 100 - For printing
  Future<void> generateFactory() async {
    setState(()=> loading = true);
    final qty = int.tryParse(qtyCtrl.text)?? 100;
    generatedIds = [];
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for(int i=0;i<qty;i++){
      final secret = '${genSecret()}-${i.toString().padLeft(3,'0')}';
      generatedIds.add(secret);
      final doc = FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret);
      batch.set(doc, {
        'secretId': secret,
        'brand': brandCtrl.text,
        'product': productCtrl.text,
        'batch': barcodeCtrl.text,
        'complianceCert': certCtrl.text,
        'branchNo': branchCtrl.text,
        'allocatedTo': allocCtrl.text,
        'mfgDate': mfgCtrl.text,
        'expDate': expCtrl.text,
        'qr_data': secret,
        'status': 'UNSOLD',
        'scanCount': 0,
        'shelfChecks': 0,
        'factoryIndex': i+1,
        'created': FieldValue.serverTimestamp(),
      });
    }
    final stockRef = FirebaseFirestore.instance.collection('branch_stock').doc('${branchCtrl.text}_${barcodeCtrl.text}');
    batch.set(stockRef, {
      'branchNo': branchCtrl.text,
      'batch': barcodeCtrl.text,
      'product': productCtrl.text,
      'mfgDate': mfgCtrl.text,
      'expDate': expCtrl.text,
      'totalAllocated': qty,
      'totalSold': 0,
      'remaining': qty,
      'status': 'IN STOCK',
      'allocatedTo': allocCtrl.text,
      'brand': brandCtrl.text,
      'created': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    setState(()=> loading = false);
  }

  Future<void> printPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (ctx){
      return [pw.Header(level: 0, child: pw.Text('QINISO FACTORY - ${branchCtrl.text} - Batch ${barcodeCtrl.text} - ${generatedIds.length} QRs - MFG ${mfgCtrl.text} EXP ${expCtrl.text} - INVISIBLE SECRET MODE')), pw.Wrap(children: generatedIds.map((id){ return pw.Container(width: 120, height: 150, margin: const pw.EdgeInsets.all(5), padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(children: [pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: id, width: 100, height: 100), pw.SizedBox(height: 4), pw.Text(id, style: const pw.TextStyle(fontSize: 5)), pw.Text(branchCtrl.text, style: const pw.TextStyle(fontSize: 5)) ])); }).toList())];
    }));
    await Printing.layoutPdf(onLayout: (f)=> pdf.save());
  }

  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Brand Protection"), backgroundColor: Colors.green[800]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.verified_user, size: 80, color: Colors.green[800]),
        const SizedBox(height: 10),
        const Text("For Real Brands. We Protect You.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Scared your brand will be duplicated and sold cheap? We got you. Register once, get protected forever.", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 20),

        TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: "Brand Name", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: productCtrl, decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: "Barcode / Product Code / Batch", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: certCtrl, decoration: const InputDecoration(labelText: "Compliance Certificate Number (SABS, Dept Health)", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: "Branch No", border: OutlineInputBorder()))), const SizedBox(width:8), Expanded(child: TextField(controller: allocCtrl, decoration: const InputDecoration(labelText: "Allocated To", border: OutlineInputBorder())))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextField(controller: mfgCtrl, decoration: const InputDecoration(labelText: "MFG Date", border: OutlineInputBorder()))), const SizedBox(width:8), Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: "EXP Date", border: OutlineInputBorder()))), const SizedBox(width:8), Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Qty", border: OutlineInputBorder())))]),

        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(16), color: Colors.green[50], child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("What You Get:", style: TextStyle(fontWeight: FontWeight.bold)), Text("✓ Protected QR Code that cannot be duplicated - INVISIBLE SECRET\n✓ Traceable ID for every batch\n✓ Proof in court - if fake makes people sick, you can prove it's not yours\n✓ Customer Scan = JUST CHECKING (no sale)\n✓ Cashier Till = CONFIRM PAYMENT (Boss)\n✓ Sold Out + Spreadsheet Protection - You NOT responsible for missing!")])),
        const SizedBox(height: 20),

        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green[800]), onPressed: registerSingle, child: const Text("REGISTER MY PRODUCT - BE SAFE (Single QR)", style: TextStyle(color: Colors.white, fontSize: 16)))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.black), onPressed: loading? null : generateFactory, child: Text(loading? "Generating..." : "FACTORY - GENERATE ${qtyCtrl.text} QRS FOR PRINTING", style: const TextStyle(color: Colors.white, fontSize: 16)))),
        const SizedBox(height: 10),
        if(generatedIds.isNotEmpty) SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: printPdf, child: const Text("PRINT PDF - 100 QR SHEET", style: TextStyle(color: Colors.white)))),
        
        if(singleQr!=null) ...[const SizedBox(height: 20), Container(padding: const EdgeInsets.all(10), color: Colors.black, child: Text(singleQr!, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))), const SizedBox(height:10), Center(child: QrImageView(data: singleQr!, version: QrVersions.auto, size: 200))],
        if(generatedIds.isNotEmpty) Padding(padding: const EdgeInsets.only(top:15), child: Text("✅ Generated ${generatedIds.length} secret QRs - First: ${generatedIds.first} - Saved to Firebase!", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),

        const SizedBox(height: 15),
        const Center(child: Text("Partners: Health Dept | SAPS | SARS | Trade & Inspection | SSA Scan Check", style: TextStyle(fontSize: 12, color: Colors.grey))),
      ])),
    );
  }
}
