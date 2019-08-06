library gpx.test.writer_test;

import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write gpx with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply routes', () async {
    final gpx = createGPXWithRte();
    final xml = await File('test/assets/rte.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply tracks', () async {
    final gpx = createGPXWithTrk();
    final xml = await File('test/assets/trk.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex gpx', () async {
    final gpx = createComplexGPX();
    final xml = await File('test/assets/complex.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });
}
