library gpx.test.all_test;

import 'package:test/test.dart';

import 'tests/gpx_reader_stream_test.dart' as gpx_reader_stream_test;
import 'tests/gpx_reader_test.dart' as gpx_reader_test;
import 'tests/gpx_test.dart' as gpx_test;
import 'tests/gpx_writer_test.dart' as gpx_writer_test;
import 'tests/kml_reader_stream_test.dart' as kml_reader_stream_test;
import 'tests/kml_reader_test.dart' as kml_reader_test;
import 'tests/kml_writer_test.dart' as kml_writer_test;

void main() {
  group('gpx', gpx_test.main);
  group('gpx_reader', gpx_reader_test.main);
  group('gpx_reader_from_stream', gpx_reader_stream_test.main);
  group('gpx_writer', gpx_writer_test.main);
  group('kml_reader', kml_reader_test.main);
  group('kml_reader_from_stream', kml_reader_stream_test.main);
  group('kml_writer', kml_writer_test.main);
}
