import 'dart:async';

import 'package:xml/xml_events.dart';

import 'model/bounds.dart';
import 'model/copyright.dart';
import 'model/email.dart';
import 'model/gpx.dart';
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
  Future<Gpx> fromStream(Stream<String> stream) async {
    final iterator = StreamIterator(toXmlStream(stream));

    return _fromIterator(iterator);
  }

  /// Parse xml string and create Gpx object
  Future<Gpx> fromString(String xml) {
    final iterator = StreamIterator(Stream.fromIterable(parseEvents(xml)));

    return _fromIterator(iterator);
  }

  Future<Gpx> _fromIterator(StreamIterator<XmlEvent> iterator) async {
    while (await iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }
    }

    // ignore: avoid_as
    final gpxTag = iterator.current as XmlStartElementEvent;
    final gpx = Gpx();

    gpx.version = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTagV11.version,
            orElse: () => XmlEventAttribute(
                GpxTagV11.version, '1.1', XmlAttributeType.DOUBLE_QUOTE))
        .value;
    gpx.creator = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTagV11.creator,
            orElse: () => XmlEventAttribute(
                GpxTagV11.creator, 'unknown', XmlAttributeType.DOUBLE_QUOTE))
        .value;

    while (await iterator.moveNext()) {
      final val = iterator.current;
      if (val is XmlEndElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case GpxTagV11.metadata:
            gpx.metadata = await _parseMetadata(iterator);
            break;
          case GpxTagV11.wayPoint:
            gpx.wpts.add(await _readPoint(iterator, val.name));
            break;
          case GpxTagV11.route:
            gpx.rtes.add(await _parseRoute(iterator));
            break;
          case GpxTagV11.track:
            gpx.trks.add(await _parseTrack(iterator));
            break;

          case GpxTagV11.extensions:
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
            case GpxTagV11.name:
              metadata.name = await _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              metadata.desc = await _readString(iterator, val.name);
              break;
            case GpxTagV11.author:
              metadata.author = await _readPerson(iterator);
              break;
            case GpxTagV11.copyright:
              metadata.copyright = await _readCopyright(iterator);
              break;
            case GpxTagV11.link:
              metadata.links.add(await _readLink(iterator));
              break;
            case GpxTagV11.time:
              metadata.time = await _readDateTime(iterator, val.name);
              break;
            case GpxTagV11.keywords:
              metadata.keywords = await _readString(iterator, val.name);
              break;
            case GpxTagV11.bounds:
              metadata.bounds = await _readBounds(iterator);
              break;
            case GpxTagV11.extensions:
              metadata.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.metadata) {
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
            case GpxTagV11.routePoint:
              rte.rtepts.add(await _readPoint(iterator, val.name));
              break;

            case GpxTagV11.name:
              rte.name = await _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              rte.desc = await _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              rte.cmt = await _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              rte.src = await _readString(iterator, val.name);
              break;

            case GpxTagV11.link:
              rte.links.add(await _readLink(iterator));
              break;

            case GpxTagV11.number:
              rte.number = await _readInt(iterator, val.name);
              break;
            case GpxTagV11.type:
              rte.type = await _readString(iterator, val.name);
              break;

            case GpxTagV11.extensions:
              rte.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.route) {
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
            case GpxTagV11.trackSegment:
              trk.trksegs.add(await _readSegment(iterator));
              break;

            case GpxTagV11.name:
              trk.name = await _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              trk.desc = await _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              trk.cmt = await _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              trk.src = await _readString(iterator, val.name);
              break;

            case GpxTagV11.link:
              trk.links.add(await _readLink(iterator));
              break;

            case GpxTagV11.number:
              trk.number = await _readInt(iterator, val.name);
              break;
            case GpxTagV11.type:
              trk.type = await _readString(iterator, val.name);
              break;

            case GpxTagV11.extensions:
              trk.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.track) {
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
          .firstWhere((attr) => attr.name == GpxTagV11.latitude)
          .value);
      wpt.lon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.longitude)
          .value);
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.sym:
              wpt.sym = await _readString(iterator, val.name);
              break;

            case GpxTagV11.fix:
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

            case GpxTagV11.dGPSId:
              wpt.dgpsid = await _readInt(iterator, val.name);
              break;

            case GpxTagV11.name:
              wpt.name = await _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              wpt.desc = await _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              wpt.cmt = await _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              wpt.src = await _readString(iterator, val.name);
              break;
            case GpxTagV11.link:
              wpt.links.add(await _readLink(iterator));
              break;
            case GpxTagV11.hDOP:
              wpt.hdop = await _readDouble(iterator, val.name);
              break;
            case GpxTagV11.vDOP:
              wpt.vdop = await _readDouble(iterator, val.name);
              break;
            case GpxTagV11.pDOP:
              wpt.pdop = await _readDouble(iterator, val.name);
              break;
            case GpxTagV11.ageOfData:
              wpt.ageofdgpsdata = await _readDouble(iterator, val.name);
              break;

            case GpxTagV11.magVar:
              wpt.magvar = await _readDouble(iterator, val.name);
              break;
            case GpxTagV11.geoidHeight:
              wpt.geoidheight = await _readDouble(iterator, val.name);
              break;

            case GpxTagV11.sat:
              wpt.sat = await _readInt(iterator, val.name);
              break;

            case GpxTagV11.elevation:
              wpt.ele = await _readDouble(iterator, val.name);
              break;
            case GpxTagV11.time:
              wpt.time = await _readDateTime(iterator, val.name);
              break;
            case GpxTagV11.type:
              wpt.type = await _readString(iterator, val.name);
              break;
            case GpxTagV11.extensions:
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
            case GpxTagV11.trackPoint:
              trkseg.trkpts.add(await _readPoint(iterator, val.name));
              break;
            case GpxTagV11.extensions:
              trkseg.extensions = await _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.trackSegment) {
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

        if (val is XmlEndElementEvent && val.name == GpxTagV11.extensions) {
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
      link.href = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.href)
          .value;
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.text:
              link.text = await _readString(iterator, val.name);
              break;
            case GpxTagV11.type:
              link.type = await _readString(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.link) {
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
            case GpxTagV11.name:
              person.name = await _readString(iterator, val.name);
              break;
            case GpxTagV11.email:
              person.email = await _readEmail(iterator);
              break;
            case GpxTagV11.link:
              person.link = await _readLink(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.author) {
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
      copyright.author = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.author)
          .value;

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            switch (val.name) {
              case GpxTagV11.year:
                copyright.year = await _readInt(iterator, val.name);
                break;
              case GpxTagV11.license:
                copyright.license = await _readString(iterator, val.name);
                break;
            }
          }

          if (val is XmlEndElementEvent && val.name == GpxTagV11.copyright) {
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
          .firstWhere((attr) => attr.name == GpxTagV11.minLatitude)
          .value);
      bounds.minlon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.minLongitude)
          .value);
      bounds.maxlat = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.maxLatitude)
          .value);
      bounds.maxlon = double.parse(elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.maxLongitude)
          .value);

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTagV11.bounds) {
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
          elm.attributes.firstWhere((attr) => attr.name == GpxTagV11.id).value;
      email.domain = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.domain)
          .value;

      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTagV11.email) {
            break;
          }
        }
      }
    }

    return email;
  }
}
