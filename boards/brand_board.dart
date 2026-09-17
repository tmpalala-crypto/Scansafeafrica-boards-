import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandBoard extends StatefulWidget {
  const BrandBoard({super.key});
  @override
  State<BrandBoard> createState() => _BrandBoardState();
}

class _BrandBoardState extends State<BrandBoard> {
  String selectedBrand = 'KOO';
  final List<String> brands = ['KOO','COKE','SASKO','TIGER','LUCKYSTAR','SHOPRITE','SPAR','OMO','KNORR','SIMBA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$selectedBrand BOARD'), backgroundColor: Colors.green[800]),
      body: Column(
        children: [
          Image.asset('assets/logo.png', height: 50),
          DropdownButton<String>(
            value: selectedBrand,
            isExpanded: true,
            items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() => selectedBrand = v!),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('scans').where('brand', isEqualTo: selectedBrand).snapshots(),
              builder: (context, snap) {
                if(!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if(docs.isEmpty) return Center(child: Text('No $selectedBrand alerts - Clean!'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (c,i){
                    final d = docs[i].data();
                    return Card(child: ListTile(title: Text('${d['product']}'), subtitle: Text('Shop: ${d['shop']} GPS: ${d['gps']}')));
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
