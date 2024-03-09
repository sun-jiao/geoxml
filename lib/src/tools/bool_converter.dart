extension Boolean2Int on bool {
  int toInt() => this ? 1 : 0;
}

extension Int2Boolean on int {
  bool toBool() => this == 1;
}
