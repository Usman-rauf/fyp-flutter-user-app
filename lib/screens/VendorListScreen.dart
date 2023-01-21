import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AppLoader.dart';
import '../../model/dashboard/VendorResponse.dart';
import '../../network/RestApi.dart';
import '../../utils/colors.dart';

import '../main.dart';
import 'VendorDetailScreen.dart';
import 'dashboard/component/VendorComponent.dart';

class VendorListScreen extends StatefulWidget {
  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
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
      appBar: appBarWidget(language.lblVendor, color: primaryColor, textColor: Colors.white,backWidget: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => finish(context))),
      body: FutureBuilder<List<VendorsResponse>>(
        future: vendorApi.getVendor(),
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data.isNotEmpty) {
              return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: snap.data.length,
                  itemBuilder: (context, i) {
                    VendorsResponse data = snap.data[i];
                    return getVendorWidget(data, context, width: context.width()).onTap(() {
                      VendorDetailScreen(data.id).launch(context);
                    });
                  });
            }
          }
          return snapWidgetHelper(snap, loadingWidget: AppLoader(), errorWidget: Offstage());
        },
      ),
    );
  }
}
