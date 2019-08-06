library gpx.test.all_test;

import 'package:test/test.dart';

import 'gpx_test.dart' as gpx_test;
import 'reader_test.dart' as reader_test;
import 'writer_test.dart' as writer_test;

void main() {
  group('gpx', gpx_test.main);
  group('reader', reader_test.main);
  group('writer', writer_test.main);
}
