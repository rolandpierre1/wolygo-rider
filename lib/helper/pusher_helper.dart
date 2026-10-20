import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/confirmation_trip_dialog.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class PusherHelper {
  static PusherChannelsClient?  pusherClient;
  static initializePusher() async{
    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: Get.find<ConfigController>().config!.webSocketUrl ?? '',
      scheme: Get.find<ConfigController>().config!.websocketScheme == 'https' ? 'wss' : 'ws',
      key: Get.find<ConfigController>().config!.webSocketKey ?? '',
      port: int.parse(Get.find<ConfigController>().config?.webSocketPort ?? '6001'),
    );

    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        Get.find<ConfigController>().setPusherStatus('Disconnected');
        refresh();
      },
    );

    await pusherClient?.connect();

    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;
    if(pusherChannelId != null){
      Get.find<ConfigController>().setPusherStatus('Connected');
    }


    pusherClient?.lifecycleStream.listen((event) {
      Get.find<ConfigController>().setPusherStatus('Disconnected');
    });

  }

/*  static PusherClient? pusherClient;
  static initilizePusher(String? token){

    pusherClient = PusherClient(
        AppConstants.appKey,
         PusherOptions(
          host: Get.find<ConfigController>().config!.webSocketUrl,
          wsPort: int.parse(Get.find<ConfigController>().config!.webSocketPort!),
          wssPort: int.parse(Get.find<ConfigController>().config!.webSocketPort!),
          auth: PusherAuth(
            'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
            headers: {'Authorization': 'Bearer $token'},
          ),
        )
    );

    pusherClient!.connect();

    pusherClient!.onConnectionStateChange((state) {
      log(
        "previousState: ${state?.previousState}, currentState: ${state?.currentState}, socketId: ${pusherClient!.getSocketId()}",
      );

      Get.find<ConfigController>().setPusherStatus(state?.currentState);
    });
  }*/

  late PrivateChannel pusherDriverAccepted;
  late PrivateChannel driverTripStarted;
  late PrivateChannel driverTripCancelled;
  late PrivateChannel driverTripCompleted;
  late PrivateChannel driverPaymentReceived;

  void pusherDriverStatus(String tripId){

    if (Get.find<ConfigController>().pusherConnectionStatus != null || Get.find<ConfigController>().pusherConnectionStatus == 'Connected'){
      pusherDriverAccepted = pusherClient!.privateChannel("private-driver-trip-accepted.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(pusherDriverAccepted.currentStatus ==  null){
        pusherDriverAccepted.subscribe();
        pusherDriverAccepted.bind("driver-trip-accepted.$tripId").listen((event) {
          Get.back();
          Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']).then((value){
            if(value.statusCode == 200){
              if(jsonDecode(event.data!)['type'] == 'parcel'){
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.acceptRider);
                Get.find<RideController>().startLocationRecord();
                Get.find<MapController>().notifyMapController();
                Get.to(() => const MapScreen(fromScreen: MapScreenType.parcel));
              }else{
                Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
                Get.find<RideController>().startLocationRecord();
                Get.find<MapController>().notifyMapController();
                Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
              }
              // pusherClient!.unsubscribe("private-driver-trip-accepted.$tripId");
            }
          });
        });
      }



      driverTripStarted = pusherClient!.privateChannel("private-driver-trip-started.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(driverTripStarted.currentStatus == null){
        driverTripStarted.subscribe();
        driverTripStarted.bind("driver-trip-started.$tripId").listen((event) {
          //   Get.find<MapController>().getPolyline();
          Get.find<RideController>().startLocationRecord();
          if(jsonDecode(event.data!)['type']== 'parcel'){
            Get.find<MapController>().getPolyline();
            Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelOngoing);

            if(Get.find<RideController>().tripDetails == null ){
              Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']).then((value) {
                if (Get.find<RideController>().tripDetails!.parcelInformation!.payer == 'sender') {
                  Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']).then((value) {
                    if (value.statusCode == 200) {
                      //  Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelComplete);
                      Get.find<MapController>().notifyMapController();
                      Get.off(() => const PaymentScreen(fromParcel: true,));
                    }
                  });
                }
              });
            }else{
              if (Get.find<RideController>().tripDetails!.parcelInformation!.payer == 'sender') {
                Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']).then((value) {
                  if (value.statusCode == 200) {
                    //  Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelComplete);
                    Get.find<MapController>().notifyMapController();
                    Get.off(() => const PaymentScreen(fromParcel: true,));
                  }
                });
              }
            }

          }else{
            Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
            Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
          }
          //  pusherClient!.unsubscribe("private-driver-trip-started.$tripId");
        });
      }


      driverTripCancelled = pusherClient!.privateChannel("private-driver-trip-cancelled.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(driverTripCancelled.currentStatus == null){
        driverTripCancelled.subscribe();
        driverTripCancelled.bind("driver-trip-cancelled.$tripId").listen((event) async{
          await Get.find<RideController>().getCurrentRideStatus(fromRefresh: true);
          Get.find<RideController>().stopLocationRecord();
          Get.offAll(const DashboardScreen());
          //  pusherClient!.unsubscribe("private-driver-trip-cancelled.$tripId");
        });
      }



      driverTripCompleted = pusherClient!.privateChannel("private-driver-trip-completed.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(driverTripCompleted.currentStatus ==  null){
        driverTripCompleted.subscribe();
        driverTripCompleted.bind("driver-trip-completed.$tripId").listen((event) {
          if(jsonDecode(event.data!)['type']== 'parcel'){
            Get.find<RideController>().clearRideDetails();
            if(Get.find<ConfigController>().config!.reviewStatus!) {
              Get.off(()=> ReviewScreen(tripId: jsonDecode(event.data!)['id']));
            }else{
              Get.offAll(const DashboardScreen());
            }
          }else{
            Get.dialog(const ConfirmationTripDialog(isStartedTrip: false,), barrierDismissible: false);
            Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']).then((value) {
              if(value.statusCode == 200){
                Get.find<RideController>().updateRideCurrentState(RideState.completeRide);
                Get.find<MapController>().notifyMapController();
                Get.find<RideController>().stopLocationRecord();
                Get.off(()=>const PaymentScreen());
              }
            });
          }
          //  pusherClient!.unsubscribe("private-driver-trip-completed.$tripId");
        });
      }



      driverPaymentReceived = pusherClient!.privateChannel("private-driver-payment-received.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));
      if(driverPaymentReceived.currentStatus == null){
        driverPaymentReceived.subscribe();
        driverPaymentReceived.bind("driver-payment-received.$tripId").listen((event) {
          if(Get.find<ConfigController>().config!.reviewStatus!){
            if(jsonDecode(event.data!)['type']== 'ride_request' && Get.find<ConfigController>().config!.reviewStatus!){
              Get.off(()=> ReviewScreen(tripId: jsonDecode(event.data!)['id']));
            }
            Get.find<RideController>().tripDetails = null;
          }else{
            Get.offAll(()=> const DashboardScreen());
            Get.find<RideController>().tripDetails = null;
          }
          // pusherClient!.unsubscribe("private-driver-payment-received.$tripId");
        });
      }
    }

  }

}