import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../screens/search/SearchScreen.dart';

class SearchComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: boxDecorationDefault(borderRadius: radius(16),color: context.cardColor, border: Border.all(color: context.dividerColor)),
      width: context.width(),
      child: Text(language.search_Plants+'...', style: secondaryTextStyle()),
    ).onTap(() {
      push(SearchScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
    });
  }
}
