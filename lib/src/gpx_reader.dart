import 'dart:async';

import 'package:xml/xml_events.dart';

import 'model/bounds.dart';
import 'model/copyright.dart';
import 'model/email.dart';
import 'model/geoxml.dart';
import 'model/gpx_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/person.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/trkseg.dart';
import 'model/wpt.dart';
import 'tools/stream_converter.dart';

/// Read Gpx from string
class GpxReader {
  /// Parse xml stream and create Gpx object
  Future<GeoXml> fromStream(Stream<String> stream) async {
    final iterator = StreamIterator(toXmlStream(stream));

    return _fromIterator(iterator);
  }

  /// Parse xml string and create Gpx object
  Future<GeoXml> fromString(String xml) {
    final iterator = StreamIterator(Stream.fromIterable(parseEvents(xml)));

    return _fromIterator(iterator);
  }

  Future<GeoXml> _fromIterator(StreamIterator<XmlEvent> iterator) async {
    while (await iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent && val.name == GpxTag.gpx) {
        break;
      }
    }

    // ignore: avoid_as
    final gpxTag = iterator.current as XmlStartElementEvent;
    final gpx = GeoXml();

    gpx.version = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTag.version,
            orElse: () => XmlEventAttribute(
                GpxTag.version, '1.1', XmlAttributeType.DOUBLE_QUOTE))
        .value;
    gpx.creator = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTag.creator,
            orElse: () => XmlEventAttribute(
                GpxTag.creator, 'unknown', XmlAttributeType.DOUBLE_QUOTE))
        .value;

    while (await iterator.moveNext()) {
      final val = iterator.current;
      if (val is XmlEndElementEvent && val.name == GpxTag.gpx) {
        break;
      }

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case GpxTag.metadata:
            gpx.metadata = await _parseMetadata(iterator);
            break;
          case GpxTag.wayPoint:
            gpx.wpts.add(await _readPoint(iterator, val.name));
            break;
          case GpxTag.route:
            gpx.rtes.add(await _parseRoute(iterator));
            break;
          case GpxTag.track:
            gpx.trks.add(await _parseTrack(iterator));
            break;

          case GpxTag.extensions:
            gpx.extensions = await _readExtensions(iterator);
            break;
        }
      }
    }

    return gpx;
  }

  Future<Metadata> _parseMetadata(StreamIterator<XmlEvent> iterator) async {
    final metadata = Metadata();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.name:
              metadata.name = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              metadata.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.author:
              metadata.author = await _readPerson(iterator);
              break;
            case GpxTag.copyright:
              metadata.copyright = await _readCopyright(iterator);
              break;
            case GpxTag.link:
              metadata.links.add(await _readLink(iterator));
              break;
            case GpxTag.time:
              metadata.time = await _readDateTime(iterator, val.name);
              break;
            case GpxTag.keywords:
              metadata.keywords = await _readString(iterator, val.name);
              break;
            case GpxTag.bounds:
              metadata.bounds = await _readBounds(iterator);
              break;
            case GpxTag.extensions:
              metadata.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.metadata) {
          break;
        }
      }
    }

    return metadata;
  }

  Future<Rte> _parseRoute(StreamIterator<XmlEvent> iterator) async {
    final rte = Rte();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.routePoint:
              rte.rtepts.add(await _readPoint(iterator, val.name));
              break;

            case GpxTag.name:
              rte.name = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              rte.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.comment:
              rte.cmt = await _readString(iterator, val.name);
              break;
            case GpxTag.src:
              rte.src = await _readString(iterator, val.name);
              break;

            case GpxTag.link:
              rte.links.add(await _readLink(iterator));
              break;

            case GpxTag.number:
              rte.number = await _readInt(iterator, val.name);
              break;
            case GpxTag.type:
              rte.type = await _readString(iterator, val.name);
              break;

            case GpxTag.extensions:
              rte.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.route) {
          break;
        }
      }
    }

    return rte;
  }

  Future<Trk> _parseTrack(StreamIterator<XmlEvent> iterator) async {
    final trk = Trk();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.trackSegment:
              trk.trksegs.add(await _readSegment(iterator));
              break;

            case GpxTag.name:
              trk.name = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              trk.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.comment:
              trk.cmt = await _readString(iterator, val.name);
              break;
            case GpxTag.src:
              trk.src = await _readString(iterator, val.name);
              break;

            case GpxTag.link:
              trk.links.add(await _readLink(iterator));
              break;

            case GpxTag.number:
              trk.number = await _readInt(iterator, val.name);
              break;
            case GpxTag.type:
              trk.type = await _readString(iterator, val.name);
              break;

            case GpxTag.extensions:
              trk.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.track) {
          break;
        }
      }
    }

    return trk;
  }

  Future<Wpt> _readPoint(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final wpt = Wpt();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      wpt.lat = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.latitude)
          .value);
      wpt.lon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.longitude)
          .value);
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.sym:
              wpt.sym = await _readString(iterator, val.name);
              break;

            case GpxTag.fix:
              final fixAsString = await _readString(iterator, val.name);
              wpt.fix = FixType.values.firstWhere(
                  (e) =>
                      e.toString().replaceFirst('.fix_', '.') ==
                      'FixType.$fixAsString',
                  orElse: () => FixType.unknown);

              if (wpt.fix == FixType.unknown) {
                wpt.fix = null;
              }
              break;

            case GpxTag.dGPSId:
              wpt.dgpsid = await _readInt(iterator, val.name);
              break;

            case GpxTag.name:
              wpt.name = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              wpt.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.comment:
              wpt.cmt = await _readString(iterator, val.name);
              break;
            case GpxTag.src:
              wpt.src = await _readString(iterator, val.name);
              break;
            case GpxTag.link:
              wpt.links.add(await _readLink(iterator));
              break;
            case GpxTag.hDOP:
              wpt.hdop = await _readDouble(iterator, val.name);
              break;
            case GpxTag.vDOP:
              wpt.vdop = await _readDouble(iterator, val.name);
              break;
            case GpxTag.pDOP:
              wpt.pdop = await _readDouble(iterator, val.name);
              break;
            case GpxTag.ageOfData:
              wpt.ageofdgpsdata = await _readDouble(iterator, val.name);
              break;

            case GpxTag.magVar:
              wpt.magvar = await _readDouble(iterator, val.name);
              break;
            case GpxTag.geoidHeight:
              wpt.geoidheight = await _readDouble(iterator, val.name);
              break;

            case GpxTag.sat:
              wpt.sat = await _readInt(iterator, val.name);
              break;

            case GpxTag.elevation:
              wpt.ele = await _readDouble(iterator, val.name);
              break;
            case GpxTag.time:
              wpt.time = await _readDateTime(iterator, val.name);
              break;
            case GpxTag.type:
              wpt.type = await _readString(iterator, val.name);
              break;
            case GpxTag.extensions:
              wpt.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return wpt;
  }

  Future<double?> _readDouble(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final doubleString = await _readString(iterator, tagName);
    return doubleString != null ? double.parse(doubleString) : null;
  }

  Future<int?> _readInt(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final intString = await _readString(iterator, tagName);
    return intString != null ? int.parse(intString) : null;
  }

  Future<DateTime?> _readDateTime(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final dateTimeString = await _readString(iterator, tagName);
    return dateTimeString != null ? DateTime.parse(dateTimeString) : null;
  }

  Future<String?> _readString(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final elm = iterator.current;
    if (!(elm is XmlStartElementEvent &&
        elm.name == tagName &&
        !elm.isSelfClosing)) {
      return null;
    }

    var string = '';
    while (await iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlTextEvent) {
        string += val.text;
      }

      if (val is XmlCDATAEvent) {
        string += val.text;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    return string;
  }

  Future<Trkseg> _readSegment(StreamIterator<XmlEvent> iterator) async {
    final trkseg = Trkseg();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.trackPoint:
              trkseg.trkpts.add(await _readPoint(iterator, val.name));
              break;
            case GpxTag.extensions:
              trkseg.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.trackSegment) {
          break;
        }
      }
    }

    return trkseg;
  }

  Future<Map<String, String>> _readExtensions(
      StreamIterator<XmlEvent> iterator) async {
    final exts = <String, String>{};
    final elm = iterator.current;

    /*if (elm is XmlStartElementEvent) {
      link.href = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.href)
          .value;
    }*/

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          exts[val.name] = await _readString(iterator, val.name) ?? '';
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.extensions) {
          break;
        }
      }
    }

    return exts;
  }

  Future<Link> _readLink(StreamIterator<XmlEvent> iterator) async {
    final link = Link();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      link.href =
          elm.attributes.firstWhere((attr) => attr.name == GpxTag.href).value;
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.text:
              link.text = await _readString(iterator, val.name);
              break;
            case GpxTag.type:
              link.type = await _readString(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.link) {
          break;
        }
      }
    }

    return link;
  }

  Future<Person> _readPerson(StreamIterator<XmlEvent> iterator) async {
    final person = Person();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTag.name:
              person.name = await _readString(iterator, val.name);
              break;
            case GpxTag.email:
              person.email = await _readEmail(iterator);
              break;
            case GpxTag.link:
              person.link = await _readLink(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTag.author) {
          break;
        }
      }
    }

    return person;
  }

  Future<Copyright> _readCopyright(StreamIterator<XmlEvent> iterator) async {
    final copyright = Copyright();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      copyright.author =
          elm.attributes.firstWhere((attr) => attr.name == GpxTag.author).value;

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            switch (val.name) {
              case GpxTag.year:
                copyright.year = await _readInt(iterator, val.name);
                break;
              case GpxTag.license:
                copyright.license = await _readString(iterator, val.name);
                break;
            }
          }

          if (val is XmlEndElementEvent && val.name == GpxTag.copyright) {
            break;
          }
        }
      }
    }

    return copyright;
  }

  Future<Bounds> _readBounds(StreamIterator<XmlEvent> iterator) async {
    final bounds = Bounds();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      bounds.minlat = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.minLatitude)
          .value);
      bounds.minlon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.minLongitude)
          .value);
      bounds.maxlat = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.maxLatitude)
          .value);
      bounds.maxlon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTag.maxLongitude)
          .value);

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTag.bounds) {
            break;
          }
        }
      }
    }

    return bounds;
  }

  Future<Email> _readEmail(StreamIterator<XmlEvent> iterator) async {
    final email = Email();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      email.id =
          elm.attributes.firstWhere((attr) => attr.name == GpxTag.id).value;
      email.domain =
          elm.attributes.firstWhere((attr) => attr.name == GpxTag.domain).value;

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTag.email) {
            break;
          }
        }
      }
    }

    return email;
  }
}
