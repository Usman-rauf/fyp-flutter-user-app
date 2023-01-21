import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../screens/DashboardScreen.dart';
import '../../utils/CachedNetworkImage.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/images.dart';
import '../../utils/TextGradient.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../main.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  GetStartedScreenState createState() => GetStartedScreenState();
}

class GetStartedScreenState extends State<GetStartedScreen> {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[unSelectedColor, primaryColor],
  ).createShader(
    Rect.fromCenter(width: 16, height: 16, center: Offset(0.5, 1.0)),
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget topWidget() {
    return Container(
      child: Row(
        children: [
          SizedBox(width: context.width() * 0.20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: context.height() * 0.20),
              Container(
                height: context.height() * 0.6,
                width: context.width() * 0.8,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: primaryColor,
                  borderRadius: radiusOnly(topLeft: 32, bottomLeft: 32),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Text(language.WelcomeMsg, style: boldTextStyle(color: Colors.white, size: 20)),
                    4.height,
                    Text(language.Message, style: primaryTextStyle(color: Colors.white.withOpacity(0.5))),
                  ],
                ).paddingAll(16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomWidget() {
    return Row(
      children: [
        SizedBox(width: context.width() * 0.25),
        Column(
          children: [
            Container(
              height: 66,
              width: context.width() * 0.75,
              color: primaryColor,
            ),
            Container(
              height: context.height() * 0.30 - 66,
              width: context.width() * 0.75,
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: primaryColor,
                  borderRadius: radiusOnly(topLeft: 32),
                  decorationImage: DecorationImage(image: AssetImage(appImages.plantBg), fit: BoxFit.cover, colorFilter: ColorFilter.mode(primaryColor, BlendMode.hardLight))),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              topWidget(),
              Positioned(
                left: 0,
                top: -150,
                child: cachedImage(appImages.plant2, height: context.height(), width: 350),
              ),
              Positioned(
                bottom: context.height() * 0.05,
                right: -20,
                top: context.height() * 0.1,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: GradientText(
                    appName.toUpperCase(),
                    style: TextStyle(fontSize: 60),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade500,
                        primaryColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          60.height,
          Row(
            children: [
              SizedBox(width: context.width() * 0.22),
              Container(
                width: context.width(),
                alignment: Alignment.center,
                decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius(24)),
                child: SlideAction(
                  borderRadius: 24,
                  onSubmit: () async {
                    setValue(sharedPref.isFirstTime, false);
                    push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade, duration: 800.milliseconds);
                  },
                  height: 50,
                  sliderButtonIconPadding: 8,
                  text: "Get Started >>>",
                  textStyle: boldTextStyle(color: primaryColor),
                  innerColor: primaryColor,
                  alignment: Alignment.centerRight,
                  outerColor: context.cardColor,
                ),
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
