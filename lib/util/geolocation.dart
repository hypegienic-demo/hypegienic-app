import 'dart:math' as math;
import 'package:mapbox_gl/mapbox_gl.dart';

double getRadianFromDegree(double degree) {
  return degree * (math.pi / 180);
}

double getDistanceBetweenPoints(LatLng pointA, LatLng pointB) {
  final radius = 6378.8; // radius of Earth in kilometer
  final latitudeDistance = getRadianFromDegree(pointB.latitude - pointA.latitude);
  final longitudeDistance = getRadianFromDegree(pointB.longitude - pointA.longitude);
  final a = math.pow(math.sin(latitudeDistance / 2), 2) +
    math.cos(getRadianFromDegree(pointB.latitude)) * math.cos(getRadianFromDegree(pointA.latitude)) *
    math.pow(math.sin(longitudeDistance / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return radius * c;
}