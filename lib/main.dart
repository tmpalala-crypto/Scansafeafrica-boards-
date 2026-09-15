import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "ScanSafeAfrica GREEN!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          )
        )
      )
    )
  );
}
