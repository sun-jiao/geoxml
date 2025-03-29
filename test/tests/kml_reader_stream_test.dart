library;

import 'dart:convert';
import 'dart:io';

import 'package:geoxml/geoxml.dart';
import 'package:test/test.dart';

import '../tools/kml_utils.dart';

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
    final src = createKmlWithRte();

    expect(kml, src);
  });

  test('read kml with multiply tracks', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/trk.kml').openRead().transform(utf8.decoder));
    final src = createKmlWithTrk();

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

  test('read style kml', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/style_test.kml').openRead().transform(utf8.decoder));

    expect(kml.styles.length, 2);
    expect(kml.styles.first.id, equals('randomColorIcon'));
    expect(kml.styles.first.iconStyle?.x, 0.5);
    expect(kml.rtes.length, 1);
    expect(kml.rtes.first.style?.lineStyle?.color, 0xffffff00);
    expect(kml.polygons.length, 1);
    expect(kml.polygons.first.style?.polyStyle?.color, 0xfe00ffff);
    expect(kml.polygons.first.outerBoundaryIs.rtepts.length, 97);
    expect(kml.polygons.first.innerBoundaryIs.length, 2);
    expect(kml.wpts.length, 2);
    expect(kml.wpts.first.style, equals(kml.styles.first));
  });

  test('read large', () async {
    final kml = await KmlReader().fromStream(
        File('test/assets/large.kml').openRead().transform(utf8.decoder));

    expect(kml.trks.length, 1);
    expect(kml.trks.first.trksegs.length, 1);
    expect(kml.trks.first.trksegs.first.trkpts.length, 8139);
  });
}
