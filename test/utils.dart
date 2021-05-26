import 'package:gpx/gpx.dart';
import 'package:gpx/src/model/copyright.dart';
import 'package:gpx/src/model/email.dart';
import 'package:gpx/src/model/gpx.dart';
import 'package:gpx/src/model/link.dart';
import 'package:gpx/src/model/metadata.dart';
import 'package:gpx/src/model/person.dart';
import 'package:gpx/src/model/rte.dart';
import 'package:gpx/src/model/trk.dart';
import 'package:gpx/src/model/trkseg.dart';
import 'package:gpx/src/model/wpt.dart';
import 'package:test/test.dart';

Gpx createMinimalGPX() {
  final gpx = Gpx();
  gpx.version = '1.1';
  gpx.creator = 'dart-gpx library';
  gpx.wpts = [];

  return gpx;
}

Gpx createMinimalMetadataGPX() {
  final gpx = createMinimalGPX();
  gpx.metadata = Metadata();

  return gpx;
}

Gpx createGPXWithWpt() {
  final gpx = createMinimalGPX();
  gpx.metadata = Metadata();
  gpx.metadata!.name = 'world cities';
  gpx.metadata!.desc = 'location of some of world cities';
  gpx.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
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
  final gpx = createMinimalGPX();
  gpx.metadata = Metadata();
  gpx.metadata!.name = 'routes';
  gpx.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.rtes = [
    Rte(
        name: 'route from London to Paris',
        desc: 'route description',
        cmt: 'route comments',
        type: 'type',
        src: 'source',
        number: 1,
        rtepts: [
          Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
          Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
        ],
        links: [
          Link(href: 'http://google.com/', text: 'LINK', type: 'TYPE')
        ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris'),
      Wpt(lat: 51.5, lon: -0.1167, name: 'London')
    ])
  ];

  return gpx;
}

Gpx createGPXWithTrk() {
  final gpx = createMinimalGPX();
  gpx.metadata = Metadata();
  gpx.metadata!.name = 'routes';
  gpx.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
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

Gpx createMetadataGPX() {
  final gpx = Gpx();
  gpx.metadata = Metadata();
  gpx.metadata!.name = 'routes';
  gpx.metadata!.desc = 'desc';
  gpx.metadata!.author = Person(
      name: 'name',
      email: Email(id: 'mail', domain: 'mail.com'),
      link: Link(href: 'http://google.com/', text: 'LINK', type: 'TYPE'));
  gpx.metadata!.links = [
    Link(href: 'http://metadata.com/', text: 'LINK', type: 'TYPE')
  ];
  gpx.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.metadata!.copyright =
      Copyright(author: 'lib', year: 2019, license: 'UNKNOWN');
  gpx.metadata!.keywords = 'k1,k2,k3';
  gpx.metadata!.bounds = Bounds(minlat: 0, minlon: 1, maxlat: 2, maxlon: 3);
  gpx.metadata!.extensions = {'schema:m1': 'v1', 'schema:m2': 'v2'};

  return gpx;
}

Gpx createComplexGPX() {
  final gpx = createMinimalGPX();
  gpx.metadata = Metadata();
  gpx.metadata!.name = 'routes';
  gpx.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  gpx.metadata!.copyright =
      Copyright(author: 'lib', year: 2019, license: 'UNKNOWN');
  gpx.metadata!.extensions = {'m1': 'v1', 'm2': 'v2'};
  gpx.wpts = [
    Wpt(
        lat: -25.7996,
        lon: -62.8666,
        ele: 10.2,
        name: 'Monte Quemado',
        desc: 'Argentina',
        extensions: {'k1': 'v1', 'k2': 'v2'}),
    Wpt(lat: 36.62, lon: 101.77, ele: 10.2, name: 'Xining', desc: 'China'),
  ];
  gpx.rtes = [
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
      Wpt(lat: 48.8667, lon: 2.3333, name: 'Paris')
    ], extensions: {
      'r1': 'v1',
      'r2': 'v2'
    }),
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
    ], extensions: {
      't1': 'v1',
      't2': 'v2'
    }),
    Trk(name: 'route from Paris to Londan', trksegs: [
      Trkseg(trkpts: [
        Wpt(lat: 51.5, lon: -0.1167, name: 'London'),
        Wpt(
            lat: 48.8667,
            lon: 2.3333,
            name: 'Paris',
            extensions: {'k1': 'v1', 'k2': 'v2'})
      ], extensions: {
        's1': 'v1',
        's2': 'v2'
      })
    ])
  ];

  gpx.extensions = {'g1': 'v1', 'g2': 'v2'};

  return gpx;
}

void expectXml(String xml1, String xml2) {
  final regexp = RegExp(r'\s+|\t+');
  expect(xml1.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      xml2.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      reason: xml1);
}
