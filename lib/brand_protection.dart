import 'package:flutter/material.dart';

class BrandProtectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brand Protection"),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user, size: 80, color: Colors.green[800]),
            SizedBox(height: 10),
            Text("For Real Brands. We Protect You.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Scared your brand will be duplicated and sold cheap? We got you. Register once, get protected forever.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            TextField(decoration: InputDecoration(labelText: "Brand Name", border: OutlineInputBorder())),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: "Barcode / Product Code", border: OutlineInputBorder())),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: "Compliance Certificate Number (SABS, Dept Health)", border: OutlineInputBorder())),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              color: Colors.green[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What You Get:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("✓ Protected QR Code that cannot be duplicated\n✓ Traceable ID for every batch\n✓ Proof in court - if fake makes people sick, you can prove it's not yours\n✓ Customer can Scan & Verify it's REAL"),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green[800]),
              onPressed: () {},
              child: Text("REGISTER MY PRODUCT - BE SAFE", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(height: 15),
            Center(child: Text("Partners: Health Dept | SAPS | SARS | Trade & Inspection | SSA Scan Check", style: TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
