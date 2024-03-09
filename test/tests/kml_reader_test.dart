library kml.test.kml_reader_test;

import 'dart:io';

import 'package:geoxml/geoxml.dart';
import 'package:test/test.dart';

import '../tools/kml_utils.dart';

void main() {
  test('read kml with multiply points', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/wpt.kml').readAsString());
    final src = createKmlWithWpt();

    expect(kml, src);
  });

  test('read kml with multiply routes', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/rte.kml').readAsString());
    final src = createKmlWithRte();

    expect(kml, src);
  });

  test('read kml with multiply tracks', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/trk.kml').readAsString());
    final src = createKmlWithTrk();

    expect(kml, src);
  });

  test('read complex kml', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/complex.kml').readAsString());
    final src = createComplexKml();

    expect(kml.metadata, src.metadata);
    expect(kml.extensions, src.extensions);
    expect(kml.wpts, src.wpts);
    expect(kml.rtes, src.rtes);
    expect(kml, src);
  });

  test('read metadata kml', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/metadata.kml').readAsString());
    final src = createMetadataKml();

    expect(kml.metadata, src.metadata);
    expect(kml, src);
  });

  test('read large', () async {
    final kml = await KmlReader()
        .fromString(await File('test/assets/large.kml').readAsString());

    expect(kml.trks.length, 1);
    expect(kml.trks.first.trksegs.length, 1);
    expect(kml.trks.first.trksegs.first.trkpts.length, 8139);
  });

  test('read simple kml', () async {
    const xml = '<?xml version="1.0" encoding="UTF-8"?> '
        '<kml xmlns="http://www.opengis.net/kml/2.2"><Document>'
        '<name>Five Hikes in the White Mountains</name>'
        '<description>Five Hikes in the White Mountains!!</description>'
        '<atom:author/><ExtendedData><Data name="keywords">'
        '<value>Hiking, NH, Presidential Range</value></Data><Data name="time">'
        '<value>2016-08-21T12:24:27.000Z</value></Data></ExtendedData>'
        '<Placemark><name>khm</name><timestamp><when>2016-08-21T12:51:30.000Z'
        '</when></timestamp><ExtendedData><Data name="src"><value>network'
        '</value></Data></ExtendedData><Point>'
        '<coordinates>16.3608048,48.2033471,0.0</coordinates></Point>'
        '</Placemark><Placemark><ExtendedData/><LineString><extrude>1</extrude>'
        '<tessellate>1</tessellate><altitudeMode>absolute</altitudeMode>'
        '<coordinates>16.40377444,48.19949341,212.0 16.40371021,48.19948359,212.0</coordinates>'
        '</LineString></Placemark></Document></kml>';

    final kml = await KmlReader().fromString(xml);

    expect(kml.metadata!.name, 'Five Hikes in the White Mountains');
    expect(kml.metadata!.desc, 'Five Hikes in the White Mountains!!');
    expect(kml.metadata!.time, DateTime.utc(2016, 8, 21, 12, 24, 27));
    expect(kml.metadata!.keywords, 'Hiking, NH, Presidential Range');

    expect(kml.wpts.length, 1);
    expect(kml.wpts.first.lat, 48.2033471);
    expect(kml.wpts.first.lon, 16.3608048);
    expect(kml.wpts.first.time, DateTime.utc(2016, 8, 21, 12, 51, 30));
    expect(kml.wpts.first.name, 'khm');
    expect(kml.wpts.first.src, 'network');

    expect(kml.rtes.length, 1);
    expect(kml.rtes.first.rtepts.length, 2);
    expect(kml.rtes.first.rtepts.last.lat, 48.19948359);
    expect(kml.rtes.first.rtepts.last.lon, 16.40371021);
    expect(kml.rtes.first.rtepts.last.ele, 212.0);
  });

  test('gx:Track support', () async {
    final kml = await KmlReader().fromString(
        await File('test/assets/2022-12-18-11-47-Beihai.kml').readAsString());

    expect(kml.trks.length, 1);
    expect(kml.trks.first.name, 'TbuluTrack');
    expect(kml.trks.first.trksegs.length, 1);
    expect(kml.trks.first.trksegs.first.trkpts.length, 1230);
  });

  test('coordinates without altitude', () async {
    const xml = '<kml xmlns="http://www.opengis.net/kml/2.2"><Placemark>'
        '<name>01:05:3305001:1171</name><description>text</description>'
        '<Style><LineStyle><color>FF143C6E</color><width>1</width></LineStyle>'
        '<PolyStyle><fill>1</fill><color>9914F0FF</color></PolyStyle></Style>'
        '<MultiGeometry><Polygon><outerBoundaryIs><LinearRing><coordinates>'
        '39.0291230732137,44.9582356582183 39.02908207410419,44.957191221292 '
        '39.0298317721077,44.9571829320347 39.02981420106074,44.956565378946 '
        '39.0313955952869,44.9565488002489 39.03182901444519,44.957933105033 '
        '39.0291230732137,44.9582356582183</coordinates></LinearRing>'
        '</outerBoundaryIs></Polygon></MultiGeometry></Placemark></kml>';

    final kml = await KmlReader().fromString(xml);

    expect(kml.polygons.length, 1);
    expect(kml.polygons.first.outerBoundaryIs.rtepts.length, 7);
  });
}
