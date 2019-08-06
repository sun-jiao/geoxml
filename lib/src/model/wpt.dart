import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

import 'link.dart';

enum FixType { fix_2d, fix_3d, dgps, none, pps }

// @TODO add extensions;
class Wpt {
  double lat;
  double lon;
  double ele;
  DateTime time;
  double magvar;
  double geoidheight;
  String name;
  String cmt;
  String desc;
  String src;
  List<Link> links;
  String sym;
  String type;
  FixType fix;
  int sat;
  double hdop;
  double vdop;
  double pdop;
  double ageofdgpsdata;
  int dgpsid;

  Wpt({
    this.lat = 0.0,
    this.lon = 0.0,
    this.ele,
    this.time,
    this.magvar,
    this.geoidheight,
    this.name,
    this.cmt,
    this.desc,
    this.src,
    List<Link> links,
    this.sym,
    this.type,
    this.fix,
    this.sat,
    this.hdop,
    this.vdop,
    this.pdop,
    this.ageofdgpsdata,
    this.dgpsid,
  }) : links = links ?? [];

  @override
  bool operator ==(other) { // ignore: type_annotate_public_apis
    if (other is Wpt) {
      return other.lat == lat &&
          other.lon == lon &&
          other.ele == ele &&
          other.time == time &&
          other.magvar == magvar &&
          other.geoidheight == geoidheight &&
          other.name == name &&
          other.cmt == cmt &&
          other.desc == desc &&
          other.src == src &&
          const ListEquality().equals(other.links, links) &&
          other.sym == sym &&
          other.type == type &&
          other.fix == fix &&
          other.sat == sat &&
          other.hdop == hdop &&
          other.vdop == vdop &&
          other.pdop == pdop &&
          other.ageofdgpsdata == ageofdgpsdata &&
          other.dgpsid == dgpsid;
    }

    return false;
  }

  @override
  String toString() => "Wpt[${[lat, lon, ele, time, name, src].join(",")}]";

  @override
  int get hashCode => hashObjects([
      lat,
      lon,
      ele,
      time,
      magvar,
      geoidheight,
      name,
      cmt,
      desc,
      src,
      links,
      sym,
      type,
      fix,
      sat,
      hdop,
      vdop,
      pdop,
      ageofdgpsdata,
      dgpsid
    ]);
}
