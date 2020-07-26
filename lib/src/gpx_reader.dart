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

class GpxReader {
//  // @TODO
//  Gpx fromStream(Stream<int> stream) {
//
//  }

  /// Parse xml string and create Gpx object
  Gpx fromString(String xml) {
    final iterator = parseEvents(xml).iterator;

    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }
    }

    // ignore: avoid_as
    final gpxTag = iterator.current as XmlStartElementEvent;
    final gpx = Gpx();

    gpx.version = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTagV11.version)
        .value;
    gpx.creator = gpxTag.attributes
        .firstWhere((attr) => attr.name == GpxTagV11.creator)
        .value;

    while (iterator.moveNext()) {
      final val = iterator.current;
      if (val is XmlEndElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case GpxTagV11.metadata:
            gpx.metadata = _parseMetadata(iterator);
            break;
          case GpxTagV11.wayPoint:
            gpx.wpts.add(_readPoint(iterator, GpxTagV11.wayPoint));
            break;
          case GpxTagV11.route:
            gpx.rtes.add(_parseRoute(iterator));
            break;
          case GpxTagV11.track:
            gpx.trks.add(_parseTrack(iterator));
            break;

          case GpxTagV11.extensions:
            gpx.extensions = _readExtensions(iterator);
            break;
        }
      }
    }

    return gpx;
  }

  Metadata _parseMetadata(Iterator<XmlEvent> iterator) {
    final metadata = Metadata();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.name:
              metadata.name = _readString(iterator, GpxTagV11.name);
              break;
            case GpxTagV11.desc:
              metadata.desc = _readString(iterator, GpxTagV11.desc);
              break;
            case GpxTagV11.author:
              metadata.author = _readPerson(iterator);
              break;
            case GpxTagV11.copyright:
              metadata.copyright = _readCopyright(iterator);
              break;
            case GpxTagV11.link:
              metadata.links.add(_readLink(iterator));
              break;
            case GpxTagV11.time:
              metadata.time =
                  DateTime.parse(_readString(iterator, GpxTagV11.time));
              break;
            case GpxTagV11.keywords:
              metadata.keywords = _readString(iterator, GpxTagV11.keywords);
              break;
            case GpxTagV11.bounds:
              metadata.bounds = _readBounds(iterator);
              break;
            case GpxTagV11.extensions:
              metadata.extensions = _readExtensions(iterator);
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

  Rte _parseRoute(Iterator<XmlEvent> iterator) {
    final rte = Rte();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.routePoint:
              rte.rtepts.add(_readPoint(iterator, GpxTagV11.routePoint));
              break;

            case GpxTagV11.name:
              rte.name = _readString(iterator, GpxTagV11.name);
              break;
            case GpxTagV11.desc:
              rte.desc = _readString(iterator, GpxTagV11.desc);
              break;
            case GpxTagV11.comment:
              rte.cmt = _readString(iterator, GpxTagV11.comment);
              break;
            case GpxTagV11.src:
              rte.src = _readString(iterator, GpxTagV11.src);
              break;

            case GpxTagV11.link:
              rte.links.add(_readLink(iterator));
              break;

            case GpxTagV11.number:
              rte.number = int.parse(_readString(iterator, GpxTagV11.number));
              break;
            case GpxTagV11.type:
              rte.type = _readString(iterator, GpxTagV11.type);
              break;

            case GpxTagV11.extensions:
              rte.extensions = _readExtensions(iterator);
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

  Trk _parseTrack(Iterator<XmlEvent> iterator) {
    final trk = Trk();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.trackSegment:
              trk.trksegs.add(_readSegment(iterator));
              break;

            case GpxTagV11.name:
              trk.name = _readString(iterator, GpxTagV11.name);
              break;
            case GpxTagV11.desc:
              trk.desc = _readString(iterator, GpxTagV11.desc);
              break;
            case GpxTagV11.comment:
              trk.cmt = _readString(iterator, GpxTagV11.comment);
              break;
            case GpxTagV11.src:
              trk.src = _readString(iterator, GpxTagV11.src);
              break;

            case GpxTagV11.link:
              trk.links.add(_readLink(iterator));
              break;

            case GpxTagV11.number:
              trk.number = int.parse(_readString(iterator, GpxTagV11.number));
              break;
            case GpxTagV11.type:
              trk.type = _readString(iterator, GpxTagV11.type);
              break;

            case GpxTagV11.extensions:
              trk.extensions = _readExtensions(iterator);
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

  Wpt _readPoint(Iterator<XmlEvent> iterator, String tagName) {
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
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.sym:
              wpt.sym = _readString(iterator, GpxTagV11.sym);
              break;

            case GpxTagV11.fix:
              wpt.fix = FixType.values.firstWhere(
                  (e) => e.toString() == _readString(iterator, GpxTagV11.fix));
              break;

            case GpxTagV11.dGPSId:
              wpt.dgpsid = int.parse(_readString(iterator, GpxTagV11.dGPSId));
              break;

            case GpxTagV11.name:
              wpt.name = _readString(iterator, GpxTagV11.name);
              break;
            case GpxTagV11.desc:
              wpt.desc = _readString(iterator, GpxTagV11.desc);
              break;
            case GpxTagV11.comment:
              wpt.cmt = _readString(iterator, GpxTagV11.comment);
              break;
            case GpxTagV11.src:
              wpt.src = _readString(iterator, GpxTagV11.src);
              break;
            case GpxTagV11.link:
              wpt.links.add(_readLink(iterator));
              break;
            case GpxTagV11.hDOP:
              wpt.hdop = double.parse(_readString(iterator, GpxTagV11.hDOP));
              break;
            case GpxTagV11.vDOP:
              wpt.vdop = double.parse(_readString(iterator, GpxTagV11.vDOP));
              break;
            case GpxTagV11.pDOP:
              wpt.pdop = double.parse(_readString(iterator, GpxTagV11.pDOP));
              break;
            case GpxTagV11.ageOfData:
              wpt.ageofdgpsdata =
                  double.parse(_readString(iterator, GpxTagV11.ageOfData));
              break;

            case GpxTagV11.magVar:
              wpt.magvar =
                  double.parse(_readString(iterator, GpxTagV11.magVar));
              break;
            case GpxTagV11.geoidHeight:
              wpt.geoidheight =
                  double.parse(_readString(iterator, GpxTagV11.geoidHeight));
              break;

            case GpxTagV11.sat:
              wpt.sat = int.parse(_readString(iterator, GpxTagV11.sat));
              break;

            case GpxTagV11.elevation:
              wpt.ele =
                  double.parse(_readString(iterator, GpxTagV11.elevation));
              break;
            case GpxTagV11.time:
              wpt.time = DateTime.parse(_readString(iterator, GpxTagV11.time));
              break;
            case GpxTagV11.type:
              wpt.type = _readString(iterator, GpxTagV11.type);
              break;
            case GpxTagV11.extensions:
              wpt.extensions = _readExtensions(iterator);
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

  String _readString(Iterator<XmlEvent> iterator, String tagName) {
    final elm = iterator.current;
    if (!(elm is XmlStartElementEvent &&
        elm.name == tagName &&
        !elm.isSelfClosing)) {
      return null;
    }

    var string = '';
    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlTextEvent) {
        string += val.text;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    return string;
  }

  Trkseg _readSegment(Iterator<XmlEvent> iterator) {
    final trkseg = Trkseg();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.trackPoint:
              trkseg.trkpts.add(_readPoint(iterator, GpxTagV11.trackPoint));
              break;
            case GpxTagV11.extensions:
              trkseg.extensions = _readExtensions(iterator);
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

  Map<String, String> _readExtensions(Iterator<XmlEvent> iterator) {
    final exts = <String, String>{};
    final elm = iterator.current;

    /*if (elm is XmlStartElementEvent) {
      link.href = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.href)
          .value;
    }*/

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          exts[val.name] = _readString(iterator, val.name);
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.extensions) {
          break;
        }
      }
    }

    return exts;
  }

  Link _readLink(Iterator<XmlEvent> iterator) {
    final link = Link();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      link.href = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.href)
          .value;
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.text:
              link.text = _readString(iterator, GpxTagV11.text);
              break;
            case GpxTagV11.type:
              link.type = _readString(iterator, GpxTagV11.type);
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

  Person _readPerson(Iterator<XmlEvent> iterator) {
    final person = Person();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.name:
              person.name = _readString(iterator, GpxTagV11.name);
              break;
            case GpxTagV11.email:
              person.email = _readEmail(iterator);
              break;
            case GpxTagV11.link:
              person.link = _readLink(iterator);
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

  Copyright _readCopyright(Iterator<XmlEvent> iterator) {
    final copyright = Copyright();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      copyright.author = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.author)
          .value;

      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            switch (val.name) {
              case GpxTagV11.year:
                copyright.year =
                    int.parse(_readString(iterator, GpxTagV11.year));
                break;
              case GpxTagV11.license:
                copyright.license = _readString(iterator, GpxTagV11.license);
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

  Bounds _readBounds(Iterator<XmlEvent> iterator) {
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
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTagV11.bounds) {
            break;
          }
        }
      }
    }

    return bounds;
  }

  Email _readEmail(Iterator<XmlEvent> iterator) {
    final email = Email();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      email.id =
          elm.attributes.firstWhere((attr) => attr.name == GpxTagV11.id).value;
      email.domain = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.domain)
          .value;

      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
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
