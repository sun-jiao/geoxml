library gpx.test.gpx_reader_test;

import 'dart:convert';
import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('read gpx with multiply points', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/wpt.gpx').openRead().transform(utf8.decoder));
    final src = createGPXWithWpt();

    expect(gpx, src);
  });

  test('read gpx with multiply routes', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/rte.gpx').openRead().transform(utf8.decoder));
    final src = createGPXWithRte();

    expect(gpx, src);
  });

  test('read gpx with multiply tracks', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/trk.gpx').openRead().transform(utf8.decoder));
    final src = createGPXWithTrk();

    expect(gpx, src);
  });

  test('read complex gpx', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/complex.gpx').openRead().transform(utf8.decoder));
    final src = createComplexGPX();

    expect(gpx.metadata, src.metadata);
    expect(gpx.extensions, src.extensions);
    expect(gpx.wpts, src.wpts);
    expect(gpx.trks, src.trks);
    expect(gpx.rtes, src.rtes);
    expect(gpx, src);
  });

  test('read metadata gpx', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/metadata.gpx').openRead().transform(utf8.decoder));
    final src = createMetadataGPX();

    expect(gpx.metadata, src.metadata);
    expect(gpx, src);
  });

  test('read large', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/large.gpx').openRead().transform(utf8.decoder));

    expect(gpx.trks.length, 1);
    expect(gpx.trks.first.trksegs.length, 1);
    expect(gpx.trks.first.trksegs.first.trkpts.length, 8139);
  });

  test('issue-4 FixType', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/fix.gpx').openRead().transform(utf8.decoder));

    expect(gpx.wpts[0].fix, FixType.fix_2d);
    expect(gpx.wpts[1].fix, FixType.fix_3d);
    expect(gpx.wpts[2].fix, FixType.none);

    final gpxUnknown = await GpxReader()
        .fromString(await File('test/assets/fix_unknown.gpx').readAsString());
    expect(gpxUnknown.wpts[0].fix, null);
  });

  test('issue-4', () async {
    final gpx = await GpxReader().fromStream(
        File('test/assets/20160617-La-Hermida-to-Bejes.gpx')
            .openRead()
            .transform(utf8.decoder));

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
