import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AppLoader.dart';
import '../../screens/SignIn/LoginRequiredWidget.dart';
import '../../main.dart';
import '../../model/order/OrderResponse.dart';
import '../../network/RestApi.dart';
import '../../screens/orders/component/NoOrdersComponent.dart';
import '../../screens/orders/component/OrderItemWidget.dart';
import '../../screens/orders/OrderDetailScreen.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
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
      appBar: appBarWidget(language.your_Orders, textColor: Colors.white,backWidget: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => finish(context))),
      body: userStore.isLoggedIn
          ? FutureBuilder<List<OrderResponse>>(
              future: orderApi.getOrders(),
              builder: (context, snap) {
                if (snap.hasData) {
                  if (snap.data.isEmpty) {
             //      return NoDataWidget(title: language.you_have_not_yet_ordered_anything);
                  }
                  return Stack(
                    children: [
                      AnimationLimiter(
                        child: ListView.separated(
                          itemCount: snap.data.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            OrderResponse data = snap.data[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: 600.milliseconds,
                              child: SlideAnimation(
                                horizontalOffset: 8.0,
                                verticalOffset: 10.0,
                                duration: 600.milliseconds,
                                child: OrderItemWidget(data: data).onTap(
                                  () async {
                                    bool res= await OrderDetailScreen(data: data).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 800.milliseconds);
                                    if(res==true)
                                      setState(() { });
                                  },
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(height: 0);
                          },
                        ).paddingAll(8),
                      ),
                      NoOrdersComponent().center().visible(false),
                    ],
                  );
                }
                return snapWidgetHelper(snap, loadingWidget: AppLoader().center());
              })
          : LoginRequiredWidget(title: language.orders),
    );
  }
}
