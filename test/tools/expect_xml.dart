import 'package:test/test.dart';

void expectXml(String xml1, String xml2) {
  final regexp = RegExp(r'\s+|\t+');
  expect(xml1.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      xml2.replaceAll(regexp, '').replaceAll(RegExp(r'\r\n'), '\n'),
      reason: xml1);
}
