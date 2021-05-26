library gpx.test.gpx_reader_test;

import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('read gpx with multiply points', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/wpt.gpx').readAsString());
    final src = createGPXWithWpt();

    expect(gpx, src);
  });

  test('read gpx with multiply points', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/wpt.gpx').readAsString());
    final src = createGPXWithWpt();

    expect(gpx, src);
  });

  test('read gpx with multiply routes', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/rte.gpx').readAsString());
    final src = createGPXWithRte();

    expect(gpx, src);
  });

  test('read gpx with multiply tracks', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/trk.gpx').readAsString());
    final src = createGPXWithTrk();

    expect(gpx, src);
  });

  test('read complex gpx', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/complex.gpx').readAsString());
    final src = createComplexGPX();

    expect(gpx.metadata, src.metadata);
    expect(gpx.extensions, src.extensions);
    expect(gpx.trks, src.trks);
    expect(gpx.rtes, src.rtes);
    expect(gpx, src);
  });

  test('read metadata gpx', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/metadata.gpx').readAsString());
    final src = createMetadataGPX();

    expect(gpx.metadata, src.metadata);
    expect(gpx, src);
  });

  test('read large', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/large.gpx').readAsString());

    expect(gpx.trks.length, 1);
    expect(gpx.trks.first.trksegs.length, 1);
    expect(gpx.trks.first.trksegs.first.trkpts.length, 8139);
  });

  test('read simple gpx', () {
    const xml = '<?xml version="1.0" encoding="UTF-8" ?>'
        '<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" creator="GPSLogger 79 - http://gpslogger.mendhak.com/" xmlns="http://www.topografix.com/GPX/1/0" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">'
        '<metadata>'
        '<name>Five Hikes in the White Mountains</name>'
        '<desc>Five Hikes in the White Mountains!!</desc>'
        '<author>Franz Wilhelmstötter</author>'
        '<email>franz.wilhelmstoetter@gmail.com</email>'
        '<url>https://github.com/jenetics/jpx</url>'
        '<urlname>Visit my New Hampshire hiking website!</urlname>'
        '<time>2016-08-21T12:24:27Z</time>'
        '<keywords>Hiking, NH, Presidential Range</keywords>'
        '<bounds minlat="42.1" minlon="71.9" maxlat="42.4" maxlon="71.1" />'
        '</metadata>'
        '<wpt lat="48.2033471" lon="16.3608048"><time>2016-08-21T12:51:30Z</time><name>khm</name><src>network</src></wpt>'
        '<trk><trkseg>'
        '<trkpt lat="48.19949341" lon="16.40377444"><ele>212.0</ele><time>2016-08-21T12:24:27Z</time><course>341.6</course><speed>0.67052215</speed><src>gps</src><sat>14</sat></trkpt>'
        '<trkpt lat="48.19948359" lon="16.40371021"><ele>212.0</ele><time>2016-08-21T12:24:31Z</time><course>298.6</course><speed>0.7424285</speed><geoidheight>43.0</geoidheight><src>gps</src><sat>2</sat><hdop>0.7</hdop><vdop>0.8</vdop><pdop>1.1</pdop></trkpt>'
        '</trkseg></trk></gpx>';

    final gpx = GpxReader().fromString(xml);

    expect(gpx.version, '1.0');
    expect(gpx.creator, 'GPSLogger 79 - http://gpslogger.mendhak.com/');

    expect(gpx.metadata!.name, 'Five Hikes in the White Mountains');
    expect(gpx.metadata!.desc, 'Five Hikes in the White Mountains!!');
    expect(gpx.metadata!.time, DateTime.utc(2016, 8, 21, 12, 24, 27));
    expect(gpx.metadata!.keywords, 'Hiking, NH, Presidential Range');
    expect(gpx.metadata!.bounds!.minlat, 42.1);
    expect(gpx.metadata!.bounds!.minlon, 71.9);
    expect(gpx.metadata!.bounds!.maxlat, 42.4);
    expect(gpx.metadata!.bounds!.maxlon, 71.1);

    expect(gpx.wpts.length, 1);
    expect(gpx.wpts.first.lat, 48.2033471);
    expect(gpx.wpts.first.lon, 16.3608048);
    expect(gpx.wpts.first.time, DateTime.utc(2016, 8, 21, 12, 51, 30));
    expect(gpx.wpts.first.name, 'khm');
    expect(gpx.wpts.first.src, 'network');

    expect(gpx.trks.length, 1);
    expect(gpx.trks.first.trksegs.length, 1);
    expect(gpx.trks.first.trksegs.first.trkpts.length, 2);
    expect(gpx.trks.first.trksegs.first.trkpts.last.lat, 48.19948359);
    expect(gpx.trks.first.trksegs.first.trkpts.last.lon, 16.40371021);
    expect(gpx.trks.first.trksegs.first.trkpts.last.ele, 212.0);
    expect(gpx.trks.first.trksegs.first.trkpts.last.sat, 2);
    expect(gpx.trks.first.trksegs.first.trkpts.last.hdop, 0.7);
    expect(gpx.trks.first.trksegs.first.trkpts.last.vdop, 0.8);
    expect(gpx.trks.first.trksegs.first.trkpts.last.pdop, 1.1);
    expect(gpx.trks.first.trksegs.first.trkpts.last.src, 'gps');
    expect(gpx.trks.first.trksegs.first.trkpts.last.time,
        DateTime.utc(2016, 8, 21, 12, 24, 31));
  });

  test('issue-4 FixType', () async {
    final gpx = GpxReader()
        .fromString(await File('test/assets/fix.gpx').readAsString());

    expect(gpx.wpts[0].fix, FixType.fix_2d);
    expect(gpx.wpts[1].fix, FixType.fix_3d);
    expect(gpx.wpts[2].fix, FixType.none);

    final gpxUnknown = GpxReader()
        .fromString(await File('test/assets/fix_unknown.gpx').readAsString());
    expect(gpxUnknown.wpts[0].fix, null);
  });

  test('issue-4', () async {
    final gpx = GpxReader().fromString(
        await File('test/assets/20160617-La-Hermida-to-Bejes.gpx')
            .readAsString());

    expect(gpx.creator, 'MapGazer 1.86');
    expect(gpx.metadata!.links.length, 1);
    expect(gpx.metadata!.links.first.text, 'MapGazer website');
    expect(gpx.metadata!.links.first.href, 'http://speleotrove.com/mapgazer/');

    expect(gpx.wpts.length, 3);
    expect(gpx.wpts.first.fix, FixType.fix_3d);
    expect(gpx.wpts.first.name, 'La Hermida');
    expect(gpx.wpts.first.desc, 'At 43.25473N, 4.61518W');

    expect(gpx.trks.length, 1);
  });
}
