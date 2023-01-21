import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../model/auth/CountryResponse.dart';
import '../../model/auth/ForgotPasswordResponseModel.dart';
import '../../model/auth/LoginResponse.dart';
import '../../model/auth/RegistrationResponse.dart';
import '../../model/auth/UpdateProfileResponse.dart';
import '../../model/auth/UserResponse.dart';
import '../../model/auth/UserUpdateResponse.dart';
import '../../model/cart/CartResponse.dart';
import '../../model/category/CategoryResponse.dart';
import '../../model/dashboard/VendorResponse.dart';
import '../../model/dashboard/AppConfigurationResponse.dart';
import '../../model/dashboard/DashboardResponse.dart';
import '../../model/dashboard/ProductListResponse.dart';
import '../../model/dashboard/TipResponse.dart';
import '../../model/order/OrderResponse.dart';
import '../../model/order/OrderTrackingResponse.dart';
import '../../model/product/ProductResponse.dart';
import '../../model/review/CreateReviewResponse.dart';
import '../../model/review/ReviewResponse.dart';
import '../../model/wishlist/response.dart';
import '../../model/wishlist/WishlistResponse.dart';
import '../../network/NetworkUtils.dart';
import '../../network/PlantApi.dart';
import '../../utils/constants.dart';

class AuthApi {
  Future<RegistrationResponse> signUp({ String firstName,  String lastName,  String userLogin,  String userEmail,  String password}) async {
    Map req = {
      'first_name': firstName.validate(),
      'last_name': lastName.validate(),
      'user_login': userLogin.validate(),
      'user_email': userEmail.validate(),
      'user_pass': password.validate(),
    };
    Response response = await buildHttpResponse('plant-app/api/v1/auth/registration', request: req, method: HttpMethod.POST);

    if (response.statusCode.isSuccessful()) {
      if (response.body.isJson()) {
        var json = jsonDecode(response.body);

        if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
          throw 'invalid_username';
        }
      }
    }

    return await handleResponse(response).then((json) async {
      RegistrationResponse loginResponse = RegistrationResponse.fromJson(json);
      Map<String, dynamic> req = {
        'username': userEmail.validate(),
        'password': password.validate(),
      };
      return await logInApi(req).then((value) async {
        return loginResponse;
      }).catchError((e) {
        throw e.toString();
      });
    }).catchError((e) {
      log(e.toString());
      throw e.toString();
    });
  }

  Future<LoginResponse> logInApi(Map<String, dynamic> request, {bool isSocialLogin = false}) async {
    Response response = await buildHttpResponse(isSocialLogin ? 'plant-app/api/v1/customer/social-login' : 'jwt-auth/v1/token', request: request, method: HttpMethod.POST);
    setValue(sharedPref.isSocial, isSocialLogin);
    if (response.statusCode.isSuccessful()) {
      if (response.body.isJson()) {
        var json = jsonDecode(response.body);

        if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
          throw 'invalid_username';
        }
      }
    }

    return await handleResponse(response).then((value) async {
      LoginResponse loginResponse = LoginResponse.fromJson(value);

      await userStore.setToken(loginResponse.token.validate());
      await userStore.setUserID(loginResponse.user_id.validate());
      await userStore.setUserEmail(loginResponse.user_email.validate());
      await userStore.setFirstName(loginResponse.first_name.validate());
      await userStore.setLastName(loginResponse.last_name.validate());
      await userStore.setUserName(loginResponse.user_display_name.validate());
      await userStore.setUserImage(loginResponse.plantapp_profile_image.validate());
      await userStore.setBillingAddress(loginResponse.billing);
      log("_______________________");
      log(loginResponse.shipping.email);
      await userStore.setShippingAddress(loginResponse.shipping);
      if (request['password'] = null) await userStore.setUserPassword(request['password']);
      await setValue(sharedPref.isRemember, getBoolAsync(sharedPref.isRemember));

      cartStore.init();
      userStore.init();
      wishCartStore.clearWishlist();
      wishCartStore.getWishlistItem();

      String wishListString = getStringAsync(WISHLIST_ITEM_LIST);
      if (wishListString.isNotEmpty) {
        wishCartStore.addAllWishListItem(jsonDecode(wishListString).map<WishlistResponse>((e) => WishlistResponse.fromJson(e)).toList());
      }
      await userStore.setLogin(true);

      return loginResponse;
    });
  }

  Future<AppBaseResponse> forgotPassword(Map req) async {
    return AppBaseResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/customer/forget-password', request: req, method: HttpMethod.POST)));
  }

  Future<AppBaseResponse> changePassword(Map req) async {
    return AppBaseResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/customer/change-password', request: req, method: HttpMethod.POST)));
  }

  Future<List<CountryResponse>> getCountries() async {
    Iterable it = (await handleResponse(await plantApi.getAsync('/wc/v3/data/countries')));
    return it.map((e) => CountryResponse.fromJson(e)).toList();
  }

  Future<UserResponse> getUserData() async {
    return UserResponse.fromJson(await handleResponse(await plantApi.getAsync('/wc/v3/customers/${userStore.userId}', requireToken: false)));
  }

  void logout(BuildContext context) async {
    userStore.setLogin(false);

    userStore.setToken('');
    userStore.setUserID(0);
    log(getBoolAsync(sharedPref.isSocial));
    if (getBoolAsync(sharedPref.isSocial) == true || getBoolAsync(sharedPref.isRemember)) {
      userStore.setUserEmail("");
      userStore.setUserPassword("");
    }
    userStore.setFirstName('');
    userStore.setLastName('');
    userStore.setUserName('');
    userStore.setUserImage('');
    removeKey(sharedPref.isSocial);
    userStore.setShippingAddress(null);
    userStore.setBillingAddress(null);

    cartStore.cartList.clear();
    wishCartStore.clearWishlist();
    productStore.cartProductId.clear();
    cartStore.cartTotalPayableAmount = 0.0;
    cartStore.cartTotalAmount = 0.0;
    cartStore.cartSavedAmount = 0.0;

    finish(context);
  }

  Future<UserUpdateResponse> updateCustomer({ Map<String, dynamic> req, int id}) async {
    return UserUpdateResponse.fromJson(await handleResponse(await plantApi.postAsync('/wc/v3/customers/$id', req, requireToken: true)));
  }

  Future<MultipartRequest> getMultiPartRequest(String endPoint, {String baseUrl}) async {
    String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
    log(url);
    return MultipartRequest('POST', Uri.parse(url));
  }

  Future sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic) onSuccess, Function(dynamic) onError}) async {
    multiPartRequest.headers.addAll(buildHeaderTokens());
    Response res = await Response.fromStream(await multiPartRequest.send());

    log(res.statusCode);
    print("Result: ${res.statusCode}");

    if (res.statusCode.isSuccessful()) {
      onSuccess?.call(res.body);
    } else {
      onError?.call(errorSomethingWentWrong);
    }
  }

  Future updateProfileImage({File file}) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('plant-app/api/v1/customer/save-profile-image');

    if (file = null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      appStore.setLoading(false);
      if (data = null) {
        if ((data as String).isJson()) {
          UpdateProfileResponse res = UpdateProfileResponse.fromJson(jsonDecode(data));
          userStore.setUserImage(res.plantApp_profile_image);
          toast(res.message.toString());
        } else {
          toast('Something went wrong');
        }
      }
    }, onError: (error) {
      toast(error.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  Future<AppBaseResponse> deleteAccount() async {
    return AppBaseResponse.fromJson(await (handleResponse(await buildHttpResponse('plant-app/api/v1/customer/delete-account', method: HttpMethod.POST))));
  }
}

class CategoryApi {
  Future<List<CategoryResponse>> getCategories({int catId = 0}) async {
    Iterable it = (await (handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-sub-category?cat_id=$catId'))));
    return it.map((e) => CategoryResponse.fromJson(e)).toList();
  }

  Future<ProductResponse> getProductListByCategory({int catId = 0}) async {
    Map<String, dynamic> req = {"text": "", "item_type": "", "attribute": [], "price": [], "page": 1, "product_per_page": 15, "category": catId};
    return ProductResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-product', request: req, method: HttpMethod.POST)));
  }

  Future<ProductResponse> getProductListBySection({ Map<String, dynamic> req}) async {
    return ProductResponse.fromJson(await handleResponse(await buildHttpResponse(
      'plant-app/api/v1/woocommerce/get-product',
      request: req,
      method: HttpMethod.POST,
    )));
  }
}

class WishlistApi {
  Future<List<WishlistResponse>> getWishList() async {
    Iterable it = (await (handleResponse(await buildHttpResponse('plant-app/api/v1/wishlist/get-wishlist/'))));
    return it.map((e) => WishlistResponse.fromJson(e)).toList();
  }

  Future<ResponseModel> addToWishList({ int pId}) async {
    Map<String, dynamic> req = {'pro_id': pId};

    return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('plant-app/api/v1/wishlist/add-wishlist/', method: HttpMethod.POST, request: req))));
  }

  Future<ResponseModel> removeFromWishList({ int pId}) async {
    Map<String, dynamic> req = {'pro_id': pId};
    return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('plant-app/api/v1/wishlist/delete-wishlist/', method: HttpMethod.POST, request: req))));
  }
}

class CartApi {
  Future<CartResponse> getCartList() async {
    return CartResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/cart/get-cart', method: HttpMethod.GET)));
  }

  Future<ResponseModel> addToCart({ int pId,  int qty}) async {
    Map<String, dynamic> req = {'pro_id': pId, "quantity": qty};
    return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('plant-app/api/v1/cart/add-cart/', method: HttpMethod.POST, request: req))));
  }

  Future<ResponseModel> removeFromCart({ int pId}) async {
    Map<String, dynamic> req = {'pro_id': pId};
    return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('plant-app/api/v1/cart/delete-cart/', method: HttpMethod.POST, request: req))));
  }

  Future<ResponseModel> updateCartProduct({ String proId,  String cartId, String qty = "1"}) async {
    Map req = {"pro_id": proId, "quantity": qty, "cart_id": cartId};
    return ResponseModel.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/cart/update-cart', request: req, method: HttpMethod.POST)));
  }

  Future<ResponseModel> clearCart() async {
    return ResponseModel.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/cart/clear-cart', method: HttpMethod.POST)));
  }
}

class CheckOutApi {
  Future createOrderApi(req) async {
    return await handleResponse(await plantApi.postAsync('/wc/v3/orders', req, requireToken: true));
  }

  Future createOrderNotes(orderId) async {
    var request = {
      'customer_note': true,
      'note': "{\n" + "\"status\":\"Ordered\",\n" + "\"message\":\"Your order has been placed.\"\n" + "} ",
    };
    return await handleResponse(await plantApi.postAsync('/wc/v3/orders/$orderId/notes', request, requireToken: true));
  }

  Future updateOrder(orderId, Map<String, dynamic> req) async {
    return await handleResponse(await plantApi.postAsync('wp-json/wc/v3/orders/$orderId', req, requireToken: true));
  }

  Future getCheckOutUrl(request) async {
    return await handleResponse(await plantApi.postAsync('/plant-app/api/v1/woocommerce/get-checkout-url', request, auth: true, requireToken: true));
  }

  Future deleteOrder(id1) async {
    return handleResponse(await plantApi.deleteAsync('wc/v3/orders/$id1'));
  }
}

class OrderApi {
  Future<List<OrderResponse>> getOrders() async {
    Iterable it = (await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-customer-orders', method: HttpMethod.GET)));
    return it.map((e) => OrderResponse.fromJson(e)).toList();
  }

  Future cancelOrder({ int orderId, request}) async {
    return handleResponse(await plantApi.postAsync('/wc/v3/orders/$orderId', request));
  }

  Future createOrderNotes(orderId, request) async {
    return handleResponse(await plantApi.postAsync('/wc/v3/orders/$orderId/notes', request));
  }

  Future<List<OrderTrackingResponse>> getOrderTrackingDetail({ int orderId}) async {
    Iterable it = (await handleResponse(await plantApi.getAsync('/wc/v3/orders/$orderId/notes')));
    appStore.setLoading(false);
    return it.map((e) => OrderTrackingResponse.fromJson(e)).toList();
  }
}

class ReviewApi {
  Future<List<ReviewResponse>> getProductReview({ int id}) async {
    Iterable it = (await handleResponse(await plantApi.getAsync('/wc/v3/products/reviews?product=$id')));
    return it.map((e) => ReviewResponse.fromJson(e)).toList();
  }

  Future<CreateReviewResponse> createReviewResponse({ Map<String, dynamic> req}) async {
    return CreateReviewResponse.fromJson(await handleResponse(await plantApi.postAsync('/wc/v3/products/reviews', req)));
  }

  Future<CreateReviewResponse> updateReview({ int id,  Map<String, dynamic> req}) async {
    return CreateReviewResponse.fromJson(await handleResponse(await plantApi.postAsync('/wc/v3/products/reviews/$id', req)));
  }

  Future<CreateReviewResponse> deleteReview({ int id}) async {
    return CreateReviewResponse.fromJson(await handleResponse(await plantApi.deleteAsync('/wc/v3/products/reviews/$id')));
  }
}

class ProductApi {
  Future<ProductResponse> getAllProducts() async {
    return ProductResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-product', method: HttpMethod.GET)));
  }

  Future<ProductResponse> getSearchFilterProducts({String searchText, String itemType}) async {
    Map<String, dynamic> req = {"text": searchText, "item_type": itemType, "attribute": [], "price": [], "page": 1, "product_per_page": 15};
    return ProductResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-product', method: HttpMethod.POST, request: req)));
  }

  Future getProductDetails({ int id}) async {
    return handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-product-details?product_id=$id'));
  }
}

class DashboardApi {
  Future<AppConfigurationResponse> getAppConfiguration() async {
    var it = await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-app-configuration', method: HttpMethod.GET));

    return AppConfigurationResponse.fromJson(it);
  }

  Future<TipResponse> getTips() async {
    return TipResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/blog/get-blog-list?posts_per_page=2&paged=1', method: HttpMethod.GET)));
  }

  Future<ListResponse> getProductList() async {
    return ListResponse.fromJson(await handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-dashboard', method: HttpMethod.GET)));
  }

  Future<List<DashboardResponse>> getCustomDataList() async {
    Iterable it = (await (handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-custom-dashboard'))));
    return it.map((e) => DashboardResponse.fromJson(e)).toList();
  }

  Future<List<DashboardResponse>> getViewALlCustomDataList({ int id}) async {
    Iterable it = (await (handleResponse(await buildHttpResponse('plant-app/api/v1/woocommerce/get-custom-dashboard-slider?slider_id=$id'))));
    return it.map((e) => DashboardResponse.fromJson(e)).toList();
  }
}

class VendorApi {
  Future<List<VendorsResponse>> getVendor() async {
    Iterable list = (await handleResponse(await plantApi.getAsync('/plant-app/api/v1/woocommerce/get-vendors')));
    log("list" + list.toString());
    return list.map((model) => VendorsResponse.fromJson(model)).toList();
  }

  Future<VendorsResponse> getVendorProfile(id) async {
    return VendorsResponse.fromJson(await handleResponse(await plantApi.getAsync('/dokan/v1/stores/$id')));
  }

  Future<List<ProductData>> getVendorProduct(id) async {
    Iterable list = (await handleResponse(await plantApi.getAsync('/plant-app/api/v1/woocommerce/get-vendor-products?vendor_id=$id', requireToken: true)));
    appStore.setLoading(false);
    return list.map((model) => ProductData.fromJson(model)).toList();
  }
}

DashboardApi dashboardApi = DashboardApi();
ProductApi productApi = ProductApi();
CategoryApi categoryApi = CategoryApi();
PlantApi plantApi = PlantApi();
AuthApi authApi = AuthApi();
WishlistApi wishlistApi = WishlistApi();
CartApi cartApi = CartApi();
CheckOutApi checkOutApi = CheckOutApi();
OrderApi orderApi = OrderApi();
ReviewApi reviewApi = ReviewApi();
VendorApi vendorApi = VendorApi();
