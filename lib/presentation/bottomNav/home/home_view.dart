import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Row(
        children: [
          // 사이드바
          SizedBox(
            width: 72,
            child: Obx(() {
              return NavigationRail(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) {
                  if (index == 1) {
                    showCreateGroupDialog(context);
                  } else {
                    // 이제 ViewModel 삭제는 GroupView 내부에서 처리됨. 여긴 index만 바꾸면 됨.
                    controller.selectedIndex.value = index;
                  }
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.chat),
                    label: Text('Chat'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.add),
                    label: Text('Create'),
                  ),
                  ...controller.groupList.map(
                    (group) => NavigationRailDestination(
                      icon: const Icon(Icons.groups),
                      label: Text(group.title),
                    ),
                  ),
                ],
              );
            }),
          ),

          // 본문
          Expanded(
            child: Obx(() {
              final index = controller.selectedIndex.value;
              if (index == 0) {
                return const PrivateChatView();
              } else if (index >= 2) {
                final group = controller.selectedGroup;
                if (group != null) {
                  return GroupView(group: group); // 여기서 ViewModel을 새로 생성함
                }
                return const Center(child: Text('존재하지 않는 그룹입니다.'));
              } else {
                return const Center(child: Text('선택된 뷰가 없습니다.'));
              }
            }),
          ),
        ],
      ),
    );
  }

  void showCreateGroupDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.close, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                '그룹 채널을 만들어봐요',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                '그룹 채널 내에서 친구들과 함께 약속을\n만들어볼까요 🌸',
                style: TextStyle(color: Colors.pinkAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
                onPressed: () {
                  Get.to(
                    () => const CreateGroupView(),
                    binding: BindingsBuilder(() {
                      Get.put(
                        CreateGroupViewModel(
                          userRepository: Get.find<UserRepository>(),
                          authRepository: Get.find<AuthRepository>(),
                          groupRepository: Get.find<GroupRepository>(),
                        ),
                      );
                    }),
                  );
                },
                child: const Text('⭐채널 생성하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
