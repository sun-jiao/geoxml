library kml.test.kml_reader_test;

import 'dart:convert';
import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'kml_utils.dart';

void main() {
  test('read kml with multiply points', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/wpt.kml').openRead().transform(utf8.decoder));
    final src = createKmlWithWpt();

    expect(kml, src);
  });

  test('read kml with multiply routes', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/rte.kml').openRead().transform(utf8.decoder));
    final src = createGPXWithRte();

    expect(kml, src);
  });

  test('read kml with multiply tracks', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/trk.kml').openRead().transform(utf8.decoder));
    final src = createGPXWithTrk();

    expect(kml, src);
  });

  test('read complex kml', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/complex.kml').openRead().transform(utf8.decoder));
    final src = createComplexKml();

    expect(kml.metadata, src.metadata);
    expect(kml.extensions, src.extensions);
    expect(kml.wpts, src.wpts);
    expect(kml.rtes, src.rtes);
    expect(kml, src);
  });

  test('read metadata kml', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/metadata.kml').openRead().transform(utf8.decoder));
    final src = createMetadataKml();

    expect(kml.metadata, src.metadata);
    expect(kml, src);
  });

  test('read large', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/large.kml').openRead().transform(utf8.decoder));

    expect(kml.rtes.length, 1);
    expect(kml.rtes.first.rtepts.length, 8139);
  });
}
