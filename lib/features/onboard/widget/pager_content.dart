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
      final double textMaxWidth = MediaQuery.of(context).size.width*0.7 - 2*Dimensions.paddingSizeExtraLarge;
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         SizedBox( child: Image.asset(image,height: MediaQuery.of(context).size.height*0.42,)),
         const SizedBox(height: Dimensions.paddingSizeDefault,),
         Flexible(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
             child: FittedBox(
               fit: BoxFit.scaleDown,
               alignment: Alignment.centerLeft,
               child: ConstrainedBox(
                 constraints: BoxConstraints(maxWidth: textMaxWidth),
                 child: Text(text,style: textMedium.copyWith(
                     color: Colors.white,fontSize: 30
                 ),),
               ),
             ),
           ),
         ),

       ],
     );
   }
}
