import 'package:ride_sharing_user_app/interface/repository_interface.dart';

abstract class CouponRepositoryInterface implements RepositoryInterface{
  Future<dynamic> applyCoupon(String couponCode, String tripId);
  Future<dynamic> customerAppliedCoupon(String couponId);
  Future<dynamic> removeCoupon(String tripId);
}