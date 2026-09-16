import 'package:flutter/material.dart';

class CEOMissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CEO Mission - ScanSafeAfrica")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Clean Our Country. Stop Fakes. Create Jobs.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("""We face health problems because of the food we eat. We blame brands and forget that we bought FAKE stuff.

ScanSafeAfrica wants to clean our country and stop duplication. Every product needs to be registered and all departments need to do their jobs. SSA wants to partner with them on Scan, Check, Inspection and Law must do its work.

FIGHTING FAKE, CORRUPTION & XENOPHOBIA:
Fake products make our communities sick and divide us. When kids get sick from spaza shops, we blame each other - but the real enemy is fake compliance. We must decrease xenophobia by fighting the real cause: fakes.

BOOST THE ECONOMY:
If you make a product, you must be accountable - meet all requirements and compliances. That way we can have more job opportunities.

PROTECT NEW BRANDS:
I want new brands to trust the system without being scared of being duplicated and sold cheap, then getting blamed and facing lawsuits because it's their name on the product but no profit for them. It's a small percentage real, then a lot of stock outside is duplicate.

We will give every real product a traceable identity so brands can prove what is real.

- Qiniso Mark, Founder & CEO, Bethelsdorp, Eastern Cape""", style: TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
