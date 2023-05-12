import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

Gpx createMinimalKml() {
  final kml = Gpx();
  kml.version = '1.1';
  kml.wpts = [];

  return kml;
}

Gpx createMinimalMetadataKml() {
  final kml = createMinimalKml();
  kml.metadata = Metadata();

  return kml;
}

Gpx createKmlWithWpt() {
  final kml = createMinimalKml();
  kml.metadata = Metadata();
  kml.metadata!.name = 'world cities';
  kml.metadata!.desc = 'location of some of world cities';
  kml.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  kml.wpts = [
    Wpt(
        lat: -25.7996,
        lon: -62.8666,
        ele: 10.2,
        name: 'Monte Quemado',
        desc: 'Argentina'),
    Wpt(lat: 36.62, lon: 101.77, ele: 10.2, name: 'Xining', desc: 'China'),
  ];

  return kml;
}

Gpx createGPXWithRte() {
  final kml = createMinimalKml();
  kml.metadata = Metadata();
  kml.metadata!.name = 'routes';
  kml.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  kml.rtes = [
    Rte(
        name: 'route from London to Paris',
        desc: 'route description',
        cmt: 'route comments',
        type: 'type',
        src: 'source',
        number: 1,
        rtepts: [
          Wpt(lat: 51.5, lon: -0.1167, ele: 0),
          Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
        ],
        links: [
          Link(href: 'http://google.com/')
        ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0),
      Wpt(lat: 51.5, lon: -0.1167, ele: 0)
    ])
  ];

  return kml;
}

Gpx createGPXWithTrk() {
  final kml = createMinimalKml();
  kml.metadata = Metadata();
  kml.metadata!.name = 'routes';
  kml.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  kml.rtes = [
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, ele: 0),
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
    ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, ele: 0),
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
    ])
  ];

  return kml;
}

Gpx createMetadataKml() {
  final kml = Gpx();
  kml.metadata = Metadata();
  kml.metadata!.name = 'routes';
  kml.metadata!.desc = 'desc';
  kml.metadata!.author = Person(
      name: 'name',
      email: Email(id: 'mail', domain: 'mail.com'),
      link: Link(href: 'http://google.com/'));
  kml.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  kml.metadata!.copyright = Copyright(author: 'lib', year: 2019);
  kml.metadata!.keywords = 'k1,k2,k3';

  return kml;
}

Gpx createComplexKml() {
  final kml = createMinimalKml();
  kml.metadata = Metadata();
  kml.metadata!.name = 'routes';
  kml.metadata!.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
  kml.metadata!.copyright = Copyright(author: 'lib', year: 2019);
  kml.wpts = [
    Wpt(
      lat: -25.7996,
      lon: -62.8666,
      ele: 10.2,
      name: 'Monte Quemado',
      desc: 'Argentina',
    ),
    Wpt(lat: 36.62, lon: 101.77, ele: 10.2, name: 'Xining', desc: 'China'),
  ];
  kml.rtes = [
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, ele: 0),
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
    ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0),
      Wpt(lat: 51.5, lon: -0.1167, ele: 0)
    ]),
    Rte(name: 'route from London to Paris', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, ele: 0),
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
    ]),
    Rte(name: 'route from Paris to Londan', rtepts: [
      Wpt(lat: 51.5, lon: -0.1167, ele: 0),
      Wpt(lat: 48.8667, lon: 2.3333, ele: 0)
    ]),
  ];

  return kml;
}

void expectXml(String xml1, String xml2) {
  final regexp = RegExp(r'\s+|\t+');
  expect(xml1.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      xml2.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      reason: xml1);
}
