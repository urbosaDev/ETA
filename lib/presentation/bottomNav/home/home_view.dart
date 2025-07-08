import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/fcm_repository.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/create_group/create_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/home_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/private_chat/private_chat_view.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double leftTabWidth = min(screenWidth * 0.18, 72.0);
    return SafeArea(
      child: Row(
        children: [
          // 사이드바
          SizedBox(
            width: leftTabWidth,
            child: Obx(() {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      backgroundColor: Color(0xff111111),
                      selectedIndex: controller.selectedIndex.value,
                      selectedLabelTextStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white),
                      unselectedLabelTextStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                      onDestinationSelected: (index) {
                        if (index == 1) {
                          showCreateGroupDialog(context);
                          return;
                        }

                        controller.selectedIndex.value = index;
                      },

                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.chat),
                          label: Text('채팅'),
                        ),
                        NavigationRailDestination(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withOpacity(
                                0.15,
                              ), // 커스텀 배경
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.add,
                              color: Colors.pinkAccent,
                            ), // 커스텀 색상
                          ),
                          label: Text(
                            '그룹생성',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.pinkAccent),
                          ),
                        ),
                        ...controller.groupList.map((group) {
                          String displayText = group.title;
                          if (displayText.length > 3) {
                            displayText = '${displayText.substring(0, 3)}..';
                          }

                          return NavigationRailDestination(
                            icon: const Icon(Icons.groups),
                            label: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // 본문
          Expanded(
            child: Obx(() {
              final index = controller.selectedIndex.value;
              Widget innerView;
              if (index == 0) {
                innerView = const PrivateChatView();
              } else if (index >= 2) {
                final group = controller.groupList[index - 2];
                final tag = group.id;

                if (!Get.isRegistered<GroupViewModel>(tag: tag)) {
                  Get.put(
                    GroupViewModel(
                      group: group,
                      groupRepository: Get.find(),
                      userRepository: Get.find(),
                      authRepository: Get.find(),
                      promiseRepository: Get.find(),
                      chatRepository: Get.find(),
                    ),
                    tag: tag,
                    permanent: true,
                  );
                }

                innerView = GetBuilder<GroupViewModel>(
                  tag: tag,
                  builder: (_) => GroupView(groupTag: tag),
                );
              } else {
                innerView = const Center(child: Text('그룹은 별도 화면에서 열립니다.'));
              }

              return Container(
                margin: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: innerView,
                ),
              );
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
                          fcmRepository: Get.find<FcmRepository>(),
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
