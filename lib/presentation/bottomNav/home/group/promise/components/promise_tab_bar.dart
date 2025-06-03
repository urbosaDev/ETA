import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view_model.dart';

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
          _TabButton('정산', () {
            // Get.to(() => const PromisePaymentView(), arguments: promiseId);
          }),
          _TabButton('벌칙', () {
            // Get.to(() => const PromisePenaltyView(), arguments: promiseId);
          }),
          _TabButton('현황', () {
            // Get.to(() => const PromiseStatusView(), arguments: promiseId);
          }),
          _TabButton('메모', () {
            // Get.to(() => const PromiseMemoView(), arguments: promiseId);
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
