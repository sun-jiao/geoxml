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

  Gpx fromString(String xml) {
    var parserIt = parseEvents(xml).iterator;

    while (parserIt.moveNext()) {
      var val = parserIt.current;

      if (val is XmlStartElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }
    }

    var gpxTag = parserIt.current as XmlStartElementEvent;
    var gpx = Gpx();

    gpx.version = gpxTag.attributes.firstWhere((attr) => attr.name == GpxTagV11.version).value;
    gpx.creator = gpxTag.attributes.firstWhere((attr) => attr.name == GpxTagV11.creator).value;

    while (parserIt.moveNext()) {
      var val = parserIt.current;
      if (val is XmlEndElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case GpxTagV11.metadata:
            gpx.metadata = _parseMetadata(parserIt);
            break;
          case GpxTagV11.wayPoint:
            gpx.wpts.add(_readPoint(parserIt, GpxTagV11.wayPoint));
            break;
          case GpxTagV11.route:
            gpx.rtes.add(_parseRoute(parserIt));
            break;
          case GpxTagV11.track:
            gpx.trks.add(_parseTrack(parserIt));
            break;

          case GpxTagV11.extensions:
            // @TODO implement gpx extensions
            break;
        }
      }
    }

    return gpx;
  }

  Metadata _parseMetadata(Iterator<XmlEvent> iterator) {
    var metadata = Metadata();

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

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
              metadata.time = DateTime.parse(_readString(iterator, GpxTagV11.time));
              break;
            case GpxTagV11.keywords:
              metadata.keywords = _readString(iterator, GpxTagV11.keywords);
              break;
            case GpxTagV11.bounds:
              metadata.bounds = _readBounds(iterator);
              break;
            case GpxTagV11.extensions:
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
    var rte = Rte();

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

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
    var trk = Trk();

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

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
    var wpt = Wpt();

    wpt.lat = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.latitude)
        .value);
    wpt.lon = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.longitude)
        .value);

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            // TODO add tags
            // wpt.ageofdgpsdata
            // wpt.geoidheight
            // wpt.dgpsid
            // wpt.fix
            // wpt.sym

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

            case GpxTagV11.magVar:
              wpt.magvar = double.parse(_readString(iterator, GpxTagV11.magVar));
              break;

            case GpxTagV11.sat:
              wpt.sat = int.parse(_readString(iterator, GpxTagV11.sat));
              break;

            case GpxTagV11.elevation:
              wpt.ele = double.parse(_readString(iterator, GpxTagV11.elevation));
              break;
            case GpxTagV11.time:
              wpt.time = DateTime.parse(_readString(iterator, GpxTagV11.time));
              break;
            case GpxTagV11.type:
              wpt.type = _readString(iterator, GpxTagV11.type);
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
    if (!(iterator.current is XmlStartElementEvent && (iterator.current as XmlStartElementEvent).name == tagName)) {
      return null;
    }

    var string = "";
    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlTextEvent) {
          string += val.text;
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return string;
  }

  Trkseg _readSegment(Iterator<XmlEvent> iterator) {
    Trkseg trkseg = Trkseg();

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.trackPoint:
              trkseg.trkpts.add(_readPoint(iterator, GpxTagV11.trackPoint));
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

  Link _readLink(Iterator<XmlEvent> iterator) {
    Link link = Link();

    link.href =
        (iterator.current as XmlStartElementEvent).attributes.firstWhere((attr) => attr.name == GpxTagV11.href).value;

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

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
    Person person = Person();

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

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
    Copyright copyright = Copyright();

    copyright.author =
        (iterator.current as XmlStartElementEvent).attributes.firstWhere((attr) => attr.name == GpxTagV11.author).value;

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.year:
              copyright.year = int.parse(_readString(iterator, GpxTagV11.year));
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

    return copyright;
  }

  Bounds _readBounds(Iterator<XmlEvent> iterator) {
    Bounds bounds = Bounds();

    bounds.minlat = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.minLatitude)
        .value);
    bounds.minlon = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.minLongitude)
        .value);
    bounds.maxlat = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.maxLatitude)
        .value);
    bounds.maxlon = double.parse((iterator.current as XmlStartElementEvent)
        .attributes
        .firstWhere((attr) => attr.name == GpxTagV11.maxLongitude)
        .value);

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlEndElementEvent && val.name == GpxTagV11.bounds) {
          break;
        }
      }
    }

    return bounds;
  }

  Email _readEmail(Iterator<XmlEvent> iterator) {
    Email email = Email();

    email.id =
        (iterator.current as XmlStartElementEvent).attributes.firstWhere((attr) => attr.name == GpxTagV11.id).value;
    email.domain =
        (iterator.current as XmlStartElementEvent).attributes.firstWhere((attr) => attr.name == GpxTagV11.domain).value;

    if (!(iterator.current as XmlStartElementEvent).isSelfClosing) {
      while (iterator.moveNext()) {
        var val = iterator.current;

        if (val is XmlEndElementEvent && val.name == GpxTagV11.email) {
          break;
        }
      }
    }

    return email;
  }
}
