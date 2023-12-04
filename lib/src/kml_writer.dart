import 'package:xml/xml.dart';

import 'model/geo_object.dart';
import 'model/geoxml.dart';
import 'model/gpx_tag.dart';
import 'model/kml_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/polygon.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/wpt.dart';

/// KML 2.2 AltitudeMode values
enum AltitudeMode {
  absolute,
  clampToGround,
  relativeToGround,
}

/// Convert Gpx into KML
class KmlWriter {
  final AltitudeMode altitudeMode;

  KmlWriter({this.altitudeMode = AltitudeMode.absolute});

  String get _altitudeModeString {
    final strVal = altitudeMode.toString();
    return strVal.substring(strVal.indexOf('.') + 1);
  }

  /// Convert Gpx into KML as String
  String asString(GeoXml gpx, {bool pretty = false}) =>
      _build(gpx).toXmlString(pretty: pretty);

  /// Convert Gpx into KML as XmlNode
  XmlNode asXml(GeoXml gpx) => _build(gpx);

  XmlNode _build(GeoXml gpx) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(KmlTag.kml, nest: () {
      builder.attribute('xmlns', 'http://www.opengis.net/kml/2.2');

      if (gpx.trks.any((trk) => trk.trksegs
          .expand((trkseg) => trkseg.trkpts)
          .every((element) => element.time != null))) {
        builder.attribute('xmlns:gx', 'http://www.google.com/kml/ext/2.2');
      }

      builder.element(KmlTag.document, nest: () {
        if (gpx.metadata != null) {
          _writeMetadata(builder, gpx.metadata!);
        }

        for (final wpt in gpx.wpts) {
          _writePoint(builder, KmlTag.placemark, wpt);
        }

        for (final polygon in gpx.polygons) {
          _writePolygon(builder, polygon);
        }

        for (final rte in gpx.rtes) {
          _writeTrackRoute(builder, rte);
        }

        for (final trk in gpx.trks) {
          if (trk.trksegs
              .expand((trkseg) => trkseg.trkpts)
              .any((element) => element.time == null)) {
            _writeTrackRoute(builder, trk);
          } else {
            _writeTrack(builder, trk);
          }
        }
      });
    });

    return builder.buildDocument();
  }

  void _writeMetadata(XmlBuilder builder, Metadata metadata) {
    _writeElement(builder, KmlTag.name, metadata.name);
    _writeElement(builder, KmlTag.desc, metadata.desc);

    if (metadata.author != null) {
      builder.element(KmlTag.author, nest: () {
        _writeElement(builder, KmlTag.authorName, metadata.author?.name);
        if (metadata.author?.email?.id != null &&
            metadata.author?.email?.domain != null) {
          final email =
              '${metadata.author!.email!.id}@${metadata.author!.email!.domain}';
          _writeElement(builder, KmlTag.email, email);
        }

        _writeElement(builder, KmlTag.uri, metadata.author?.link?.href);
      });
    }

    builder.element(KmlTag.extendedData, nest: () {
      _writeExtendedElement(builder, GpxTag.keywords, metadata.keywords);

      if (metadata.time != null) {
        _writeExtendedElement(
            builder, GpxTag.time, metadata.time?.toIso8601String());
      }

      if (metadata.copyright != null) {
        _writeExtendedElement(builder, GpxTag.copyright,
            '${metadata.copyright!.author}, ${metadata.copyright!.year}');
      }
    });
  }

  void _writeTrackRoute(XmlBuilder builder, GeoObject item) {
    builder.element(KmlTag.placemark, nest: () {
      _writeElement(builder, GpxTag.name, item.name);
      _writeElement(builder, GpxTag.desc, item.desc);
      _writeAtomLinks(builder, item.links);

      builder.element(KmlTag.extendedData, nest: () {
        _writeExtendedElement(builder, GpxTag.comment, item.cmt);
        _writeExtendedElement(builder, GpxTag.type, item.type);

        _writeExtendedElement(builder, GpxTag.src, item.src);
        _writeExtendedElement(builder, GpxTag.number, item.number);
      });

      final Iterable<Wpt> wptList;

      if (item is Rte) {
        wptList = item.rtepts;
      } else if (item is Trk) {
        wptList = item.trksegs.expand((trkseg) => trkseg.trkpts);
      } else {
        return;
      }

      final tag = wptList.first.coordinateEqual(wptList.last)
          ? KmlTag.ring
          : KmlTag.track;

      builder.element(tag, nest: () {
        _writeElement(builder, KmlTag.extrude, 1);
        _writeElement(builder, KmlTag.tessellate, 1);
        _writeElement(builder, KmlTag.altitudeMode, _altitudeModeString);

        _writeElement(
            builder,
            KmlTag.coordinates,
            wptList
                .map((wpt) => [wpt.lon, wpt.lat, wpt.ele ?? 0].join(','))
                .join('\n'));
      });
    });
  }

  void _writeTrack(XmlBuilder builder, Trk trk) {
    builder.element(KmlTag.folder, nest: () {
      _writeElement(builder, KmlTag.name, trk.name);
      _writeElement(builder, KmlTag.desc, trk.desc);
      _writeAtomLinks(builder, trk.links);

      builder.element(KmlTag.extendedData, nest: () {
        _writeExtendedElement(builder, GpxTag.comment, trk.cmt);
        _writeExtendedElement(builder, GpxTag.type, trk.type);

        _writeExtendedElement(builder, GpxTag.src, trk.src);
        _writeExtendedElement(builder, GpxTag.number, trk.number);
      });

      for (final seg in trk.trksegs) {
        builder.element(KmlTag.placemark, nest: () {
          // _writeExtendedElement(builder, KmlTag.name, seg.name);

          builder.element(KmlTag.gxTrack, nest: () {
            for (final wpt in seg.trkpts) {
              _writeElement(builder, KmlTag.gxCoord,
                  [wpt.lon, wpt.lat, wpt.ele ?? 0].join(' '));
            }
            for (final wpt in seg.trkpts) {
              _writeElement(
                  builder, KmlTag.when, wpt.time?._toGxString() ?? ' ');
            }
          });
        });
      }
    });
  }

  void _writePolygon(XmlBuilder builder, Polygon polygon) {
    builder.element(KmlTag.placemark, nest: () {
      _writeElement(builder, KmlTag.name, polygon.name);
      _writeElement(builder, KmlTag.desc, polygon.desc);
      _writeAtomLinks(builder, polygon.links);

      // Style the polygon.
      builder.element(KmlTag.style, nest: () {
        builder.element(KmlTag.linestyle, nest: () {
          _writeElement(builder, KmlTag.color,
              polygon.outlineColor.toRadixString(16));
          _writeElement(builder, KmlTag.width, polygon.outlineWidth);
        });
        builder.element(KmlTag.polystyle, nest: () {
          _writeElement(
              builder, KmlTag.color, polygon.fillColor.toRadixString(16));
          _writeElement(builder, KmlTag.outline, 0);
        });
      });

      builder.element(KmlTag.extendedData, nest: () {
        _writeExtendedElement(builder, GpxTag.comment, polygon.cmt);
        _writeExtendedElement(builder, GpxTag.type, polygon.type);

        _writeExtendedElement(builder, GpxTag.src, polygon.src);
        _writeExtendedElement(builder, GpxTag.number, polygon.number);
      });

      builder.element(KmlTag.polygon, nest: () {
        builder.element(KmlTag.outerBoundaryIs, nest: () {
          builder.element(KmlTag.linearRing, nest: () {
            _writeElement(
                builder,
                KmlTag.coordinates,
                polygon.points
                    .map((wpt) => [wpt.lon, wpt.lat].join(','))
                    .join('\n'));
          });
        });
      });
    });
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt wpt) {
    builder.element(tagName, nest: () {
      _writeElement(builder, KmlTag.name, wpt.name);
      _writeElement(builder, KmlTag.desc, wpt.desc);

      _writeElementWithTime(builder, wpt.time);

      _writeAtomLinks(builder, wpt.links);

      builder.element(KmlTag.extendedData, nest: () {
        _writeExtendedElement(builder, GpxTag.magVar, wpt.magvar);

        _writeExtendedElement(builder, GpxTag.sat, wpt.sat);
        _writeExtendedElement(builder, GpxTag.src, wpt.src);

        _writeExtendedElement(builder, GpxTag.hDOP, wpt.hdop);
        _writeExtendedElement(builder, GpxTag.vDOP, wpt.vdop);
        _writeExtendedElement(builder, GpxTag.pDOP, wpt.pdop);

        _writeExtendedElement(builder, GpxTag.geoidHeight, wpt.geoidheight);
        _writeExtendedElement(builder, GpxTag.ageOfData, wpt.ageofdgpsdata);
        _writeExtendedElement(builder, GpxTag.dGPSId, wpt.dgpsid);

        _writeExtendedElement(builder, GpxTag.comment, wpt.cmt);
        _writeExtendedElement(builder, GpxTag.type, wpt.type);
      });

      builder.element(KmlTag.point, nest: () {
        if (wpt.ele != null) {
          _writeElement(builder, KmlTag.altitudeMode, _altitudeModeString);
        }

        _writeElement(builder, KmlTag.coordinates,
            [wpt.lon, wpt.lat, wpt.ele ?? 0].join(','));
      });
    });
  }

  void _writeElement(XmlBuilder builder, String tagName, Object? value) {
    if (value != null) {
      builder.element(tagName, nest: value);
    }
  }

  void _writeAtomLinks(XmlBuilder builder, List<Link> value) {
    for (final link in value) {
      builder.element(KmlTag.link, nest: link.href);
    }
  }

  void _writeExtendedElement(XmlBuilder builder, String tagName, value) {
    if (value != null) {
      builder.element(KmlTag.data, nest: () {
        builder.attribute(KmlTag.name, tagName);
        builder.element(KmlTag.value, nest: value);
      });
    }
  }

  void _writeElementWithTime(XmlBuilder builder, DateTime? value) {
    if (value != null) {
      builder.element(KmlTag.timestamp, nest: () {
        builder.element(KmlTag.when, nest: value.toUtc().toIso8601String());
      });
    }
  }
}

extension _Gx on DateTime {
  String _toGxString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}T'
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}'
      '${isUtc ? 'Z' : ''}';
}
