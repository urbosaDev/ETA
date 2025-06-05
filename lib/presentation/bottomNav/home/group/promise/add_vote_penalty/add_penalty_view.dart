import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/components/swipe_hint.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/penalty_container_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class AddPenaltyView extends GetView<PenaltyContainerViewModel> {
  const AddPenaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //설명서, 단순텍스트
          _buildePenaltyExample(),
          //진행도, 어떤 유저가 벌칙을 제안했는지, 또한 진행률은 어떻게 되는지
          _buildePenaltyING(),
          // 벌칙 입력 필드
          _buildPenaltyInput(textController),
          // 스와이프하도록 유도하는 텍스트
          SwipeHint(icon: Icons.arrow_forward_ios, label: '투표하기'),
        ],
      ),
    );
  }

  Widget _buildePenaltyExample() {
    return Column(
      children: [
        const Text(
          '벌칙 추가 설명서',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const Text(
          '각 참여자는 자신이 추가한 벌칙에 대해 투표할 수 있습니다.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          '한번 정해진 벌칙은 변경할 수 없습니다.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          '동일한 투표수의 벌칙은 랜덤으로 선택됩니다.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          '타이머 종료 후 까지 선택되지 않으면, 벌칙이 초기화됩니다.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          '진행도',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildePenaltyING() {
    return Obx(() {
      final list = controller.memberWithStatusList;

      return SizedBox(
        height: 270,
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white24),
          itemBuilder: (context, index) {
            final member = list[index];
            return Container(
              color: member.isCurrentUser ? Colors.white12 : Colors.transparent,
              child: UserTile(
                user: member.user.copyWith(
                  name: member.isCurrentUser ? '나' : member.user.name,
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      member.hasSuggested ? '제안 완료' : '대기 중',
                      style: TextStyle(
                        color:
                            member.hasSuggested
                                ? Colors.greenAccent
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (member.description != null)
                      Text(
                        '"${member.description}"',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPenaltyInput(TextEditingController textController) {
    return Column(
      children: [
        const Text(
          '벌칙 추가하기',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          '벌칙은 단 한번 정할 수 있습니다.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Obx(() {
          final hasSuggested = controller.hasCurrentUserSuggested;
          final isSubmitting = controller.isSubmitting.value;
          final isDisabled = hasSuggested || isSubmitting;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 텍스트 필드
                    Expanded(
                      child: TextField(
                        controller: textController,
                        enabled: !isDisabled,
                        decoration: InputDecoration(
                          hintText: hasSuggested ? "이미 제안하셨습니다." : "벌칙을 입력하세요",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor:
                              hasSuggested ? Colors.white12 : Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 버튼
                    ElevatedButton(
                      onPressed:
                          isDisabled
                              ? () {}
                              : () async {
                                await controller.submitPenalty(
                                  textController.text,
                                );
                                textController.clear();
                                final successMsg =
                                    controller.successMessage.value;
                                final errorMsg = controller.errorMessage.value;
                                if (successMsg != null) {
                                  Get.snackbar(
                                    '완료',
                                    successMsg,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                }

                                if (errorMsg != null) {
                                  Get.snackbar(
                                    '오류',
                                    errorMsg,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                }
                                controller.clearMessages();
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDisabled ? Colors.grey : Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("추가"),
                    ),
                  ],
                ),
                if (hasSuggested)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "⚠️ 벌칙을 제안하셨습니다. 다시 수정할 수 없습니다.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
