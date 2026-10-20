import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class CouponRepository implements CouponRepositoryInterface{
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future<Response> getList({int? offset = 1}) async {
    return await apiClient.getData('${AppConstants.couponList}$offset');
  }

  @override
  Future<Response> applyCoupon(String couponCode, String tripId) async {
    return await apiClient.postData(AppConstants.applyCoupon,

        {
          "_method":"put",
          "trip_request_id": tripId,
          "coupon_code" : couponCode
        });
  }

  @override
  Future<Response> removeCoupon(String tripId) async {
    return await apiClient.postData(AppConstants.removeCoupon,

        {
          "_method":"put",
          "trip_request_id": tripId,
        });
  }

  @override
  Future customerAppliedCoupon(String couponId) async{
    return await apiClient.postData(AppConstants.customerAppliedCoupon, {
      "coupon_id": couponId,
      "_method": "post"
    });
  }


  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }


  @override
  Future update(value, {int? id}) {
    // TODO: implement update
    throw UnimplementedError();
  }


}