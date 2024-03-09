import 'package:xml/xml.dart';

import 'model/geo_object.dart';
import 'model/geo_style.dart';
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

  XmlNode _build(GeoXml geoXml) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(KmlTag.kml, nest: () {
      builder.attribute('xmlns', 'http://www.opengis.net/kml/2.2');

      if (geoXml.trks.any((trk) => trk.trksegs
          .expand((trkseg) => trkseg.trkpts)
          .every((element) => element.time != null))) {
        builder.attribute('xmlns:gx', 'http://www.google.com/kml/ext/2.2');
      }

      builder.element(KmlTag.document, nest: () {
        if (geoXml.metadata != null) {
          _writeMetadata(builder, geoXml.metadata!);
        }

        for (final style in geoXml.styles) {
          _writeStyle(builder, style);
        }

        for (final wpt in geoXml.wpts) {
          _writePoint(builder, wpt, geoXml);
        }

        for (final polygon in geoXml.polygons) {
          _writePolygon(builder, polygon, geoXml);
        }

        for (final rte in geoXml.rtes) {
          _writeTrackRoute(builder, rte, geoXml);
        }

        for (final trk in geoXml.trks) {
          if (trk.trksegs
              .expand((trkseg) => trkseg.trkpts)
              .any((element) => element.time == null)) {
            _writeTrackRoute(builder, trk, geoXml);
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

  void _writeTrackRoute(XmlBuilder builder, GeoObject item, GeoXml geoXml) {
    builder.element(KmlTag.placemark, nest: () {
      _writeElement(builder, GpxTag.name, item.name);
      _writeElement(builder, GpxTag.desc, item.desc);
      _writeAtomLinks(builder, item.links);

      if (item.style != null) {
        if (item.style!.id != null && item.style!.id!.isNotEmpty
            && geoXml.styles.contains(item.style)) {
          _writeElement(builder, KmlTag.styleUrl, '#${item.style!.id}');
        } else {
          _writeStyle(builder, item.style!);
        }
      }

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

  void _writePolygon(XmlBuilder builder, Polygon polygon, GeoXml geoXml) {
    builder.element(KmlTag.placemark, nest: () {
      _writeElement(builder, KmlTag.name, polygon.name);
      _writeElement(builder, KmlTag.desc, polygon.desc);
      _writeAtomLinks(builder, polygon.links);

      // Style the polygon.
      if (polygon.style != null) {
        if (polygon.style!.id != null && polygon.style!.id!.isNotEmpty
            && geoXml.styles.contains(polygon.style)) {
          _writeElement(builder, KmlTag.styleUrl, '#${polygon.style!.id}');
        } else {
          _writeStyle(builder, polygon.style!);
        }
      }

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

  void _writeStyle(XmlBuilder builder, GeoStyle style) {
    builder.element(KmlTag.style,
        attributes: style.id != null ? {KmlTag.id: style.id!} : {}, nest: () {
      if (style.lineStyle != null) {
        builder.element(KmlTag.lineStyle, nest: () {
          _writeColorStyleElements(builder, style.lineStyle);
          _writeElement(builder, KmlTag.width, style.lineStyle?.width);
        });
      }

      if (style.polyStyle != null) {
        builder.element(KmlTag.polyStyle, nest: () {
          _writeColorStyleElements(builder, style.polyStyle);
          _writeElement(builder, KmlTag.fill, style.polyStyle?.fill);
          _writeElement(builder, KmlTag.outline, style.polyStyle?.outline);
        });
      }

      if (style.iconStyle != null) {
        builder.element(KmlTag.iconStyle, nest: () {
          _writeColorStyleElements(builder, style.iconStyle);
          if (style.iconStyle?.iconUrl != null) {
            builder.element(KmlTag.icon, nest: () {
              _writeElement(builder, KmlTag.href, style.iconStyle?.iconUrl);
            });
          }
          _writeElement(builder, KmlTag.scale, style.iconStyle?.scale);
          _writeElement(builder, KmlTag.heading, style.iconStyle?.heading);
          if (style.iconStyle?.x != null &&
          style.iconStyle?.y != null &&
          style.iconStyle?.xunit != null &&
          style.iconStyle?.yunit != null){
            builder.element(KmlTag.hotSpot, attributes: {
              KmlTag.hotSpotX: style.iconStyle!.x!.toString(),
              KmlTag.hotSpotY: style.iconStyle!.y!.toString(),
              KmlTag.xunits: style.iconStyle!.xunit!.name,
              KmlTag.yunits: style.iconStyle!.yunit!.name,
            });
          }
        });
      }

      if (style.labelStyle != null) {
        builder.element(KmlTag.labelStyle, nest: () {
          _writeColorStyleElements(builder, style.labelStyle);
          _writeElement(builder, KmlTag.scale, style.labelStyle?.scale);
        });
      }

      if (style.balloonStyle != null) {
        builder.element(KmlTag.balloonStyle, nest: () {
          _writeElement(builder, KmlTag.bgColor,
              style.balloonStyle!.bgColor.toRadixString(16));
          _writeElement(builder, KmlTag.textColor,
              style.balloonStyle!.textColor.toRadixString(16));
          _writeElement(builder, KmlTag.text,
              style.balloonStyle!.text);
          _writeElement(builder, KmlTag.displayMode,
              style.balloonStyle!.show ? 'default' : 'hide');
        });
      }
    });
  }

  void _writeColorStyleElements(XmlBuilder builder, ColorStyle? colorStyle) {
    if (colorStyle == null) {
      return;
    }
    _writeElement(builder,
        KmlTag.color, colorStyle.color?.toRadixString(16));
    _writeElement(builder,
        KmlTag.colorMode, colorStyle.colorMode?.name);
  }

  void _writePoint(XmlBuilder builder, Wpt wpt, GeoXml geoXml) {
    builder.element(KmlTag.placemark, nest: () {
      _writeElement(builder, KmlTag.name, wpt.name);
      _writeElement(builder, KmlTag.desc, wpt.desc);

      _writeElementWithTime(builder, wpt.time);

      _writeAtomLinks(builder, wpt.links);
      
      if (wpt.style != null) {
        if (wpt.style!.id != null && wpt.style!.id!.isNotEmpty
            && geoXml.styles.contains(wpt.style)) {
          _writeElement(builder, KmlTag.styleUrl, '#${wpt.style!.id}');
        } else {
          _writeStyle(builder, wpt.style!);
        }
      }

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
