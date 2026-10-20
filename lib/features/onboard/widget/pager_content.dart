import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';


class PagerContent extends StatelessWidget {
  const PagerContent({super.key, required this.image, required this.text, required this.index});
  final String image;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    if(index != 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.7,
            height: MediaQuery.of(context).size.height*0.25,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                child: Text(text,style: textMedium.copyWith(
                    color: Colors.white,fontSize: 30
                ),),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: index!=0? Dimensions.paddingSizeLarge:0),
            child: SizedBox( child: Image.asset(image,height: MediaQuery.of(context).size.height*0.5,)),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,)
        ],
      );
    }

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         SizedBox( child: Image.asset(image,height: MediaQuery.of(context).size.height*0.5,)),
         const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
         SizedBox(
           width: MediaQuery.of(context).size.width*0.7,
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
             child: Text(text,style: textMedium.copyWith(
                 color: Colors.white,fontSize: 30
             ),),
           ),
         ),

       ],
     );
   }
}