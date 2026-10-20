abstract class CouponServiceInterface{
  Future<dynamic> getList({int? offset = 1});
  Future<dynamic> applyCoupon(String couponCode, String tripId);
  Future<dynamic> customerAppliedCoupon(String couponId);
  Future<dynamic> removeCoupon(String tripId);
}