String expandColorWithAlpha(String color) {
  final expandedColor = StringBuffer('#');
  if (color.length == 4) {
    // processing hex color abbr as #RGBA
    for (var i = 1; i < color.length; i++) {
      final char = color[i];
      expandedColor.write('$char$char');
    }
    expandedColor.write('00'); // 设置完全透明的Alpha值
    return expandedColor.toString();
  } else if (color.length == 5) {
    // processing hex color abbr as #ARGB
    for (var i = 1; i < color.length; i++) {
      final char = color[i];
      expandedColor.write('$char$char');
    }
    return expandedColor.toString();
  }
  return color;
}

String intToHexStringWithAlpha(int number) {
  var hexString = number.toRadixString(16).toUpperCase();
  if (hexString.length < 8) {
    hexString = '0' * (8 - hexString.length) + hexString;
  }
  return '#$hexString';
}

int hexStringToInt(String hexString) =>
    int.parse(hexString.replaceAll('#', ''), radix: 16);
