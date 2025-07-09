import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/common_text_field.dart';

class AddFriendView extends GetView<AddFriendViewModel> {
  final UserModel user;
  const AddFriendView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final TextEditingController textIdController = TextEditingController();

    controller.init(user);

    return Scaffold(
      appBar: AppBar(
        title: Text('친구 추가', style: textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '친구 아이디로 추가하기',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => CommonTextField(
                controller: textIdController,
                hintText: '친구 아이디 검색',
                keyboardType: TextInputType.text,
                onChanged: controller.onInputChanged,

                maxLength: 12,
                textStyle: textTheme.bodyMedium,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                suffixIcon: IconButton(
                  icon:
                      controller.isLoading.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white70,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.search,
                            color:
                                controller.isInputValid.value
                                    ? Colors.white
                                    : Colors.grey[600],
                          ),
                  onPressed:
                      controller.isInputValid.value &&
                              !controller.isLoading.value
                          ? () {
                            FocusScope.of(context).unfocus();
                            controller.searchAddFriend(textIdController.text);
                          }
                          : null,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white12, thickness: 0.2),
            const SizedBox(height: 24),

            Obx(() {
              if (controller.isLoading.value &&
                  controller.searchedUser.value == null &&
                  !controller.isUserNotFound.value &&
                  !controller.isFriend.value &&
                  !controller.isMe.value) {
                return const Center(child: CommonLoadingLottie());
              }

              if (controller.isMe.value) {
                return Center(
                  child: Text(
                    '자기 자신은 친구로 추가할 수 없습니다.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }
              if (controller.isUserNotFound.value) {
                return Center(
                  child: Text(
                    '해당 아이디의 사용자를 찾을 수 없습니다.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }
              if (controller.isFriend.value) {
                return Center(
                  child: Text(
                    '이미 친구입니다.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.green),
                  ),
                );
              }
              final user = controller.searchedUser.value;
              if (user != null) {
                return Center(
                  child: Container(
                    width: screenWidth * 0.7,
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              user.photoUrl.isNotEmpty
                                  ? NetworkImage(user.photoUrl)
                                  : const AssetImage(
                                        'assets/imgs/default_profile.png',
                                      )
                                      as ImageProvider,
                          backgroundColor: Colors.grey[700],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${user.uniqueId}',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.addFriend();
                              Get.back();
                              Get.snackbar(
                                '친구 추가 완료',
                                '${user.name}님을 친구로 추가했습니다.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.black.withOpacity(0.8),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(12),
                              );
                            },
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: Text(
                              '친구 추가',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
