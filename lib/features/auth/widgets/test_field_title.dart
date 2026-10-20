import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TextFieldTitle extends StatelessWidget {
  final String title;
  final double textOpacity;
  const TextFieldTitle({super.key, required this.title,this.textOpacity=0.5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:const EdgeInsets.fromLTRB(0,15,0,10),
      child: Text(title,
        style: textMedium.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(textOpacity),
        ),
      ),
    );
  }
}
