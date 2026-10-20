import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/refund_request/controllers/refund_request_controller.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/features/splash/screens/app_version_warning_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/firebase_helper.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:app_links/app_links.dart';


class SplashScreen extends StatefulWidget {
  final Map<String,dynamic>? notificationData;
  final String? userName;
  const SplashScreen({super.key, this.notificationData, this.userName});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;
  late AnimationController _controller;
  late Animation _animation;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });


    _controller.repeat(max: 1);
    _controller.forward();

    Get.find<ConfigController>().initSharedData();

    _checkConnectivity();
  }

  void _checkConnectivity(){
    bool isFirst = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);
      if(!isFirst || !isConnected) {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(isConnected) {
          _handleIncomingLinks();
        }
      }else{
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        _handleIncomingLinks();
      }
      isFirst = false;
    });
  }


  void _handleIncomingLinks() {
    Get.find<TripController>().getRideCancellationReasonList();
    Get.find<TripController>().getParcelCancellationReasonList();
    Get.find<RefundRequestController>().getParcelRefundReasonList();
    FirebaseHelper().subscribeFirebaseTopic();

    Get.find<ConfigController>().getConfigData().then((value){


      if(_isForceUpdate(Get.find<ConfigController>().config)) {
        Get.offAll(()=> const AppVersionWarningScreen());
      }else{
        _appLinks.getInitialLink().then((Uri? uri) {
          if (uri != null) {
            _handleUri(uri);
          }else{
            _route();
            if(GetPlatform.isIOS){
              _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
                if (uri != null) {
                  _handleUri(uri);
                }
              });
            }
          }
        });
      }

    });

  }


  bool _isForceUpdate(ConfigModel? config) {
    double minimumVersion = Platform.isAndroid
        ? config?.androidAppMinimumVersion ?? 0
        : Platform.isIOS
        ? config?.iosAppMinimumVersion ?? 0
        : 0;

    return minimumVersion > 0 && minimumVersion > AppConstants.appVersion;
  }






  void _handleUri(Uri uri) {
    final String? fromMartPhone = uri.queryParameters['phone'];
    final String? fromMartPassword = uri.queryParameters['password'];
    final String? fromCountryCode = uri.queryParameters['country_code'];
    if(Get.find<AuthController>().getUserToken().isNotEmpty){
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if(value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if(Get.find<ProfileController>().profileModel?.data?.phone == '+${fromCountryCode!.trim()}$fromMartPhone'){
            _route();
          }else{
            Get.find<AuthController>().externalLogin('+${fromCountryCode.trim()}', fromMartPhone!, fromMartPassword!);
          }
        }
      });

    }else{
      Get.find<AuthController>().externalLogin('+${fromCountryCode!.trim()}', fromMartPhone!, fromMartPassword!);
    }
  }

  void _route() async {

    if(Get.find<AuthController>().getUserToken().isNotEmpty){
      PusherHelper.initializePusher();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if(Get.find<AuthController>().isLoggedIn()) {
        forLoginUserRoute();
      }else{
        forNotLoginUserRoute();
      }
    });

  }

  void forNotLoginUserRoute(){
    if(Get.find<ConfigController>().config!.maintenanceMode != null &&
        Get.find<ConfigController>().config!.maintenanceMode!.maintenanceStatus == 1 &&
        Get.find<ConfigController>().config!.maintenanceMode!.selectedMaintenanceSystem!.userApp == 1
    ){
      Get.offAll(() => const MaintenanceScreen());
    }else{
      if (Get.find<ConfigController>().showIntro()) {
        Get.offAll(() => const OnBoardingScreen());
      }else {
        Get.offAll(() => const SignInScreen());
      }
    }
  }

  void forLoginUserRoute(){
    if(widget.notificationData != null) {
      NotificationHelper.notificationRouteCheck(widget.notificationData!, formSplash: true, userName: widget.userName);

    }else if(Get.find<LocationController>().getUserAddress() != null
        && Get.find<LocationController>().getUserAddress()!.address != null
        && Get.find<LocationController>().getUserAddress()!.address!.isNotEmpty) {

      Get.find<ProfileController>().getProfileInfo().then((value) {
        if(value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if(value.body['data']['is_profile_verified'] == 1) {
            Get.find<AuthController>().remainingFindingRideTime();
            Get.offAll(()=> const DashboardScreen());
            // Get.find<RideController>().getCurrentRideStatus();
          }else {
            Get.offAll(() => const EditProfileScreen(fromLogin: true));
          }
        }
      });

    }else{
      Get.offAll(() => const AccessLocationScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
        alignment: Alignment.bottomCenter,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [

          Stack(alignment: AlignmentDirectional.bottomCenter, children: [

            Container(
              transform: Matrix4.translationValues(0, 320 - (320 * double.tryParse(_animation.value.toString())!), 0),
              child: Column(children: [
                Opacity(
                  opacity: _animation.value,
                  child: Padding(
                    padding: EdgeInsets.only(left: 120 - ((120 * double.tryParse(_animation.value.toString())!))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Image.asset(Images.splashLogo,width: 160)),
                  ),
                ),
                const SizedBox(height: 50),
                Image.asset(Images.splashBackgroundOne, width: Get.width, height: Get.height/2, fit: BoxFit.cover)]),
            ),

            Container(
              transform: Matrix4.translationValues(0, 20, 0),
              child: Padding(
                padding:EdgeInsets.symmetric(horizontal:(70 * double.tryParse(_animation.value.toString())!)),
                child: Image.asset(Images.splashBackgroundTwo, width: Get.size.width),
              ),
            ),

          ]),

        ]),
      ),
    );
  }
}
