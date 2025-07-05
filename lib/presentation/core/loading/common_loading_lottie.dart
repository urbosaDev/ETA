import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CommonLoadingLottie extends StatelessWidget {
  const CommonLoadingLottie({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Lottie.asset('assets/lottie/loading.json', fit: BoxFit.contain),
    );
  }
}
