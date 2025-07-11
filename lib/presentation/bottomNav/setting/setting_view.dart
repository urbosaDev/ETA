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
                // SettingTile(title: "사용자 리뷰", value: "부탁드려요!", onTap: () {}),
                SettingTile(title: "앱 버전", value: "1.0.0", onTap: () {}),
                const Divider(color: Colors.grey, thickness: 0.2),
                SettingTile(title: "로그아웃", onTap: controller.signOut),
                SettingTile(
                  title: "탈퇴하기",
                  value: "가지마!",
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: const Color(0xff1a1a1a),
                        title: Text(
                          "정말 탈퇴하시겠어요?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              "계정 삭제 시 다음과 같은 모든 데이터가 영구적으로 삭제되며, 복구할 수 없습니다.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "- 프로필 정보 (이름, 사진, 고유 ID 등)",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "- 모든 채팅 기록 및 친구 목록",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "- 모든 활동 기록 및 기타 생성 데이터",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "탈퇴 후에는 더 이상 이 서비스에 로그인할 수 없습니다.",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("아니오"),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              Get.dialog(
                                AlertDialog(
                                  backgroundColor: const Color(0xff1a1a1a),
                                  title: Text(
                                    "정말 탈퇴해요? ㅠㅠ",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  content: Text(
                                    "탈퇴 후에는 모든 데이터가 영구적으로 삭제되며, 복구할 수 없습니다.\n정말 탈퇴하시겠어요?",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        "아니요, 아직은...",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteAccount();
                                      },
                                      child: Text(
                                        "네, 삭제할게요!",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("탈퇴할래요"),
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
