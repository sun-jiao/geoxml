import 'package:xml/xml.dart';

import 'model/gpx.dart';
import 'model/gpx_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/wpt.dart';

class GpxWriter {
  String asString(Gpx gpx, {bool pretty = false}) =>
      _build(gpx).toXmlString(pretty: pretty);

  XmlNode asXml(Gpx gpx) => _build(gpx);

  XmlNode _build(Gpx gpx) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(GpxTagV11.gpx, nest: () {
      builder.attribute(GpxTagV11.version, gpx.version);
      builder.attribute(GpxTagV11.creator, gpx.creator);

      if (gpx.metadata != null) {
        _writeMetadata(builder, gpx.metadata);
      }

      if (gpx.wpts != null) {
        for (final wpt in gpx.wpts) {
          _writePoint(builder, GpxTagV11.wayPoint, wpt);
        }
      }

      if (gpx.rtes != null) {
        for (final rte in gpx.rtes) {
          _writeRoute(builder, rte);
        }
      }

      if (gpx.trks != null) {
        for (final trk in gpx.trks) {
          _writeTrack(builder, trk);
        }
      }
    });

    return builder.build();
  }

  void _writeMetadata(XmlBuilder builder, Metadata metadata) {
    builder.element(GpxTagV11.metadata, nest: () {
      _writeElementWithText(builder, GpxTagV11.name, metadata.name);
      _writeElementWithText(builder, GpxTagV11.desc, metadata.desc);

      _writeElementWithText(builder, GpxTagV11.keywords, metadata.keywords);

      if (metadata.author != null) {
        builder.element(GpxTagV11.author, nest: () {
          _writeElementWithText(builder, GpxTagV11.name, metadata.author.name);

          if (metadata.author.email != null) {
            builder.element(GpxTagV11.email, nest: () {
              _writeAttribute(builder, GpxTagV11.id, metadata.author.email.id);
              _writeAttribute(
                  builder, GpxTagV11.domain, metadata.author.email.domain);
            });
          }

          _writeLinks(builder, [metadata.author.link]);
        });
      }

      if (metadata.copyright != null) {
        builder.element(GpxTagV11.copyright, nest: () {
          _writeAttribute(builder, GpxTagV11.author, metadata.copyright.author);

          _writeElementWithInt(
              builder, GpxTagV11.year, metadata.copyright.year);
          _writeElementWithText(
              builder, GpxTagV11.license, metadata.copyright.license);
        });
      }

      _writeLinks(builder, metadata.links);

      _writeElementWithTime(builder, GpxTagV11.time, metadata.time);

      if (metadata.bounds != null) {
        builder.element(GpxTagV11.bounds, nest: () {
          _writeAttributeWithDouble(
              builder, GpxTagV11.minLatitude, metadata.bounds.minlat);
          _writeAttributeWithDouble(
              builder, GpxTagV11.minLongitude, metadata.bounds.minlon);
          _writeAttributeWithDouble(
              builder, GpxTagV11.maxLatitude, metadata.bounds.maxlat);
          _writeAttributeWithDouble(
              builder, GpxTagV11.maxLongitude, metadata.bounds.maxlon);
        });
      }
    });
  }

  void _writeRoute(XmlBuilder builder, Rte rte) {
    builder.element(GpxTagV11.route, nest: () {
      _writeElementWithText(builder, GpxTagV11.name, rte.name);
      _writeElementWithText(builder, GpxTagV11.desc, rte.desc);
      _writeElementWithText(builder, GpxTagV11.comment, rte.cmt);
      _writeElementWithText(builder, GpxTagV11.type, rte.type);

      _writeElementWithText(builder, GpxTagV11.src, rte.src);
      _writeElementWithInt(builder, GpxTagV11.number, rte.number);

      for (final wpt in rte.rtepts) {
        _writePoint(builder, GpxTagV11.routePoint, wpt);
      }

      _writeLinks(builder, rte.links);
    });
  }

  void _writeTrack(XmlBuilder builder, Trk trk) {
    builder.element(GpxTagV11.track, nest: () {
      _writeElementWithText(builder, GpxTagV11.name, trk.name);
      _writeElementWithText(builder, GpxTagV11.desc, trk.desc);
      _writeElementWithText(builder, GpxTagV11.comment, trk.cmt);
      _writeElementWithText(builder, GpxTagV11.type, trk.type);

      _writeElementWithText(builder, GpxTagV11.src, trk.src);
      _writeElementWithInt(builder, GpxTagV11.number, trk.number);

      for (final trkseg in trk.trksegs) {
        builder.element(GpxTagV11.trackSegment, nest: () {
          for (final wpt in trkseg.trkpts) {
            _writePoint(builder, GpxTagV11.trackPoint, wpt);
          }
        });
      }

      _writeLinks(builder, trk.links);
    });
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt wpt) {
    if (wpt != null) {
      builder.element(tagName, nest: () {
        _writeAttributeWithDouble(builder, GpxTagV11.latitude, wpt.lat);
        _writeAttributeWithDouble(builder, GpxTagV11.longitude, wpt.lon);

        _writeElementWithTime(builder, GpxTagV11.time, wpt.time);

        _writeElementWithDouble(builder, GpxTagV11.elevation, wpt.ele);
        _writeElementWithDouble(builder, GpxTagV11.magVar, wpt.magvar);

        _writeElementWithInt(builder, GpxTagV11.sat, wpt.sat);
        _writeElementWithText(builder, GpxTagV11.src, wpt.src);

        _writeElementWithDouble(builder, GpxTagV11.hDOP, wpt.hdop);
        _writeElementWithDouble(builder, GpxTagV11.vDOP, wpt.vdop);
        _writeElementWithDouble(builder, GpxTagV11.pDOP, wpt.pdop);

        _writeElementWithDouble(
            builder, GpxTagV11.geoidHeight, wpt.geoidheight);
        _writeElementWithDouble(
            builder, GpxTagV11.ageOfData, wpt.ageofdgpsdata);
        _writeElementWithInt(builder, GpxTagV11.dGPSId, wpt.dgpsid);

        _writeElementWithText(builder, GpxTagV11.name, wpt.name);
        _writeElementWithText(builder, GpxTagV11.desc, wpt.desc);
        _writeElementWithText(builder, GpxTagV11.comment, wpt.cmt);
        _writeElementWithText(builder, GpxTagV11.type, wpt.type);

        _writeLinks(builder, wpt.links);
      });
    }
  }

  void _writeLinks(XmlBuilder builder, List<Link> value) {
    if (value != null) {
      for (final link in value.where((link) => link != null)) {
        builder.element(GpxTagV11.link, nest: () {
          _writeAttribute(builder, GpxTagV11.href, link.href);

          _writeElementWithText(builder, GpxTagV11.name, link.text);
          _writeElementWithText(builder, GpxTagV11.type, link.type);
        });
      }
    }
  }

  void _writeElementWithText(XmlBuilder builder, String tagName, String value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeElementWithTime(
      XmlBuilder builder, String tagName, DateTime value) {
    if (value != null) {
      builder.element(tagName, nest: value.toUtc().toIso8601String());
    }
  }

  void _writeElementWithInt(XmlBuilder builder, String tagName, int value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeElementWithDouble(
      XmlBuilder builder, String tagName, double value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeAttribute(XmlBuilder builder, String tagName, String value) {
    if (value != null) {
      builder.attribute(tagName, value);
    }
  }

  void _writeAttributeWithDouble(
      XmlBuilder builder, String tagName, double value) {
    if (value != null) {
      builder.attribute(tagName, value);
    }
  }
}
