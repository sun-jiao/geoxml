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

      _writeExtensions(builder, gpx.extensions);

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

    return builder.buildDocument();
  }

  void _writeMetadata(XmlBuilder builder, Metadata metadata) {
    builder.element(GpxTagV11.metadata, nest: () {
      _writeElement(builder, GpxTagV11.name, metadata.name);
      _writeElement(builder, GpxTagV11.desc, metadata.desc);

      _writeElement(builder, GpxTagV11.keywords, metadata.keywords);

      if (metadata.author != null) {
        builder.element(GpxTagV11.author, nest: () {
          _writeElement(builder, GpxTagV11.name, metadata.author.name);

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

          _writeElement(builder, GpxTagV11.year, metadata.copyright.year);
          _writeElement(builder, GpxTagV11.license, metadata.copyright.license);
        });
      }

      _writeLinks(builder, metadata.links);

      _writeElementWithTime(builder, GpxTagV11.time, metadata.time);

      if (metadata.bounds != null) {
        builder.element(GpxTagV11.bounds, nest: () {
          _writeAttribute(
              builder, GpxTagV11.minLatitude, metadata.bounds.minlat);
          _writeAttribute(
              builder, GpxTagV11.minLongitude, metadata.bounds.minlon);
          _writeAttribute(
              builder, GpxTagV11.maxLatitude, metadata.bounds.maxlat);
          _writeAttribute(
              builder, GpxTagV11.maxLongitude, metadata.bounds.maxlon);
        });
      }

      _writeExtensions(builder, metadata.extensions);
    });
  }

  void _writeRoute(XmlBuilder builder, Rte rte) {
    builder.element(GpxTagV11.route, nest: () {
      _writeElement(builder, GpxTagV11.name, rte.name);
      _writeElement(builder, GpxTagV11.desc, rte.desc);
      _writeElement(builder, GpxTagV11.comment, rte.cmt);
      _writeElement(builder, GpxTagV11.type, rte.type);

      _writeElement(builder, GpxTagV11.src, rte.src);
      _writeElement(builder, GpxTagV11.number, rte.number);

      _writeExtensions(builder, rte.extensions);

      for (final wpt in rte.rtepts) {
        _writePoint(builder, GpxTagV11.routePoint, wpt);
      }

      _writeLinks(builder, rte.links);
    });
  }

  void _writeTrack(XmlBuilder builder, Trk trk) {
    builder.element(GpxTagV11.track, nest: () {
      _writeElement(builder, GpxTagV11.name, trk.name);
      _writeElement(builder, GpxTagV11.desc, trk.desc);
      _writeElement(builder, GpxTagV11.comment, trk.cmt);
      _writeElement(builder, GpxTagV11.type, trk.type);

      _writeElement(builder, GpxTagV11.src, trk.src);
      _writeElement(builder, GpxTagV11.number, trk.number);

      _writeExtensions(builder, trk.extensions);

      for (final trkseg in trk.trksegs) {
        builder.element(GpxTagV11.trackSegment, nest: () {
          for (final wpt in trkseg.trkpts) {
            _writePoint(builder, GpxTagV11.trackPoint, wpt);
          }

          _writeExtensions(builder, trkseg.extensions);
        });
      }

      _writeLinks(builder, trk.links);
    });
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt wpt) {
    if (wpt != null) {
      builder.element(tagName, nest: () {
        _writeAttribute(builder, GpxTagV11.latitude, wpt.lat);
        _writeAttribute(builder, GpxTagV11.longitude, wpt.lon);

        _writeElementWithTime(builder, GpxTagV11.time, wpt.time);

        _writeElement(builder, GpxTagV11.elevation, wpt.ele);
        _writeElement(builder, GpxTagV11.magVar, wpt.magvar);

        _writeElement(builder, GpxTagV11.sat, wpt.sat);
        _writeElement(builder, GpxTagV11.src, wpt.src);

        _writeElement(builder, GpxTagV11.hDOP, wpt.hdop);
        _writeElement(builder, GpxTagV11.vDOP, wpt.vdop);
        _writeElement(builder, GpxTagV11.pDOP, wpt.pdop);

        _writeElement(builder, GpxTagV11.geoidHeight, wpt.geoidheight);
        _writeElement(builder, GpxTagV11.ageOfData, wpt.ageofdgpsdata);
        _writeElement(builder, GpxTagV11.dGPSId, wpt.dgpsid);

        _writeElement(builder, GpxTagV11.name, wpt.name);
        _writeElement(builder, GpxTagV11.desc, wpt.desc);
        _writeElement(builder, GpxTagV11.comment, wpt.cmt);
        _writeElement(builder, GpxTagV11.type, wpt.type);

        _writeExtensions(builder, wpt.extensions);

        _writeLinks(builder, wpt.links);
      });
    }
  }

  void _writeExtensions(XmlBuilder builder, Map<String, String> value) {
    if (value != null && value.isNotEmpty) {
      builder.element(GpxTagV11.extensions, nest: () {
        value.forEach((k, v) {
          _writeElement(builder, k, v);
        });
      });
    }
  }

  void _writeLinks(XmlBuilder builder, List<Link> value) {
    if (value != null) {
      for (final link in value.where((link) => link != null)) {
        builder.element(GpxTagV11.link, nest: () {
          _writeAttribute(builder, GpxTagV11.href, link.href);

          _writeElement(builder, GpxTagV11.text, link.text);
          _writeElement(builder, GpxTagV11.type, link.type);
        });
      }
    }
  }

  void _writeElement(XmlBuilder builder, String tagName, value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeAttribute(XmlBuilder builder, String tagName, value) {
    if (value != null) {
      builder.attribute(tagName, value);
    }
  }

  void _writeElementWithTime(
      XmlBuilder builder, String tagName, DateTime value) {
    if (value != null) {
      builder.element(tagName, nest: value.toUtc().toIso8601String());
    }
  }
}
