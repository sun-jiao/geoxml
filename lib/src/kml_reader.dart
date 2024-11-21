import 'dart:async';

import 'package:xml/xml_events.dart';

import 'model/copyright.dart';
import 'model/email.dart';
import 'model/geo_object.dart';
import 'model/geo_style.dart';
import 'model/geoxml.dart';
import 'model/gpx_tag.dart';
import 'model/kml_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/person.dart';
import 'model/polygon.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/trkseg.dart';
import 'model/wpt.dart';
import 'tools/bool_converter.dart';
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
    final geoXml = GeoXml();
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
            geoXml.metadata = await _parseMetadata(iterator);
            break;
          case KmlTag.placemark:
            final item = await _readPlacemark(iterator, val.name, geoXml);
            if (item is Wpt) {
              geoXml.wpts.add(item);
            } else if (item is Rte) {
              geoXml.rtes.add(item);
            } else if (item is Polygon) {
              geoXml.polygons.add(item);
            }
            break;
          case KmlTag.folder:
            geoXml.trks.add(await _readFolder(iterator, val.name, geoXml));
            break;
          case KmlTag.style:
            geoXml.styles.add(await _readStyle(iterator, val.name));
            break;
        }
      }
    }

    if (kmlName != null) {
      geoXml.metadata ??= Metadata();
      geoXml.metadata!.name = kmlName;
    }

    if (author != null) {
      geoXml.metadata ??= Metadata();
      geoXml.metadata!.author = author;
    }

    if (desc != null) {
      geoXml.metadata ??= Metadata();
      geoXml.metadata!.desc = desc;
    }

    return geoXml;
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

  String _convertHtmlToText(String input) {
    input = input.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    final htmlTagRegex = RegExp(r'<[^>]*>');
    return input.replaceAll(htmlTagRegex, '').trim();
  }

  Future<GeoObject> _readPlacemark(
      StreamIterator<XmlEvent> iterator, String tagName, GeoXml geoXml) async {
    final item = GeoObject();
    final elm = iterator.current;
    GeoStyle? style;
    DateTime? time;
    bool? tessellate;
    Wpt? ext;
    Wpt? wpt;
    Rte? rte;
    Polygon? polygon;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.name:
              item.name = await _readString(iterator, val.name);
              break;
            case KmlTag.desc:
              final rawDesc = await _readString(iterator, val.name);
              item.desc = rawDesc != null ? _convertHtmlToText(rawDesc) : null;
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
            case KmlTag.polygon:
              polygon = Polygon();
              break;
            case KmlTag.extrude:
              item.extrude = (await _readInt(iterator, val.name))?.toBool();
              break;
            case KmlTag.tessellate:
              tessellate = (await _readInt(iterator, val.name))?.toBool();
              break;
            case KmlTag.altitudeMode:
              item.altitudeMode =
                  await _readEnum(iterator, val.name, AltitudeMode.values);
              break;
            case KmlTag.outerBoundaryIs:
              polygon = polygon ?? Polygon();
              polygon.outerBoundaryIs = Rte();
              polygon.outerBoundaryIs.rtepts =
                  await _readCoordinate(iterator, val.name);
              break;
            case KmlTag.innerBoundaryIs:
              polygon = polygon ?? Polygon();
              polygon.innerBoundaryIs.addAll(
                  (await _readCoordinates(iterator, val.name))
                      .map((e) => Rte(rtepts: e)));
              break;
            case KmlTag.style:
              style = await _readStyle(iterator, val.name);
              break;
            case KmlTag.styleUrl:
              var styleUrl = await _readString(iterator, val.name);
              if (styleUrl != null && style == null) {
                if (styleUrl.startsWith('#')) {
                  styleUrl = styleUrl.substring(1);
                }

                style = geoXml.styles.firstWhere(
                  (element) => element.id == styleUrl,
                  orElse: GeoStyle.new,
                );
              }
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
      wpt.extrude = item.extrude;
      wpt.altitudeMode = item.altitudeMode;
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

      wpt.style = style;

      return wpt;
    } else if (polygon is Polygon) {
      polygon.name = item.name;
      polygon.desc = item.desc;
      polygon.links = item.links;
      polygon.extrude = item.extrude;
      polygon.tessellate = tessellate;
      polygon.altitudeMode = item.altitudeMode;
      if (time != null) {
        for (final wpt in polygon.outerBoundaryIs.rtepts) {
          wpt.time = time;
        }
      }

      if (time != null) {
        for (final rte in polygon.innerBoundaryIs) {
          for (final wpt in rte.rtepts) {
            wpt.time = time;
          }
        }
      }

      if (ext != null) {
        polygon.src = ext.src;
        polygon.cmt = ext.cmt;
        polygon.type = ext.type;
        polygon.number = ext.number;
      }

      polygon.style = style;

      return polygon;
    } else if (rte is Rte) {
      rte.name = item.name;
      rte.desc = item.desc;
      rte.links = item.links;
      rte.extrude = item.extrude;
      rte.tessellate = tessellate;
      rte.altitudeMode = item.altitudeMode;
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

      rte.style = style;

      return rte;
    }

    item.style = style;

    return item;
  }

  Future<Trk> _readFolder(
      StreamIterator<XmlEvent> iterator, String tagName, GeoXml geoXml) async {
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
              final item = await _readPlacemark(iterator, val.name, geoXml);
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

  Future<int?> _readInt(StreamIterator<XmlEvent> iterator, String tagName,
      [int radix = 10]) async {
    final intString = await _readString(iterator, tagName);
    return intString != null ? int.parse(intString, radix: radix) : null;
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
        string += val.value;
      }

      if (val is XmlCDATAEvent) {
        string += val.value;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    return string.trim();
  }

  Future<T?> _readEnum<T extends Enum>(
      StreamIterator<XmlEvent> iterator, String tagName, List<T> values) async {
    final name = await _readString(iterator, tagName);
    if (name == null) {
      return null;
    }
    return values.firstWhere((e) => e.name == name);
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
              } else {
                if (list.length == 3) {
                  final wpt = Wpt();
                  wpt.lon = double.parse(list[0]);
                  wpt.lat = double.parse(list[1]);
                  wpt.ele = 0;
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

  Future<List<List<Wpt>>> _readCoordinates(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final coords = <List<Wpt>>[];
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.altitudeMode:
              break;
            case KmlTag.coordinates:
              coords.add(await _readCoordinate(iterator, val.name));
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return coords;
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
                } else if (list.length == 2) {
                  final wpt = Wpt();
                  wpt.lon = double.parse(list[0]);
                  wpt.lat = double.parse(list[1]);
                  wpt.ele = 0;
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

  Future<GeoStyle> _readStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final style = GeoStyle();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      for (final attribute in elm.attributes) {
        if (attribute.name == KmlTag.id) {
          style.id = attribute.value;
        }
      }

      while (await iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.lineStyle:
              style.lineStyle = await _readLineStyle(iterator, val.name);
              break;
            case KmlTag.polyStyle:
              style.polyStyle = await _readPolyStyle(iterator, val.name);
              break;
            case KmlTag.iconStyle:
              style.iconStyle = await _readIconStyle(iterator, val.name);
              break;
            case KmlTag.labelStyle:
              style.labelStyle = await _readLabelStyle(iterator, val.name);
              break;
            case KmlTag.balloonStyle:
              style.balloonStyle = await _readBalloonStyle(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return style;
  }

  Future<LineStyle> _readLineStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final lineStyle = LineStyle();
    final elm = iterator.current;
    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;
        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.color:
              lineStyle.color = await _readInt(iterator, val.name, 16);
              break;
            case KmlTag.colorMode:
              lineStyle.colorMode =
                  await _readEnum(iterator, val.name, ColorMode.values);
              break;
            case KmlTag.width:
              lineStyle.width = await _readDouble(iterator, val.name);
          }
        }
        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }
    return lineStyle;
  }

  Future<PolyStyle> _readPolyStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final polyStyle = PolyStyle();
    final elm = iterator.current;
    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;
        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.color:
              polyStyle.color = await _readInt(iterator, val.name, 16);
              break;
            case KmlTag.colorMode:
              polyStyle.colorMode =
                  await _readEnum(iterator, val.name, ColorMode.values);
              break;
            case KmlTag.fill:
              polyStyle.fill = (await _readInt(iterator, val.name))?.toBool();
              break;
            case KmlTag.outline:
              polyStyle.outline =
                  (await _readInt(iterator, val.name))?.toBool();
              break;
          }
        }
        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }
    return polyStyle;
  }

  Future<IconStyle> _readIconStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final iconStyle = IconStyle();
    final elm = iterator.current;
    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;
        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.color:
              iconStyle.color = await _readInt(iterator, val.name, 16);
              break;
            case KmlTag.colorMode:
              iconStyle.colorMode =
                  await _readEnum(iterator, val.name, ColorMode.values);
              break;
            case KmlTag.scale:
              iconStyle.scale = await _readDouble(iterator, val.name);
              break;
            case KmlTag.heading:
              iconStyle.heading = await _readDouble(iterator, val.name);
              break;
            case KmlTag.icon:
              while (await iterator.moveNext()) {
                final val = iterator.current;
                if (val is XmlStartElementEvent && val.name == KmlTag.href) {
                  iconStyle.iconUrl = await _readString(iterator, val.name);
                }
                if (val is XmlEndElementEvent && val.name == KmlTag.icon) {
                  break;
                }
              }
              break;
            case KmlTag.hotSpot:
              for (final attribute in val.attributes) {
                switch (attribute.name) {
                  case KmlTag.hotSpotX:
                    iconStyle.x = double.tryParse(attribute.value);
                    break;
                  case KmlTag.hotSpotY:
                    iconStyle.y = double.tryParse(attribute.value);
                    break;
                  case KmlTag.xunits:
                    iconStyle.xunit = HotspotUnits.values.firstWhere(
                        (element) => element.name == attribute.value);
                    break;
                  case KmlTag.yunits:
                    iconStyle.yunit = HotspotUnits.values.firstWhere(
                        (element) => element.name == attribute.value);
                    break;
                }
              }
          }
        }
        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }
    return iconStyle;
  }

  Future<LabelStyle> _readLabelStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final labelStyle = LabelStyle();
    final elm = iterator.current;
    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;
        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.color:
              labelStyle.color = await _readInt(iterator, val.name, 16);
              break;
            case KmlTag.colorMode:
              labelStyle.colorMode =
                  await _readEnum(iterator, val.name, ColorMode.values);
              break;
            case KmlTag.scale:
              labelStyle.scale = await _readDouble(iterator, val.name);
              break;
          }
        }
        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }
    return labelStyle;
  }

  Future<BalloonStyle> _readBalloonStyle(
      StreamIterator<XmlEvent> iterator, String tagName) async {
    final balloonStyle = BalloonStyle();
    final elm = iterator.current;
    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (await iterator.moveNext()) {
        final val = iterator.current;
        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTag.bgColor:
              balloonStyle.bgColor = await _readInt(iterator, val.name, 16) ??
                  balloonStyle.bgColor;
              break;
            case KmlTag.textColor:
              balloonStyle.textColor = await _readInt(iterator, val.name, 16) ??
                  balloonStyle.textColor;
              break;
            case KmlTag.text:
              balloonStyle.text = await _readString(iterator, val.name) ?? '';
              break;
            case KmlTag.displayMode:
              balloonStyle.show =
                  await _readString(iterator, val.name) == 'default';
              break;
          }
        }
        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }
    return balloonStyle;
  }
}
