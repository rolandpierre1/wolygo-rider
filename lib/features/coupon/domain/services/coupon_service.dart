import 'package:ride_sharing_user_app/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:ride_sharing_user_app/features/coupon/domain/services/coupon_service_interface.dart';

class CouponService implements CouponServiceInterface{
  CouponRepositoryInterface couponRepositoryInterface;

  CouponService({required this.couponRepositoryInterface});

  @override
  Future getList({int? offset = 1}) async{
    return await couponRepositoryInterface.getList(offset: offset);
  }

  @override
  Future applyCoupon(String couponCode, String tripId) async{
    return await couponRepositoryInterface.applyCoupon(couponCode, tripId);
  }

  @override
  Future removeCoupon(String tripId) async{
    return await couponRepositoryInterface.removeCoupon(tripId);
  }

  @override
  Future customerAppliedCoupon(String couponId) async{
    return await couponRepositoryInterface.customerAppliedCoupon(couponId);
  }

}