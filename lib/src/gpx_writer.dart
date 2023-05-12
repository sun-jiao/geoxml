import 'package:xml/xml.dart';

import 'model/geo_object.dart';
import 'model/geoxml.dart';
import 'model/gpx_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/wpt.dart';

/// Convert Gpx into GPX
class GpxWriter {
  /// Convert Gpx into GPX XML (v1.1) as String
  String asString(GeoXml gpx, {bool pretty = false}) =>
      _build(gpx).toXmlString(pretty: pretty);

  /// Convert Gpx into GPX XML (v1.1) as XmlNode
  XmlNode asXml(GeoXml gpx) => _build(gpx);

  XmlNode _build(GeoXml gpx) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(GpxTag.gpx, nest: () {
      builder.attribute(GpxTag.version, gpx.version);
      builder.attribute(GpxTag.creator, gpx.creator);

      if (gpx.metadata != null) {
        _writeMetadata(builder, gpx.metadata!);
      }

      _writeExtensions(builder, gpx.extensions);

      for (final wpt in gpx.wpts) {
        _writePoint(builder, GpxTag.wayPoint, wpt);
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
    builder.element(GpxTag.metadata, nest: () {
      _writeElement(builder, GpxTag.name, metadata.name);
      _writeElement(builder, GpxTag.desc, metadata.desc);

      _writeElement(builder, GpxTag.keywords, metadata.keywords);

      if (metadata.author != null) {
        builder.element(GpxTag.author, nest: () {
          if (metadata.author?.name != null) {
            _writeElement(builder, GpxTag.name, metadata.author?.name);
          }

          if (metadata.author?.email != null) {
            builder.element(GpxTag.email, nest: () {
              _writeAttribute(builder, GpxTag.id, metadata.author?.email?.id);
              _writeAttribute(
                  builder, GpxTag.domain, metadata.author?.email?.domain);
            });
          }

          _writeLinks(builder, [metadata.author?.link]);
        });
      }

      if (metadata.copyright != null) {
        builder.element(GpxTag.copyright, nest: () {
          _writeAttribute(builder, GpxTag.author, metadata.copyright?.author);

          _writeElement(builder, GpxTag.year, metadata.copyright?.year);
          _writeElement(builder, GpxTag.license, metadata.copyright?.license);
        });
      }

      _writeLinks(builder, metadata.links);

      _writeElementWithTime(builder, GpxTag.time, metadata.time);

      if (metadata.bounds != null) {
        builder.element(GpxTag.bounds, nest: () {
          _writeAttribute(builder, GpxTag.minLatitude, metadata.bounds?.minlat);
          _writeAttribute(
              builder, GpxTag.minLongitude, metadata.bounds?.minlon);
          _writeAttribute(builder, GpxTag.maxLatitude, metadata.bounds?.maxlat);
          _writeAttribute(
              builder, GpxTag.maxLongitude, metadata.bounds?.maxlon);
        });
      }

      _writeExtensions(builder, metadata.extensions);
    });
  }

  void _writeTrackRoute(XmlBuilder builder, GeoObject item) {
    builder.element(item.tag, nest: () {
      _writeElement(builder, GpxTag.name, item.name);
      _writeElement(builder, GpxTag.desc, item.desc);
      _writeElement(builder, GpxTag.comment, item.cmt);
      _writeElement(builder, GpxTag.type, item.type);

      _writeElement(builder, GpxTag.src, item.src);
      _writeElement(builder, GpxTag.number, item.number);

      _writeExtensions(builder, item.extensions);

      if (item is Trk) {
        for (final trkseg in item.trksegs) {
          builder.element(GpxTag.trackSegment, nest: () {
            for (final wpt in trkseg.trkpts) {
              _writePoint(builder, GpxTag.trackPoint, wpt);
            }

            _writeExtensions(builder, trkseg.extensions);
          });
        }
      } else if (item is Rte) {
        for (final wpt in item.rtepts) {
          _writePoint(builder, GpxTag.routePoint, wpt);
        }
      }

      _writeLinks(builder, item.links);
    });
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt? wpt) {
    if (wpt != null) {
      builder.element(tagName, nest: () {
        _writeAttribute(builder, GpxTag.latitude, wpt.lat);
        _writeAttribute(builder, GpxTag.longitude, wpt.lon);

        _writeElementWithTime(builder, GpxTag.time, wpt.time);

        _writeElement(builder, GpxTag.elevation, wpt.ele);
        _writeElement(
            builder,
            GpxTag.fix,
            wpt.fix
                ?.toString()
                .replaceFirst('FixType.', '')
                .replaceFirst('fix_', ''));
        _writeElement(builder, GpxTag.magVar, wpt.magvar);

        _writeElement(builder, GpxTag.sat, wpt.sat);
        _writeElement(builder, GpxTag.src, wpt.src);

        _writeElement(builder, GpxTag.hDOP, wpt.hdop);
        _writeElement(builder, GpxTag.vDOP, wpt.vdop);
        _writeElement(builder, GpxTag.pDOP, wpt.pdop);

        _writeElement(builder, GpxTag.geoidHeight, wpt.geoidheight);
        _writeElement(builder, GpxTag.ageOfData, wpt.ageofdgpsdata);
        _writeElement(builder, GpxTag.dGPSId, wpt.dgpsid);

        _writeElement(builder, GpxTag.name, wpt.name);
        _writeElement(builder, GpxTag.desc, wpt.desc);
        _writeElement(builder, GpxTag.comment, wpt.cmt);
        _writeElement(builder, GpxTag.type, wpt.type);
        _writeElement(builder, GpxTag.sym, wpt.sym);

        _writeExtensions(builder, wpt.extensions);

        _writeLinks(builder, wpt.links);
      });
    }
  }

  void _writeExtensions(XmlBuilder builder, Map<String, String>? value) {
    if (value != null && value.isNotEmpty) {
      builder.element(GpxTag.extensions, nest: () {
        value.forEach((k, v) {
          _writeElement(builder, k, v);
        });
      });
    }
  }

  void _writeLinks(XmlBuilder builder, List<Link?>? value) {
    if (value != null) {
      for (final link in value.where((link) => link != null)) {
        builder.element(GpxTag.link, nest: () {
          _writeAttribute(builder, GpxTag.href, link?.href);

          _writeElement(builder, GpxTag.text, link?.text);
          _writeElement(builder, GpxTag.type, link?.type);
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
