library gpx.test.all_test;

import 'package:test/test.dart';

import 'gpx_reader_test.dart' as gpx_reader_test;
import 'gpx_test.dart' as gpx_test;
import 'gpx_writer_test.dart' as gpx_writer_test;
import 'kml_reader_test.dart' as kml_reader_test;
import 'kml_writer_test.dart' as kml_writer_test;

void main() {
  group('gpx', gpx_test.main);
  group('gpx_reader', gpx_reader_test.main);
  group('gpx_writer', gpx_writer_test.main);
  group('kml_reader', kml_reader_test.main);
  group('kml_writer', kml_writer_test.main);
}
