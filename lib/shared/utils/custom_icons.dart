import 'package:flutter/foundation.dart';

@immutable
class _CustomIconData {
  const _CustomIconData(this._name, this.description);

  static const String _kAssetPath = "assets";
  final String _name;

  String get name => "$_kAssetPath/$_name";
  final String description;
}

@immutable
class CustomIcons {
  const CustomIcons._();
  static const search = _CustomIconData("search.svg", "Search");
}
