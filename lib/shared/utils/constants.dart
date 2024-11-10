import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_icons.dart';

class Constants {
  static Widget search = SvgPicture.asset(
    CustomIcons.search.name,
    semanticsLabel: CustomIcons.search.description,
    height: 26,
    width: 26,
  );

  closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
