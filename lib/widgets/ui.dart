import 'package:flutter/material.dart';

InputDecoration appInput(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );

Widget gap(double h) => SizedBox(height: h);
