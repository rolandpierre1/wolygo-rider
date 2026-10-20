import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/home/domain/repositories/category_repo.dart';


class CategoryController extends GetxController implements GetxService{
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<Category>? categoryList;
  bool isLoading = false;

  Future<void> getCategoryList() async {
    Response? response = await categoryRepo.getCategoryList();
    if(response!.statusCode == 200 && response.body['data'] != null) {
      categoryList = [];
      categoryList!.addAll(CategoryModel.fromJson(response.body).data!);
    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

}
