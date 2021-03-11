import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

final areasPolygonsProvider = FutureProvider.autoDispose<Set<Polygon>>(
  (ref) async {
    var data = await rootBundle.loadString("assets/city.json");
    List polygons = await json.decode(data);
    return polygons.map((e) {
      List<LatLng> list =
          e["points"].map<LatLng>((s) => LatLng(s[1], s[0])).toList();
      return Polygon(
          polygonId: PolygonId(e["id"]),
          points: list,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeWidth: 2);
    }).toSet();
  },
);
