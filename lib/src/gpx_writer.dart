import 'package:xml/xml.dart';

import 'model/gpx.dart';
import 'model/gpx_object.dart';
import 'model/gpx_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/wpt.dart';

/// Convert Gpx into GPX
class GpxWriter {
  /// Convert Gpx into GPX XML (v1.1) as String
  String asString(Gpx gpx, {bool pretty = false}) =>
      _build(gpx).toXmlString(pretty: pretty);

  /// Convert Gpx into GPX XML (v1.1) as XmlNode
  XmlNode asXml(Gpx gpx) => _build(gpx);

  XmlNode _build(Gpx gpx) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(GpxTagV11.gpx, nest: () {
      builder.attribute(GpxTagV11.version, gpx.version);
      builder.attribute(GpxTagV11.creator, gpx.creator);

      if (gpx.metadata != null) {
        _writeMetadata(builder, gpx.metadata!);
      }

      _writeExtensions(builder, gpx.extensions);

      for (final wpt in gpx.wpts) {
        _writePoint(builder, GpxTagV11.wayPoint, wpt);
      }
      for (final rte in gpx.rtes) {
        _writeTrackRoute(builder, rte);
      }
      for (final trk in gpx.trks) {
        _writeTrackRoute(builder, trk);
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
          if (metadata.author?.name != null) {
            _writeElement(builder, GpxTagV11.name, metadata.author?.name);
          }

          if (metadata.author?.email != null) {
            builder.element(GpxTagV11.email, nest: () {
              _writeAttribute(
                  builder, GpxTagV11.id, metadata.author?.email?.id);
              _writeAttribute(
                  builder, GpxTagV11.domain, metadata.author?.email?.domain);
            });
          }

          _writeLinks(builder, [metadata.author?.link]);
        });
      }

      if (metadata.copyright != null) {
        builder.element(GpxTagV11.copyright, nest: () {
          _writeAttribute(
              builder, GpxTagV11.author, metadata.copyright?.author);

          _writeElement(builder, GpxTagV11.year, metadata.copyright?.year);
          _writeElement(
              builder, GpxTagV11.license, metadata.copyright?.license);
        });
      }

      _writeLinks(builder, metadata.links);

      _writeElementWithTime(builder, GpxTagV11.time, metadata.time);

      if (metadata.bounds != null) {
        builder.element(GpxTagV11.bounds, nest: () {
          _writeAttribute(
              builder, GpxTagV11.minLatitude, metadata.bounds?.minlat);
          _writeAttribute(
              builder, GpxTagV11.minLongitude, metadata.bounds?.minlon);
          _writeAttribute(
              builder, GpxTagV11.maxLatitude, metadata.bounds?.maxlat);
          _writeAttribute(
              builder, GpxTagV11.maxLongitude, metadata.bounds?.maxlon);
        });
      }

      _writeExtensions(builder, metadata.extensions);
    });
  }

  void _writeTrackRoute(XmlBuilder builder, GpxObject item) {
    builder.element(item.tag, nest: () {
      _writeElement(builder, GpxTagV11.name, item.name);
      _writeElement(builder, GpxTagV11.desc, item.desc);
      _writeElement(builder, GpxTagV11.comment, item.cmt);
      _writeElement(builder, GpxTagV11.type, item.type);

      _writeElement(builder, GpxTagV11.src, item.src);
      _writeElement(builder, GpxTagV11.number, item.number);

      _writeExtensions(builder, item.extensions);

      if (item is Trk) {
        for (final trkseg in item.trksegs) {
          builder.element(GpxTagV11.trackSegment, nest: () {
            for (final wpt in trkseg.trkpts) {
              _writePoint(builder, GpxTagV11.trackPoint, wpt);
            }

            _writeExtensions(builder, trkseg.extensions);
          });
        }
      } else if (item is Rte) {
        for (final wpt in item.rtepts) {
          _writePoint(builder, GpxTagV11.routePoint, wpt);
        }
      }

      _writeLinks(builder, item.links);
    });
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt? wpt) {
    if (wpt != null) {
      builder.element(tagName, nest: () {
        _writeAttribute(builder, GpxTagV11.latitude, wpt.lat);
        _writeAttribute(builder, GpxTagV11.longitude, wpt.lon);

        _writeElementWithTime(builder, GpxTagV11.time, wpt.time);

        _writeElement(builder, GpxTagV11.elevation, wpt.ele);
        _writeElement(
            builder,
            GpxTagV11.fix,
            wpt.fix
                ?.toString()
                .replaceFirst('FixType.', '')
                .replaceFirst('fix_', ''));
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
        _writeElement(builder, GpxTagV11.sym, wpt.sym);

        _writeExtensions(builder, wpt.extensions);

        _writeLinks(builder, wpt.links);
      });
    }
  }

  void _writeExtensions(XmlBuilder builder, Map<String, String>? value) {
    if (value != null && value.isNotEmpty) {
      builder.element(GpxTagV11.extensions, nest: () {
        value.forEach((k, v) {
          _writeElement(builder, k, v);
        });
      });
    }
  }

  void _writeLinks(XmlBuilder builder, List<Link?>? value) {
    if (value != null) {
      for (final link in value.where((link) => link != null)) {
        builder.element(GpxTagV11.link, nest: () {
          _writeAttribute(builder, GpxTagV11.href, link?.href);

          _writeElement(builder, GpxTagV11.text, link?.text);
          _writeElement(builder, GpxTagV11.type, link?.type);
        });
      }
    }
  }

  void _writeElement(XmlBuilder builder, String tagName, Object? value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeAttribute(XmlBuilder builder, String tagName, Object? value) {
    if (value != null) {
      builder.attribute(tagName, value);
    }
  }

  void _writeElementWithTime(
      XmlBuilder builder, String tagName, DateTime? value) {
    if (value != null) {
      builder.element(tagName, nest: value.toUtc().toIso8601String());
    }
  }
}
