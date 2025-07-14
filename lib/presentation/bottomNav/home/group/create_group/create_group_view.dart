import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/%08user_card.dart';
import 'package:what_is_your_eta/presentation/core/widget/common_text_field.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';

class CreateGroupView extends GetView<CreateGroupViewModel> {
  final TextEditingController titleController = TextEditingController();

  CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (titleController.text != controller.groupTitle.value) {
      titleController.text = controller.groupTitle.value;
    }

    return Obx(() {
      final message = controller.systemMessage.value;
      final isGroupCreated = controller.isGroupCreated.value;
      final isLoading = controller.isLoading.value;
      if (message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('알림', message, snackPosition: SnackPosition.TOP);
          controller.systemMessage.value = '';
        });
      }
      if (isGroupCreated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/main');
          controller.isGroupCreated.value = false;
        });
      }
      if (isLoading) {
        return const Center(child: CommonLoadingLottie());
      }
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '그룹 만들기',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey, thickness: 0.2),
                const SizedBox(height: 16),
                Text(
                  '그룹 제목을 설정해주세요',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGroupNameInput(context, textTheme),
                const SizedBox(height: 24),

                Text(
                  '친구를 초대하세요',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      SelectFriendDialog(
                        friendList: controller.validFriends.obs,
                        selectedFriends: controller.selectedFriends,
                        toggleFriend: controller.toggleFriend,
                        disabledUids: const [],
                        confirmText: '선택 완료',
                        onConfirm: () => Get.back(),
                      ),
                    );
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Obx(() {
                        final selected = controller.selectedFriends;
                        if (selected.isEmpty) {
                          return Text(
                            '이곳을 눌러 친구 초대하기',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          );
                        } else {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              spacing: 8,

                              children:
                                  selected
                                      .map(
                                        (f) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: UserSquareCard(
                                            user: f.userModel,
                                            size: 80,
                                            onTap: () {
                                              Get.dialog(
                                                SelectFriendDialog(
                                                  friendList:
                                                      controller
                                                          .validFriends
                                                          .obs,
                                                  selectedFriends:
                                                      controller
                                                          .selectedFriends,
                                                  toggleFriend:
                                                      controller.toggleFriend,
                                                  disabledUids: const [],
                                                  confirmText: '선택 완료',
                                                  onConfirm: () => Get.back(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() {
                  if (controller.isReadyToCreate &&
                      !controller.isCreating.value) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.createGroup();
                        },

                        child:
                            controller.isCreating.value
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      textTheme.bodyMedium?.color ??
                                          Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  '그룹 만들기',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '그룹 제목을 입력하고 친구를 초대해야 그룹을 만들 수 있습니다.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '모든 항목이 채워지면 버튼이 나타납니다.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '⚠️ 이름에 부적절한 단어(욕설, 사회적으로 부적절한 표현 등)가 포함될 경우 제재를 받을 수 있습니다.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGroupNameInput(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: titleController,
          hintText: '그룹 이름을 입력하세요 (2~10자, 욕설 금지)',
          keyboardType: TextInputType.text,
          onChanged: (value) {
            controller.onTitleChanged(value);
          },
          maxLength: 10,
          onSubmitted: null,
        ),
        Obx(() {
          if (controller.containsBlockedWordInTitle.value) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '❌ 그룹 이름에 부적절한 단어가 포함되어 있습니다.',
                style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
              ),
            );
          } else if (controller.groupTitle.value.length > 10) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '⚠️ 그룹 이름은 최대 10자까지 입력 가능합니다.',
                style: textTheme.bodySmall?.copyWith(color: Colors.orange),
              ),
            );
          } else if (controller.groupTitle.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '✅ 사용 가능한 이름입니다.',
                style: textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '그룹 이름을 입력해주세요.',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            );
          }
        }),
      ],
    );
  }
}
