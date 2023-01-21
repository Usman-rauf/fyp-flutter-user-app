import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';

class AppNoDataWidget extends StatelessWidget {
  final String title;

  AppNoDataWidget({this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        16.height,
        Container(
          padding: EdgeInsets.all(8),
          decoration: boxDecorationDefault(
            shape: BoxShape.circle,
            boxShadow: defaultBoxShadow(spreadRadius: 0, blurRadius: 0),
            color: primaryColor.withOpacity(0.2),
          ),
          child: Image.asset(appImages.appLogo, height: 80),
        ),
        16.height,
        Text(title ?? language.no_Data, style: secondaryTextStyle()),
      ],
    ).center();
  }
}
