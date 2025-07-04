import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/%08add_friend/add_friend_view_model.dart';

class AddFriendView extends GetView<AddFriendViewModel> {
  final UserModel user;
  const AddFriendView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textIdController = TextEditingController();
    controller.init(user);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Friend')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Add Friend View'),
            Row(
              children: [
                Text('내 ID: ${controller.currentUser.value?.uniqueId ?? ''}'),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: textIdController,
                    decoration: const InputDecoration(labelText: '친구 ID 검색'),
                    onChanged: controller.onInputChanged, // 👈 연결
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isInputValid.value
                              ? () => controller.searchAddFriend(
                                textIdController.text,
                              )
                              : null, // 👈 null이면 비활성화
                      child: const Text('검색'),
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return CircularProgressIndicator();
              }
              if (controller.isMe.value) {
                return const Text('자기 자신은 친구로 추가할 수 없습니다.');
              }
              if (controller.isUserNotFound.value) {
                return const Text('해당 ID의 사용자를 찾을 수 없습니다.');
              }
              if (controller.isFriend.value) {
                return const Text('이미 친구입니다.');
              }
              final user = controller.searchedUser.value;
              if (user != null) {
                return Column(
                  children: [
                    Image.network(user.photoUrl, width: 100, height: 100),
                    Text('이름: ${user.name}'),
                    Text('아이디: ${user.uniqueId}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.addFriend();
                        Get.back();
                        Get.snackbar('성공', '친구가 추가되었습니다');
                      },
                      child: const Text('친구 추가'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
