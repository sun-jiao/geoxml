import 'dart:async';

import 'package:xml/xml_events.dart';

import 'model/copyright.dart';
import 'model/email.dart';
import 'model/geo_object.dart';
import 'model/geoxml.dart';
import 'model/gpx_tag.dart';
import 'model/kml_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/person.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/trkseg.dart';
import 'model/wpt.dart';
import 'tools/stream_converter.dart';

/// Read Gpx from string
class KmlReader {
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
    // ignore: avoid_as
    final gpx = GeoXml();
    String? kmlName;
    String? desc;
    Person? author;

    while (await iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case KmlTag.document:
            break;
          case KmlTag.kml:
            break;
          case KmlTag.name:
            kmlName = await _readString(iterator, val.name);
            break;
          case KmlTag.desc:
            desc = await _readString(iterator, val.name);
            break;
          case GpxTag.desc:
            desc = await _readString(iterator, val.name);
            break;
          case KmlTag.author:
            author = await _readPerson(iterator);
            break;
          case KmlTag.extendedData:
            gpx.metadata = await _parseMetadata(iterator);
            break;
          case KmlTag.placemark:
            final item = await _readPlacemark(iterator, val.name);
            if (item is Wpt) {
              gpx.wpts.add(item);
            } else if (item is Rte) {
              gpx.rtes.add(item);
            }
            break;
          case KmlTag.folder:
            gpx.trks.add(await _readFolder(iterator, val.name));
            break;
        }
      }
    }

    if (kmlName != null) {
      gpx.metadata ??= Metadata();
      gpx.metadata!.name = kmlName;
    }

    if (author != null) {
      gpx.metadata ??= Metadata();
      gpx.metadata!.author = author;
    }

    if (desc != null) {
      gpx.metadata ??= Metadata();
      gpx.metadata!.desc = desc;
    }

    return gpx;
  }

  Future<Metadata> _parseMetadata(StreamIterator<XmlEvent> iterator) async {
    final metadata = Metadata();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent && val.name == KmlTag.data) {
          for (final attribute in val.attributes) {
            if (attribute.name == KmlTag.name) {
              switch (attribute.value) {
                case KmlTag.copyright:
                  metadata.copyright = await _readCopyright(iterator);
                  break;
                case KmlTag.keywords:
                  metadata.keywords = await _readData(iterator, _readString);
                  break;
                case KmlTag.time:
                  metadata.time = await _readData(iterator, _readDateTime);
                  break;
              }
            }
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTag.extendedData) {
          break;
        }
      }
    }

    return metadata;
  }

  Future<GeoObject> _readPlacemark(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final item = GeoObject();
    final elm = iterator.current;
    DateTime? time;
    Wpt? ext;
    Wpt? wpt;
    Rte? rte;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.name:
              item.name = await _readString(iterator, val.name);
              break;
            case KmlTag.desc:
              item.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              item.desc = await _readString(iterator, val.name);
              break;
            case KmlTag.link:
              final hrefStr = await _readString(iterator, val.name);
              if (hrefStr != null) {
                item.links.add(Link(href: hrefStr));
              }
              break;
            case KmlTag.extendedData:
              ext = await _readExtended(iterator);
              break;
            case KmlTag.timestamp:
              time = await _readData(iterator, _readDateTime,
                  tagName: KmlTag.when);
              break;
            case KmlTag.point:
              final coorList = await _readCoordinate(iterator, val.name);
              if (coorList.length == 1) {
                wpt = coorList.first;
              }
              break;
            case KmlTag.track:
            case KmlTag.ring:
              rte = Rte();
              rte.rtepts = await _readCoordinate(iterator, val.name);
              break;
            case KmlTag.gxTrack:
              rte = await _readGxTrack(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    if (wpt != null) {
      wpt.name = item.name;
      wpt.desc = item.desc;
      wpt.links = item.links;
      if (time != null) {
        wpt.time = time;
      }

      if (ext != null) {
        wpt.magvar = ext.magvar;
        wpt.sat = ext.sat;
        wpt.src = ext.src;
        wpt.hdop = ext.hdop;
        wpt.vdop = ext.vdop;
        wpt.pdop = ext.pdop;
        wpt.geoidheight = ext.geoidheight;
        wpt.ageofdgpsdata = ext.ageofdgpsdata;
        wpt.dgpsid = ext.dgpsid;
        wpt.cmt = ext.cmt;
        wpt.type = ext.type;
        wpt.number = ext.number;
      }

      return wpt;
    } else if (rte is Rte) {
      rte.name = item.name;
      rte.desc = item.desc;
      rte.links = item.links;
      if (time != null) {
        for (final wpt in rte.rtepts) {
          wpt.time = time;
        }
      }

      if (ext != null) {
        rte.src = ext.src;
        rte.cmt = ext.cmt;
        rte.type = ext.type;
        rte.number = ext.number;
      }

      return rte;
    }

    return item;
  }

  Future<Trk> _readFolder(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final trk = Trk();
    final elm = iterator.current;
    Wpt? ext;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.name:
              trk.name = await _readString(iterator, val.name);
              break;
            case KmlTag.desc:
              trk.desc = await _readString(iterator, val.name);
              break;
            case GpxTag.desc:
              trk.desc = await _readString(iterator, val.name);
              break;
            case KmlTag.link:
              final hrefStr = await _readString(iterator, val.name);
              if (hrefStr != null) {
                trk.links.add(Link(href: hrefStr));
              }
              break;
            case KmlTag.extendedData:
              ext = await _readExtended(iterator);
              break;
            case KmlTag.placemark:
              final item = await _readPlacemark(iterator, val.name);
              if (item is Wpt) {
                if (trk.trksegs.isEmpty) {
                  trk.trksegs.add(Trkseg());
                }
                trk.trksegs.last.trkpts.add(item);
              } else if (item is Rte) {
                trk.trksegs.add(Trkseg(trkpts: item.rtepts));
              }
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    if (ext != null) {
      trk.src = ext.src;
      trk.cmt = ext.cmt;
      trk.type = ext.type;
      trk.number = ext.number;
    }

    return trk;
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

    return string.trim();
  }

  Future<T?> _readData<T>(
      StreamIterator<XmlEvent> iterator,
      Future<T?> Function(StreamIterator<XmlEvent> iterator, String tagName)
          function,
      {String? tagName}) async {
    tagName ??= KmlTag.value;

    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            if (val.name == tagName) {
              return function(iterator, tagName);
            }

            if (elm.isSelfClosing && val.name == KmlTag.data) {
              break;
            }
          }
        }
      }
    }
    return null;
  }

  Future<Wpt> _readExtended(StreamIterator<XmlEvent> iterator) async {
    final wpt = Wpt();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent && val.name == KmlTag.data) {
          for (final attribute in val.attributes) {
            if (attribute.name == KmlTag.name) {
              switch (attribute.value) {
                case GpxTag.magVar:
                  wpt.magvar = await _readData(iterator, _readDouble);
                  break;

                case GpxTag.sat:
                  wpt.sat = await _readData(iterator, _readInt);
                  break;
                case GpxTag.src:
                  wpt.src = await _readData(iterator, _readString);
                  break;

                case GpxTag.hDOP:
                  wpt.hdop = await _readData(iterator, _readDouble);
                  break;
                case GpxTag.vDOP:
                  wpt.vdop = await _readData(iterator, _readDouble);
                  break;
                case GpxTag.pDOP:
                  wpt.pdop = await _readData(iterator, _readDouble);
                  break;

                case GpxTag.geoidHeight:
                  wpt.geoidheight = await _readData(iterator, _readDouble);
                  break;
                case GpxTag.ageOfData:
                  wpt.ageofdgpsdata = await _readData(iterator, _readDouble);
                  break;
                case GpxTag.dGPSId:
                  wpt.dgpsid = await _readData(iterator, _readInt);
                  break;

                case GpxTag.comment:
                  wpt.cmt = await _readData(iterator, _readString);
                  break;
                case GpxTag.type:
                  wpt.type = await _readData(iterator, _readString);
                  break;
                case GpxTag.number:
                  wpt.number = await _readData(iterator, _readInt);
              }
            }
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTag.extendedData) {
          break;
        }
      }
    }

    return wpt;
  }

  Future<Rte> _readGxTrack(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final wpts = <Wpt>[];
    final whens = <DateTime>[];
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.when:
              final dateTime = await _readDateTime(iterator, val.name);
              if (dateTime != null) {
                whens.add(dateTime);
              }
              break;
            case KmlTag.gxCoord:
              final coorStr = await _readString(iterator, val.name);
              if (coorStr == null) {
                break;
              }
              final list = coorStr.split(' ');
              if (list.length == 3) {
                final wpt = Wpt();
                wpt.lon = double.parse(list[0]);
                wpt.lat = double.parse(list[1]);
                wpt.ele = double.parse(list[2]);
                wpts.add(wpt);
              }
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    if (wpts.length != whens.length) {
      throw const FormatException(
          'Kml file format is not right. The number of <when> elements in a '
          '<Track> must be equal to the number of <gx:coord> elements');
    }

    whens.asMap().forEach((index, when) {
      wpts[index].time = when;
    });

    return Rte(rtepts: wpts);
  }

  Future<List<Wpt>> _readCoordinate(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final wpts = <Wpt>[];
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.altitudeMode:
              break;
            case KmlTag.coordinates:
              final coorStr = await _readString(iterator, KmlTag.coordinates);
              if (coorStr == null) {
                break;
              }
              final coorStrList = coorStr.split(' ');
              for (final str in coorStrList) {
                final list = str.split(',');
                if (list.length == 3) {
                  final wpt = Wpt();
                  wpt.lon = double.parse(list[0]);
                  wpt.lat = double.parse(list[1]);
                  wpt.ele = double.parse(list[2]);
                  wpts.add(wpt);
                }
              }
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return wpts;
  }

  Future<Person> _readPerson(StreamIterator<XmlEvent> iterator) async {
    final person = Person();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.authorName:
              person.name = await _readString(iterator, val.name);
              break;
            case KmlTag.email:
              person.email = await _readEmail(iterator);
              break;
            case KmlTag.uri:
              person.link =
                  Link(href: await _readString(iterator, val.name) ?? '');
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTag.author) {
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
      if (!elm.isSelfClosing) {
        while (await iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            if (val.name == KmlTag.value) {
              final copyrightText = await _readString(iterator, val.name);
              if (copyrightText != null) {
                final copyrightSplit = copyrightText.split(', ');

                if (copyrightSplit.length != 2) {
                  throw const FormatException(
                      'Supplied copyright text is not right.');
                } else {
                  copyright.author = copyrightSplit[0];
                  copyright.year = int.parse(copyrightSplit[1]);
                }
              }
            }
          }

          if (val is XmlEndElementEvent && val.name == KmlTag.data) {
            break;
          }
        }
      }
    }

    return copyright;
  }

  Future<Email> _readEmail(StreamIterator<XmlEvent> iterator) async {
    final email = Email();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      if (elm.name == KmlTag.email) {
        final emailText = await _readString(iterator, KmlTag.email);
        if (emailText != null) {
          final emailSplit = emailText.split('@');

          if (emailSplit.length != 2) {
            throw const FormatException(
                'Supplied email address is not in the right format.');
          } else {
            email.id = emailSplit[0];
            email.domain = emailSplit[1];
          }
        }
      }
    }

    return email;
  }
}
