import 'package:xml/xml_events.dart';

import 'model/copyright.dart';
import 'model/email.dart';
import 'model/gpx.dart';
import 'model/gpx_object.dart';
import 'model/gpx_tag.dart';
import 'model/kml_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/person.dart';
import 'model/rte.dart';
import 'model/wpt.dart';

/// Read Gpx from string
class KmlReader {
//  // @TODO
//  Gpx fromStream(Stream<int> stream) {
//
//  }

  /// Parse xml string and create Gpx object
  Gpx fromString(String xml) {
    final iterator = parseEvents(xml).iterator;

    // ignore: avoid_as
    final gpx = Gpx();
    String? kmlName;
    String? desc;
    Person? author;

    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case KmlTagV22.document:
            break;
          case KmlTagV22.kml:
            break;
          case KmlTagV22.name:
            kmlName = _readString(iterator, val.name);
            break;
          case KmlTagV22.desc:
            desc = _readString(iterator, val.name);
            break;
          case GpxTagV11.desc:
            desc = _readString(iterator, val.name);
            break;
          case KmlTagV22.author:
            author = _readPerson(iterator);
            break;
          case KmlTagV22.extendedData:
            gpx.metadata = _parseMetadata(iterator);
            break;
          case KmlTagV22.placemark:
            final item = _readPlacemark(iterator, val.name);
            if (item is Wpt) {
              gpx.wpts.add(item);
            } else if (item is Rte) {
              gpx.rtes.add(item);
            }
            break;
        }
      }
    }

    if (kmlName != null) {
      gpx.metadata ??= Metadata();
      gpx.metadata!.name = kmlName;
    }

    if (author != null){
      gpx.metadata ??= Metadata();
      gpx.metadata!.author = author;
    }

    if (desc != null){
      gpx.metadata ??= Metadata();
      gpx.metadata!.desc = desc;
    }

    return gpx;
  }

  Metadata _parseMetadata(Iterator<XmlEvent> iterator) {
    final metadata = Metadata();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent && val.name == KmlTagV22.data) {
          for (final attribute in val.attributes){
            if (attribute.name == KmlTagV22.name){
              switch (attribute.value) {
                case KmlTagV22.copyright:
                  metadata.copyright = _readCopyright(iterator);
                  break;
                case KmlTagV22.keywords:
                  metadata.keywords = _readData(iterator, _readString);
                  break;
                case KmlTagV22.time:
                  metadata.time = _readData(iterator, _readDateTime);
                  break;
              }
            }
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTagV22.extendedData) {
          break;
        }
      }
    }

    return metadata;
  }
  
  GpxObject _readPlacemark(Iterator<XmlEvent> iterator, String tagName) {
    final item = GpxObject();
    final elm = iterator.current;
    DateTime? time;
    Wpt? ext;
    Wpt? wpt;
    Rte? rte;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTagV22.name:
              item.name = _readString(iterator, val.name);
              break;
            case KmlTagV22.desc:
              item.desc = _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              item.desc = _readString(iterator, val.name);
              break;
            case KmlTagV22.link:
              final hrefStr = _readString(iterator, val.name);
              if (hrefStr != null){
                item.links.add(Link(href: hrefStr));
              }
              break;
            case KmlTagV22.extendedData:
              ext = _readExtended(iterator);
              break;
            case KmlTagV22.timestamp:
              time = _readData(iterator, _readDateTime,
                  tagName: KmlTagV22.when);
              break;
            case KmlTagV22.point:
              final coorList = _readCoordinate(iterator, val.name);
              if (coorList.length == 1){
                wpt = coorList.first;
              }
              break;
            case KmlTagV22.track:
            case KmlTagV22.ring:
              rte = Rte();
              rte.rtepts = _readCoordinate(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    if (wpt != null){
      wpt.name = item.name;
      wpt.desc = item.desc;
      wpt.links = item.links;
      if (time != null){
        wpt.time = time;
      }

      if (ext != null){
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
    } else if (rte is Rte){
      rte.name = item.name;
      rte.desc = item.desc;
      rte.links = item.links;
      if (time != null){
        for (final wpt in rte.rtepts) {
          wpt.time = time;
        }
      }

      if (ext != null){
        rte.src = ext.src;
        rte.cmt = ext.cmt;
        rte.type = ext.type;
        rte.number = ext.number;
      }

      return rte;
    }

    return item;
  }
  
  double? _readDouble(Iterator<XmlEvent> iterator, String tagName) {
    final doubleString = _readString(iterator, tagName);
    return doubleString != null ? double.parse(doubleString) : null;
  }

  int? _readInt(Iterator<XmlEvent> iterator, String tagName) {
    final intString = _readString(iterator, tagName);
    return intString != null ? int.parse(intString) : null;
  }

  DateTime? _readDateTime(Iterator<XmlEvent> iterator, String tagName) {
    final dateTimeString = _readString(iterator, tagName);
    return dateTimeString != null ? DateTime.parse(dateTimeString) : null;
  }

  String? _readString(Iterator<XmlEvent> iterator, String tagName) {
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

      if (val is XmlCDATAEvent) {
        string += val.text;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    return string.trim();
  }

  T? _readData<T>(Iterator<XmlEvent> iterator,
      T? Function(Iterator<XmlEvent> iterator, String tagName) function,
      {String? tagName}) {
    tagName ??= KmlTagV22.value;

    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            if (val.name == tagName){
              return function(iterator, tagName);
            }

            if (elm.isSelfClosing && val.name == KmlTagV22.data) {
              break;
            }
          }
        }
      }
    }
    return null;
  }

  Wpt _readExtended(Iterator<XmlEvent> iterator) {
    final wpt = Wpt();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent && val.name == KmlTagV22.data) {
          for (final attribute in val.attributes){
            if (attribute.name == KmlTagV22.name){
              switch (attribute.value) {
                case GpxTagV11.magVar:
                  wpt.magvar = _readData(iterator, _readDouble);
                  break;

                case GpxTagV11.sat:
                  wpt.sat = _readData(iterator, _readInt);
                  break;
                case GpxTagV11.src:
                  wpt.src = _readData(iterator, _readString);
                  break;
                  
                case GpxTagV11.hDOP:
                  wpt.hdop = _readData(iterator, _readDouble);
                  break;
                case GpxTagV11.vDOP:
                  wpt.vdop = _readData(iterator, _readDouble);
                  break;
                case GpxTagV11.pDOP:
                  wpt.pdop = _readData(iterator, _readDouble);
                  break;

                case GpxTagV11.geoidHeight:
                  wpt.geoidheight = _readData(iterator, _readDouble);
                  break;
                case GpxTagV11.ageOfData:
                  wpt.ageofdgpsdata = _readData(iterator, _readDouble);
                  break;
                case GpxTagV11.dGPSId:
                  wpt.dgpsid = _readData(iterator, _readInt);
                  break;
                  
                case GpxTagV11.comment:
                  wpt.cmt = _readData(iterator, _readString);
                  break;
                case GpxTagV11.type:
                  wpt.type = _readData(iterator, _readString);
                  break;
                case GpxTagV11.number:
                  wpt.number = _readData(iterator, _readInt);
              }
            }
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTagV22.extendedData) {
          break;
        }
      }
    }

    return wpt;
  }
  
  List<Wpt> _readCoordinate(Iterator<XmlEvent> iterator, String tagName){
    final wpts = <Wpt>[];
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTagV22.altitudeMode:
              break;
            case KmlTagV22.coordinates:
              final coorStr = _readString(iterator, KmlTagV22.coordinates);
              if (coorStr == null){
                break;
              }
              final coorStrList = coorStr.split(' ');
              for (final str in coorStrList){
                final list = str.split(',');
                if (list.length == 3){
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

  Person _readPerson(Iterator<XmlEvent> iterator) {
    final person = Person();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case KmlTagV22.authorName:
              person.name = _readString(iterator, val.name);
              break;
            case KmlTagV22.email:
              person.email = _readEmail(iterator);
              break;
            case KmlTagV22.uri:
              person.link = Link(href: _readString(iterator, val.name) ?? '');
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == KmlTagV22.author) {
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
      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            if (val.name == KmlTagV22.value){
              final copyrightText = _readString(iterator, val.name);
              if (copyrightText != null){
                final copyrightSplit = copyrightText.split(', ');

                if (copyrightSplit.length != 2){
                  throw const FormatException(
                      'Supplied copyright text is not right.');
                } else {
                  copyright.author = copyrightSplit[0];
                  copyright.year = int.parse(copyrightSplit[1]);
                }
              }
            }
          }

          if (val is XmlEndElementEvent && val.name == KmlTagV22.data) {
            break;
          }
        }
      }
    }

    return copyright;
  }

  Email _readEmail(Iterator<XmlEvent> iterator) {
    final email = Email();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      if (elm.name == KmlTagV22.email){
        final emailText = _readString(iterator, KmlTagV22.email);
        if (emailText != null){
          final emailSplit = emailText.split('@');

          if (emailSplit.length != 2){
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

