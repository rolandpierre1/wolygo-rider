import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/address/domain/repositories/address_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';


class AddressRepository implements AddressRepositoryInterface{
  final ApiClient apiClient;
  AddressRepository({required this.apiClient});




  @override
  Future<Response?> add(Address address) async {
    return await apiClient.postData(AppConstants.addNewAddress, address.toJson());
  }

  @override
  Future<Response?> update(Address address, {int? id}) async {
    Map<String, dynamic> fields = {};
    fields.addAll(<String, dynamic>{
      'latitude': address.latitude,
      'longitude' : address.longitude,
      'address': address.address,
      'address_label': address.addressLabel,
      'id': address.id,
      'street': address.street,
      'contact_person_name': address.contactPersonName,
      'contact_person_phone': address.contactPersonPhone,
      'zone_id' : address.zoneId,
      "_method" : "put"
    });
    return await apiClient.postData(AppConstants.updateAddress, fields);
  }


  @override
  Future<Response?> getList({int? offset}) async {
    return await apiClient.getData('${AppConstants.getAddressList}$offset');
  }

  @override
  Future<Response?> delete(String addressId) async {
    return await apiClient.postData(AppConstants.deleteAddress,{
      '_method' : "delete",
      "address_id" : addressId
    });
  }



  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }
}