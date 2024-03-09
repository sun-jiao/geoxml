library gpx.test.kml_writer_test;

import 'dart:io';

import 'package:geoxml/geoxml.dart';
import 'package:test/test.dart';

import '../tools/expect_xml.dart';
import '../tools/gpx_utils.dart';
import '../tools/kml_utils.dart';

void main() {
  test('write empty kml', () async {
    final gpx = createMinimalGPX();
    final xml = await File('test/assets/minimal.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write empty kml with metadata', () async {
    final gpx = createMinimalMetadataGPX();
    final xml =
        await File('test/assets/minimal_with_metadata.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write kml with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write kml with multiply routes', () async {
    final gpx = createGPXWithRte();
    final xml = await File('test/assets/rte.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write kml with multiply tracks', () async {
    final gpx = createKmlWithTrk();
    final xml = await File('test/assets/trk.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex kml', () async {
    final gpx = createComplexGPX();
    final xml = await File('test/assets/complex.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex kml with altitudeMode', () async {
    final gpx = createComplexGPX();
    final xml =
        await File('test/assets/complex_clampToGround.kml').readAsString();

    expectXml(
        KmlWriter(altitudeMode: AltitudeMode.clampToGround)
            .asString(gpx, pretty: true),
        xml);
  });

  // test('write styled kml', () async {
  //   final kmlString = await File('test/assets/style_test.kml').readAsString();
  //   final kml = await GeoXml.fromKmlString(kmlString);
  //   final kmlOutput = KmlWriter().asString(kml, pretty: true);
  //   print(kmlOutput);
  //
  //   expectXml(kmlOutput, kmlString);
  // });

  test('write large kml', () async {
    final gpx = await GpxReader()
        .fromString(await File('test/assets/large.gpx').readAsString());
    final xml = await File('test/assets/large.kml').readAsString();

    expectXml(KmlWriter().asString(gpx, pretty: true), xml);
  });
}
