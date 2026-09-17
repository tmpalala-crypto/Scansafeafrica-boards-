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

class ScanSafeAfricaApp extends StatelessWidget {
  const ScanSafeAfricaApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'QINISO Factory', theme: ThemeData(primarySwatch: Colors.green), home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('QINISO - FINAL SYSTEM'), backgroundColor: Colors.green[800]),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const BrandProtectionPage())), child: const Text('1. BRAND - Single QR')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const QrFactoryPage())), style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('2. QR FACTORY - Generate 100 QRs + PDF + Spreadsheet', style: TextStyle(color: Colors.white))),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const PplScanPage())), child: const Text('3. CUSTOMER - Just Checking')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CashierPage())), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('4. CASHIER TILL - Confirm Payment (BOSS)')),
      ])),
    );
  }
}

// ============ FACTORY PAGE - GENERATE 100 QRS + PDF ============
class QrFactoryPage extends StatefulWidget { const QrFactoryPage({super.key}); @override State<QrFactoryPage> createState() => _QrFactoryPageState(); }

class _QrFactoryPageState extends State<QrFactoryPage> {
  final productCtrl = TextEditingController(text: 'MANGO JUICE 500ml');
  final batchCtrl = TextEditingController(text: 'B001');
  final branchCtrl = TextEditingController(text: 'SPAR-BETHEL-101');
  final allocCtrl = TextEditingController(text: 'SPAR Bethelsdorp');
  final qtyCtrl = TextEditingController(text: '100');
  final mfgCtrl = TextEditingController(text: '2026-09-01');
  final expCtrl = TextEditingController(text: '2027-03-01');
  List<String> generatedIds = [];
  bool loading = false;

  String genSecret() {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String c = ''; for(int i=0;i<4;i++){ c+= chars[DateTime.now().microsecondsSinceEpoch % 32]; }
    String c2 = ''; for(int i=0;i<4;i++){ c2+= chars[(DateTime.now().millisecondsSinceEpoch+i*3) % 32]; }
    final r = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    return 'QIN-${batchCtrl.text}-$c-$c2-$r';
  }

  Future<void> generateFactory() async {
    setState(()=> loading = true);
    final qty = int.tryParse(qtyCtrl.text)?? 100;
    generatedIds = [];
    final batch = FirebaseFirestore.instance.batch();

    for(int i=0;i<qty;i++){
      final secret = '${genSecret()}-${i.toString().padLeft(3,'0')}';
      generatedIds.add(secret);
      final doc = FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret);
      batch.set(doc, {
        'secretId': secret,
        'brand': 'QINISO',
        'product': productCtrl.text,
        'batch': batchCtrl.text,
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
      await Future.delayed(const Duration(milliseconds: 2));
    }

    final stockRef = FirebaseFirestore.instance.collection('branch_stock').doc('${branchCtrl.text}_${batchCtrl.text}');
    batch.set(stockRef, {
      'branchNo': branchCtrl.text,
      'batch': batchCtrl.text,
      'product': productCtrl.text,
      'mfgDate': mfgCtrl.text,
      'expDate': expCtrl.text,
      'totalAllocated': qty,
      'totalSold': 0,
      'remaining': qty,
      'status': 'IN STOCK',
      'allocatedTo': allocCtrl.text,
      'created': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    setState(()=> loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Generated $qty QRs + Saved to Firebase! Now print PDF')));
  }

  Future<void> printPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (ctx){
      return [
        pw.Header(level: 0, child: pw.Text('QINISO - ${branchCtrl.text} - Batch ${batchCtrl.text} - ${generatedIds.length} QRs - MFG ${mfgCtrl.text} - INVISIBLE SECRET MODE')),
        pw.Wrap(children: generatedIds.map((id){
          return pw.Container(width: 120, height: 150, margin: const pw.EdgeInsets.all(5), padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Column(children: [
            pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: id, width: 100, height: 100),
            pw.SizedBox(height: 4),
            pw.Text(id, style: const pw.TextStyle(fontSize: 5)),
            pw.Text(branchCtrl.text, style: const pw.TextStyle(fontSize: 5)),
          ]));
        }).toList())
      ];
    }));
    await Printing.layoutPdf(onLayout: (f)=> pdf.save());
  }

  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('QR FACTORY - 100 Print'), backgroundColor: Colors.black),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(padding: const EdgeInsets.all(8), color: Colors.yellow[100], child: const Text('Factory creates 100 secret IDs, saves to Firebase, creates branch_stock counter, and PDF ready to print. Give spreadsheet to shop to sign - then you are NOT responsible for missing!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product')),
        TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch')),
        TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Branch No (e.g SPAR-BETHEL-101)')),
        TextField(controller: allocCtrl, decoration: const InputDecoration(labelText: 'Allocated To')),
        Row(children: [Expanded(child: TextField(controller: mfgCtrl, decoration: const InputDecoration(labelText: 'MFG'))), const SizedBox(width:8), Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'EXP'))), const SizedBox(width:8), Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Qty')))]),
        const SizedBox(height:10),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: loading? null : generateFactory, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text(loading? 'Generating...' : 'GENERATE ${qtyCtrl.text} SECRET QRS + SAVE TO FIREBASE', style: const TextStyle(color: Colors.white)))),
        const SizedBox(height:10),
        if(generatedIds.isNotEmpty) SizedBox(width: double.infinity, child: ElevatedButton(onPressed: printPdf, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('PRINT PDF - 100 QR SHEET FOR PRINTER'))),
        const SizedBox(height:10),
        if(generatedIds.isNotEmpty) Text('Generated ${generatedIds.length} IDs. First: ${generatedIds.first} Last: ${generatedIds.last}', style: const TextStyle(fontSize: 10)),
        const SizedBox(height:10),
        if(generatedIds.isNotEmpty) SizedBox(height: 300, child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: generatedIds.take(12).length, itemBuilder: (c,i){ return Card(child: Column(children: [QrImageView(data: generatedIds[i], size: 80), Text(generatedIds[i], style: const TextStyle(fontSize: 5))])) ;})),
      ])),
    );
  }
}

// ============ OTHER PAGES (BRAND SINGLE, CUSTOMER, CASHIER) ============
class BrandProtectionPage extends StatefulWidget { const BrandProtectionPage({super.key}); @override State<BrandProtectionPage> createState() => _BrandProtectionPageState(); }
class _BrandProtectionPageState extends State<BrandProtectionPage> {
  final brandCtrl = TextEditingController(text: 'QINISO'); final productCtrl = TextEditingController(text: 'MANGO JUICE 500ml'); final batchCtrl = TextEditingController(text: 'B001'); final branchCtrl = TextEditingController(text: 'SPAR-BETHEL-101'); final allocCtrl = TextEditingController(text: 'SPAR Bethelsdorp'); final mfgCtrl = TextEditingController(text: '2026-09-01'); final expCtrl = TextEditingController(text: '2027-03-01'); String? secretId;
  String genSecret(){ final chars='ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; String c=''; for(int i=0;i<4;i++){ c+= chars[DateTime.now().microsecondsSinceEpoch % 28]; } String c2=''; for(int i=0;i<4;i++){ c2+= chars[(DateTime.now().millisecondsSinceEpoch+i) % 28]; } final r=DateTime.now().millisecondsSinceEpoch % 9000 + 1000; return 'QIN-${batchCtrl.text}-$c-$c2-$r';}
  Future<void> generate() async { final secret=genSecret(); setState(()=> secretId=secret); await FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret).set({'secretId': secret,'brand': brandCtrl.text,'product': productCtrl.text,'batch': batchCtrl.text,'branchNo': branchCtrl.text,'allocatedTo': allocCtrl.text,'mfgDate': mfgCtrl.text,'expDate': expCtrl.text,'qr_data': secret,'status': 'UNSOLD','scanCount': 0,'shelfChecks': 0,'created': FieldValue.serverTimestamp(),});}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('QINISO - Single'), backgroundColor: Colors.black), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Brand')), TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product')), TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch')), TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Branch No')), TextField(controller: allocCtrl, decoration: const InputDecoration(labelText: 'Allocated To')), Row(children: [Expanded(child: TextField(controller: mfgCtrl, decoration: const InputDecoration(labelText: 'MFG'))), const SizedBox(width:8), Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'EXP')))]), const SizedBox(height:10), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: generate, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('GENERATE SECRET QR', style: TextStyle(color: Colors.white)))), const SizedBox(height:20), if(secretId!=null)...[Container(padding: const EdgeInsets.all(10), color: Colors.black, child: Text(secretId!, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))), const SizedBox(height:10), QrImageView(data: secretId!, version: QrVersions.auto, size: 220)]])),);}}

class PplScanPage extends StatefulWidget { const PplScanPage({super.key}); @override State<PplScanPage> createState() => _PplScanPageState(); }
class _PplScanPageState extends State<PplScanPage> { String? result; bool verified=false; Map<String,dynamic>? data; final scanner=MobileScannerController();
  Future<void> checkSecret(String secret) async { final doc=await FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret).get(); if(!doc.exists){ setState(()=> result='🚨 SUSPECT - UNKNOWN SECRET'); return;} final d=doc.data()!; final exp=DateTime.tryParse(d['expDate']?? ''); if(exp!=null && DateTime.now().isAfter(exp)){ setState(()=> result='🚨 SUSPECT - EXPIRED MFG ${d['mfgDate']} EXP ${d['expDate']}'); return;} if(d['status']=='SOLD'){ setState(()=> result='🚨 SUSPECT - RECYCLED - Already SOLD at ${d['soldLocation']}'); data=d; return;} await FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret).update({'shelfChecks': FieldValue.increment(1)}); final stock=await FirebaseFirestore.instance.collection('branch_stock').doc('${d['branchNo']}_${d['batch']}').get(); final remaining=stock.data()?['remaining']?? '?'; setState(()=> verified=true); data=d; result='✅ VERIFIED - Real ${d['brand']} for ${d['branchNo']} MFG ${d['mfgDate']} EXP ${d['expDate']} | $remaining left. Take to till.';}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('Customer - Just Checking')), body: Column(children: [Expanded(child: MobileScanner(controller: scanner, onDetect: (cap){ final code=cap.barcodes.first.rawValue; if(code!=null){ scanner.stop(); checkSecret(code); }})), Container(padding: const EdgeInsets.all(16), color: verified? Colors.green[50]: Colors.red[50], child: Text(result?? 'Scan QINISO secret QR', style: const TextStyle(fontWeight: FontWeight.bold))), if(data!=null) Padding(padding: const EdgeInsets.all(8), child: Text('Branch: ${data!['branchNo']} | Batch ${data!['batch']} | Status ${data!['status']}')), ElevatedButton(onPressed: ()=> scanner.start(), child: const Text('Scan Again')), const SizedBox(height:10)]));}}

class CashierPage extends StatefulWidget { const CashierPage({super.key}); @override State<CashierPage> createState() => _CashierPageState(); }
class _CashierPageState extends State<CashierPage> { String? result; final scanner=MobileScannerController(); String? _pendingSecret; Map<String,dynamic>? _pendingData;
  Future<void> tillScan(String secret) async { final docRef=FirebaseFirestore.instance.collection('protected_brands_secret').doc(secret); final doc=await docRef.get(); if(!doc.exists){ setState(()=> result='🚨 SUSPECT - Not in system'); return;} final d=doc.data()!; if(d['status']=='SOLD'){ setState(()=> result='⚠️ Already SOLD - Cannot sell again. Return to shelf!'); return;} setState(()=> result='Ready to sell: ${d['product']} Batch ${d['batch']} Branch ${d['branchNo']} - Confirm payment?'); _pendingSecret=secret; _pendingData=d;}
  Future<void> confirmPayment() async { if(_pendingSecret==null || _pendingData==null) return; final d=_pendingData!; await FirebaseFirestore.instance.collection('protected_brands_secret').doc(_pendingSecret!).update({'status': 'SOLD', 'soldAt': FieldValue.serverTimestamp(), 'soldLocation': d['branchNo'], 'soldBy': 'TILL-01'}); final stockRef=FirebaseFirestore.instance.collection('branch_stock').doc('${d['branchNo']}_${d['batch']}'); await stockRef.update({'totalSold': FieldValue.increment(1), 'remaining': FieldValue.increment(-1), 'lastSale': FieldValue.serverTimestamp()}); final stock=await stockRef.get(); final rem=stock.data()?['remaining']?? 0; final status=rem <=0? 'SOLD OUT - Reorder Batch ${d['batch']}' : '$rem left'; setState(()=> result='✅ SALE CONFIRMED - ${d['product']} marked SOLD. Branch ${d['branchNo']} now $status'); _pendingSecret=null;}
  Future<void> returnToShelf() async { if(_pendingSecret==null) return; await FirebaseFirestore.instance.collection('protected_brands_secret').doc(_pendingSecret!).update({'abandonedAtTillCount': FieldValue.increment(1)}); setState(()=> result='↩️ RETURNED TO SHELF - Payment failed/card declined/short money. Stock NOT decreased. Bottle back on shelf.'); _pendingSecret=null;}
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('CASHIER TILL - Boss'), backgroundColor: Colors.black), body: Column(children: [Expanded(child: MobileScanner(controller: scanner, onDetect: (cap){ final code=cap.barcodes.first.rawValue; if(code!=null){ scanner.stop(); tillScan(code); }})), Container(padding: const EdgeInsets.all(12), color: Colors.yellow[100], child: Text(result?? 'Cashier: Scan QINISO at till', style: const TextStyle(fontWeight: FontWeight.bold))), if(_pendingSecret!=null) Row(children: [Expanded(child: ElevatedButton(onPressed: confirmPayment, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('✅ CONFIRM PAYMENT'))), const SizedBox(width:8), Expanded(child: ElevatedButton(onPressed: returnToShelf, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('↩️ RETURN TO SHELF')))]), ElevatedButton(onPressed: ()=> scanner.start(), child: const Text('Scan Next')), const SizedBox(height:10)]));}}
