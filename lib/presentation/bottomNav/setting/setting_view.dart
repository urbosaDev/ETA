import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/good_bye_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/component/setting_tile.dart';
import 'package:what_is_your_eta/presentation/bottomNav/setting/setting_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';

class SettingView extends GetView<SettingViewModel> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSignedOut.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
      }
      if (controller.isDeleting.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Get.offAll(() => const GoodbyeView());
        });
      }

      return Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '설정',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SettingTile(title: "화면 테마", value: "구현중입니다", onTap: () {}),
                const Divider(color: Colors.grey, thickness: 0.2),
                SettingTile(
                  title: "개인정보 처리방침",
                  value: "＞",
                  onTap: () {
                    Get.toNamed('/privacy-policy');
                  },
                ),
                SettingTile(
                  title: "서비스 이용약관",
                  value: "＞",
                  onTap: () {
                    Get.toNamed('/terms-of-service');
                  },
                ),
                const Divider(color: Colors.grey, thickness: 0.2),
                SettingTile(title: "사용자 리뷰", value: "부탁드려요!", onTap: () {}),
                SettingTile(title: "앱 버전", value: "1.0.0", onTap: () {}),
                const Divider(color: Colors.grey, thickness: 0.2),
                SettingTile(title: "로그아웃", onTap: controller.signOut),
                SettingTile(
                  title: "탈퇴하기",
                  value: "가지마!",
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text("정말 탈퇴하시겠어요?"),
                        content: const Text("탈퇴하면 모든 데이터가 삭제됩니다."),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(), // 닫기만
                            child: const Text("아니오"),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(); // 먼저 다이얼로그 닫고
                              controller.deleteAccount(); // 그 후 탈퇴 실행
                            },
                            child: const Text("네"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CommonLoadingLottie()),
            ),
        ],
      );
    });
  }
}
