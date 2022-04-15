library gpx.test.gpx_writer_test;

import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write empty gpx', () async {
    final gpx = createMinimalGPX();
    final xml = await File('test/assets/minimal.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write empty gpx with metadata', () async {
    final gpx = createMinimalMetadataGPX();
    final xml =
        await File('test/assets/minimal_with_metadata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt_nocdata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt_nocdata.gpx').readAsString();

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

  test('write metadata gpx', () async {
    final gpx = createMetadataGPX();
    final xml = await File('test/assets/metadata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write FixType', () async {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(lat: 1, lon: 1, fix: FixType.fix_2d),
      Wpt(lat: 1, lon: 1, fix: FixType.fix_3d),
      Wpt(lat: 1, lon: 1, fix: FixType.none)
    ];
    final xml = await File('test/assets/fix.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });
}
