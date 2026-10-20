import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/onboard/controllers/on_board_page_controller.dart';
import 'package:ride_sharing_user_app/features/onboard/widget/pager_content.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController()..addListener(_handlePageChanged);
  late final ValueNotifier<int> _currentPage = ValueNotifier(0)..addListener(() => setState(() {}));

  late AnimationController _controller;
  late Animation _animation;

  final List<Widget> pages = AppConstants.onBoardPagerData.map((data) => PagerContent(
    image: data.image,
    text: data.title,
    index: AppConstants.onBoardPagerData.indexOf(data),
  )).toList();


  @override
  void initState() {

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to free resources
    _pageController.dispose(); // Dispose PageController as well if not used elsewhere
    super.dispose();
  }



  void _handlePageChanged() {
    int newPage = _pageController.page?.round() ?? 0;
    _currentPage.value = newPage;
  }

  void _handleSemanticSwipe(int dir) {
    _pageController.animateToPage((_pageController.page ?? 0).round() + dir,
        duration: const Duration(milliseconds: 1), curve: Curves.easeOut);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [

        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Theme.of(context).colorScheme.onPrimary, Theme.of(context).primaryColor],)),
          child: GetBuilder<OnBoardController>(builder: (onBoardController) {
            return Column(children: [

              Expanded(child: MergeSemantics(
                child: Semantics(
                  onIncrease: () => _handleSemanticSwipe(1),
                  onDecrease: () => _handleSemanticSwipe(-1),
                  child: Stack(
                    children: [

                      if(onBoardController.pageIndex != 3) Positioned(bottom: 100, right: 0, left: -100, child: SizedBox(
                        width: 1200,
                        height: 300 + (300 * double.tryParse(_animation.value.toString())!),
                        child: Image.asset(
                          Images.splashBackgroundOne,
                          fit: BoxFit.fitHeight,
                          alignment: onBoardController.pageIndex == 0
                              ? Alignment.centerLeft
                              : onBoardController.pageIndex == 1
                              ? Alignment.centerRight
                              : Alignment.center,
                        ),
                      )),

                      PageView(
                        controller: _pageController,
                        children: pages,
                        onPageChanged: (value) {
                          onBoardController.onPageChanged(value);
                          _controller.reset(); // Reset the animation to start over
                          _controller.forward(); // Start the animation
                        },
                      ),

                    ],
                  ),
                ),
              )),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: onBoardController.pageIndex == 3
                    ? const _GetStartedButtonWidget()
                    : _NavigationButtonWidget(pageController: _pageController),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

            ]);
          }),
        )],
      ),
    );
  }

}

class _GetStartedButtonWidget extends StatelessWidget {
  const _GetStartedButtonWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: ButtonWidget(
        transparent: true,
        textColor: Theme.of(context).cardColor,
        showBorder: true,
        radius: 100,
        borderColor: Theme.of(context).cardColor.withOpacity(0.5),
        buttonText: 'get_started'.tr,
        onPressed: () {
          Get.find<ConfigController>().disableIntro();
          Get.offAll(() => const SignInScreen());
        },
      ),
    );
  }
}


class _NavigationButtonWidget extends StatelessWidget {
  final PageController pageController;
  const _NavigationButtonWidget({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: Dimensions.paddingSizeDefault),

        IconButton(
          onPressed: () {
            if (AppConstants.onBoardPagerData.length - 1 == Get.find<OnBoardController>().pageIndex) {
              Get.find<ConfigController>().disableIntro();
              Get.offAll(() => const SignInScreen());
            } else {
              pageController.nextPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              );
            }
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white60),
        ),
        SizedBox(width: Get.width * 0.2),

        TextButton(
          onPressed: () {
            Get.find<ConfigController>().disableIntro();
            Get.offAll(() => const SignInScreen());
          },
          child: Text(
            'skip'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.white60,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
      ],
    );
  }
}

