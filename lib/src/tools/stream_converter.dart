import 'dart:async';

import 'package:xml/xml_events.dart';

Stream<XmlEvent> toXmlStream(Stream<String> source) async* {
  final listStream = source.toXmlEvents();

  // Wait until a new chunk is available, then process it.
  await for (final chunk in listStream) {
    for (final event in chunk) {
      yield event; // Add events to output stream.
    }
  }
}
