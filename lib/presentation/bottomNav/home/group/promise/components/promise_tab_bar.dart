import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/calculate_distance_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/late/late_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/status/promise_status_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/status/promise_status_view_model.dart';

class PromiseTabBar extends StatelessWidget {
  final String promiseId;
  const PromiseTabBar({super.key, required this.promiseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabButton('정보', () {
            Get.to(
              () => const PromiseInfoView(),
              arguments: promiseId,
              binding: BindingsBuilder(() {
                Get.put(
                  PromiseInfoViewModel(
                    promiseId: promiseId,
                    promiseRepository: Get.find<PromiseRepository>(),
                    userRepository: Get.find<UserRepository>(),
                  ),
                );
              }),
            );
          }),
          _TabButton('정산', () {}),
          _TabButton('벌칙', () {}),
          _TabButton('현황', () {
            Get.to(
              () => const PromiseStatusView(),
              arguments: promiseId,
              transition: Transition.downToUp,
              opaque: false,
              duration: const Duration(milliseconds: 300),
              fullscreenDialog: true,
              binding: BindingsBuilder(() {
                Get.lazyPut(() => CalculateDistanceUseCase());
                Get.put(
                  PromiseStatusViewModel(
                    promiseId: promiseId,
                    promiseRepository: Get.find<PromiseRepository>(),
                    userRepository: Get.find<UserRepository>(),
                    calculateDistanceUseCase:
                        Get.find<CalculateDistanceUseCase>(),
                  ),
                );
              }),
            );
          }),
          _TabButton('지각', () {
            Get.to(
              () => const LateView(),
              arguments: promiseId,
              transition: Transition.downToUp,
              opaque: false,
              duration: const Duration(milliseconds: 300),
              fullscreenDialog: true,
              binding: BindingsBuilder(() {
                Get.put(
                  LateViewModel(
                    promiseId: promiseId,
                    promiseRepository: Get.find<PromiseRepository>(),
                    userRepository: Get.find<UserRepository>(),
                    authRepository: Get.find<AuthRepository>(),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _TabButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
