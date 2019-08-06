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
  bool operator ==(other) {
    if (other is Wpt) {
      return other.lat == this.lat &&
          other.lon == this.lon &&
          other.ele == this.ele &&
          other.time == this.time &&
          other.magvar == this.magvar &&
          other.geoidheight == this.geoidheight &&
          other.name == this.name &&
          other.cmt == this.cmt &&
          other.desc == this.desc &&
          other.src == this.src &&
          ListEquality().equals(other.links, this.links) &&
          other.sym == this.sym &&
          other.type == this.type &&
          other.fix == this.fix &&
          other.sat == this.sat &&
          other.hdop == this.hdop &&
          other.vdop == this.vdop &&
          other.pdop == this.pdop &&
          other.ageofdgpsdata == this.ageofdgpsdata &&
          other.dgpsid == this.dgpsid;
    }

    return false;
  }

  @override
  String toString() {
    return "Wpt[${[lat, lon, ele, time, name, src].join(",")}]";
  }

  @override
  int get hashCode {
    return hashObjects([
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
}
