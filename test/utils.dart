import 'package:gpx/src/model/copyright.dart';
import 'package:gpx/src/model/gpx.dart';
import 'package:gpx/src/model/metadata.dart';
import 'package:gpx/src/model/rte.dart';
import 'package:gpx/src/model/trk.dart';
import 'package:gpx/src/model/trkseg.dart';
import 'package:gpx/src/model/wpt.dart';
import 'package:test/test.dart';

Gpx createGPXWithWpt() {
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.metadata = Metadata();
  gpx.metadata.name = 'world cities';
  gpx.metadata.desc = 'location of some of world cities';
  gpx.metadata.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.wpts = [
    Wpt(
        lat: -25.7996,
        lon: -62.8666,
        ele: 10.2,
        name: 'Monte Quemado',
        desc: 'Argentina'),
    Wpt(lat: 36.62, lon: 101.77, ele: 10.2, name: 'Xining', desc: 'China'),
  ];

  return gpx;
}

Gpx createGPXWithRte() {
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.metadata = Metadata();
  gpx.metadata.name = 'routes';
  gpx.metadata.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.rtes = [
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
    ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris'),
      Wpt(lat: 51.5, lon: -0.1167, name: 'London')
    ])
  ];

  return gpx;
}

Gpx createGPXWithTrk() {
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.metadata = Metadata();
  gpx.metadata.name = 'routes';
  gpx.metadata.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.trks = [
    Trk(name: 'route from London to Paris', trksegs: [
      Trkseg(trkpts: [
        Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
        Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
      ])
    ]),
    Trk(name: 'route from Paris to Londan', trksegs: [
      Trkseg(trkpts: [
        Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
        Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
      ])
    ])
  ];

  return gpx;
}

Gpx createComplexGPX() {
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.metadata = Metadata();
  gpx.metadata.name = 'routes';
  gpx.metadata.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.metadata.copyright =
      Copyright(author: 'lib', year: 2019, license: 'UNKNOWN');
  gpx.wpts = [
    Wpt(
        lat: -25.7996,
        lon: -62.8666,
        ele: 10.2,
        name: 'Monte Quemado',
        desc: 'Argentina'),
    Wpt(lat: 36.62, lon: 101.77, ele: 10.2, name: 'Xining', desc: 'China'),
  ];
  gpx.rtes = [
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
    ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris'),
      Wpt(lat: 51.5, lon: -0.1167, name: 'London')
    ])
  ];
  gpx.trks = [
    Trk(name: 'route from London to Paris', trksegs: [
      Trkseg(trkpts: [
        Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
        Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
      ])
    ]),
    Trk(name: 'route from Paris to Londan', trksegs: [
      Trkseg(trkpts: [
        Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
        Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
      ])
    ])
  ];

  return gpx;
}

void expectXml(String xml1, String xml2) {
  final regexp = RegExp(r'^\s+|\s+$|^\t+');
  expect(xml1.replaceAll(regexp, ''),
      xml2.replaceAll(regexp, '') /*, reason: xml1 */);
}
