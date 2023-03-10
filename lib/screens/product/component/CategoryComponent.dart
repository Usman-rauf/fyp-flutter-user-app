import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../model/category/CategoryResponse.dart';
import '../../../model/product/ProductDetailResponse.dart';
import '../../../screens/category/SubCategoryProductScreen.dart';
import '../../../utils/CachedNetworkImage.dart';

class CategoryComponent extends StatelessWidget {
  final List<Category> categoryData;

  CategoryComponent({ this.categoryData});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text(language.category, style: boldTextStyle()),
          16.height,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              categoryData.length,
              (index) {
                return Column(
                  children: [
                    Container(
                      decoration: boxDecorationDefault(color: Color(0xD658D63),shape: BoxShape.circle),
                      padding: EdgeInsets.all(6),
                      child: cachedImage(categoryData[index].image, height: 56, width: 56,fit: BoxFit.cover).cornerRadiusWithClipRRect(28),
                    ),
                    8.height,
                    Text('${categoryData[index].name}', style: boldTextStyle(size: 12)),
                  ],
                ).onTap(
                  () {
                    push(
                      SubCategoryProductScreen(parentCategory: CategoryResponse(name: categoryData[index].name, term_id: categoryData[index].id, image: categoryData[index].image, slug: categoryData[index].slug)),
                      pageRouteAnimation: PageRouteAnimation.Fade,
                      duration: 800.milliseconds,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
