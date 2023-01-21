import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AppLoader.dart';
import '../../main.dart';
import '../../model/dashboard/AppConfigurationResponse.dart';
import '../../network/RestApi.dart';
import '../../screens/category/component/CategoryComponent.dart';
import '../../screens/dashboard/component/SearchComponent.dart';
import '../../screens/dashboard/CustomDashboardScreen.dart';
import '../../screens/dashboard/DefaultDashboardScreen.dart';
import '../../screens/dashboard/TipListScreen.dart';

import 'component/SliderComponent.dart';
import 'component/VendorComponent.dart';
import 'component/TipComponent.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<AppConfigurationResponse> mConfiguration;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mConfiguration = dashboardApi.getAppConfiguration();
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await 2.seconds.delay;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<AppConfigurationResponse>(
                    future: dashboardApi.getAppConfiguration(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        afterBuildCreated(() {
                          if (appStore.isLoading) {
                            appStore.setLoading(false);
                          }
                        });
                        userStore.setEnableCustomDashboard(snap.data.enable_custom_dashboard);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            SearchComponent().paddingSymmetric(horizontal: 16),
                            16.height,
                            TipComponent().paddingSymmetric(horizontal: 16).onTap(() {
                              push(TipListScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                            8.height,
                            if(snap.data.banner!=null && snap.data.banner.isNotEmpty)
                              SliderComponent(data: snap.data),
                            16.height,
                            Text(language.categories, style: boldTextStyle(size: 20)).paddingSymmetric(horizontal: 16),
                            AnimationLimiter(
                              child: HorizontalList(
                                itemCount: snap.data.category.length,
                                spacing: 16,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    delay: 200.milliseconds,
                                    duration: const Duration(milliseconds: 600),
                                    child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: CategoryComponent(value: snap.data.category[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            mVendorWidget(context, snap.data.vendors),
                          ],
                        );
                      }
                      return snapWidgetHelper(snap, loadingWidget: SizedBox(), errorWidget: Offstage());
                    },
                  ),
                  16.height,
                  userStore.enableCustomDashboard ? CustomDashboardScreen() : DefaultDashboardScreen()
                ],
              ),
            ),
            Observer(builder: (context) {
              return AppLoader().center().visible(appStore.isLoading);
            })
          ],
        ),
      ),
    );
  }
}
