import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../components/AdComponent.dart';
import '../../components/WebViewScreen.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblAboutUs, textColor: Colors.white, backWidget: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => finish(context))),
      body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (_, snap) {
            if (snap.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(appImages.appLogo, height: 150, width: 150),
                  Text('${snap.data.appName.validate()}', style: boldTextStyle(color: primaryColor, size: 20)),
                  8.height,
                  Text('V ${snap.data.version.validate()}', style: secondaryTextStyle(color: primaryColor)),
                ],
              );
            }
            return SizedBox();
          }).center(),
      bottomNavigationBar: Container(
        height: 190,
        child: Column(
          children: [
            Text(language.lblFollowUs, style: boldTextStyle()),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    var whatsappUrl = "whatsapp://send?phone=${userStore.whatsapp}";
                    launchUrl(Uri.parse(whatsappUrl));
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(appImages.whatsApp, height: 35, width: 35),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (userStore.website_url.isNotEmpty) {
                      push(
                        WebViewScreen(url: userStore.instagram, name: language.website),
                      );
                    } else {
                      toast(language.url_is_Empty);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(appImages.insta, height: 35, width: 35),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (userStore.website_url.isNotEmpty) {
                      push(
                        WebViewScreen(url: userStore.twitter, name: language.website),
                      );
                    } else {
                      toast(language.url_is_Empty);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(appImages.twitter, height: 35, width: 35),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (userStore.website_url.isNotEmpty) {
                      push(
                        WebViewScreen(url: userStore.facebook, name: language.website),
                      );
                    } else {
                      toast(language.url_is_Empty);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(appImages.facebook, height: 35, width: 35),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (userStore.contact.isNotEmpty) {
                      launchUrl(Uri.parse('tel://${userStore.contact.validate()}'));
                    } else {
                      toast(language.url_is_Empty);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.call,
                      color: primaryColor,
                      size: 36,
                    ),
                  ),
                )
              ],
            ),
            userStore.copyright_text.isNotEmpty
                ? Text(userStore.copyright_text, style: primaryTextStyle(letterSpacing: 1.2))
                : Text('${language.lblcopyright} @${DateTime.now().year} MeetMighty', style: primaryTextStyle(letterSpacing: 1.2)),
            // Container(
            //   height: 60,
            //   child: AdWidget(
            //     ad: BannerAd(
            //       adUnitId: getBannerAdUnitId(),
            //       size: AdSize.banner,
            //       request: AdRequest(),
            //       listener: BannerAdListener(),
            //     )..load(),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
