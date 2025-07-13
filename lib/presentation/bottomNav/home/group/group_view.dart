import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/data/repository/auth_repository.dart';
import 'package:what_is_your_eta/data/repository/chat_repository.dart';
import 'package:what_is_your_eta/data/repository/notification_api_repository.dart';

import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';
import 'package:what_is_your_eta/data/repository/user_%08repository.dart';
import 'package:what_is_your_eta/domain/usecase/get_single_with_status_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/lounge_in_group/lounge_in_group_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise_log/promise_log_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise_log/promise_log_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/%08user_card.dart';
import 'package:what_is_your_eta/presentation/core/widget/select_friend_dialog.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view.dart';
import 'package:what_is_your_eta/presentation/user_profile/user_profile_view_model.dart';

class GroupView extends GetView<GroupViewModel> {
  final String groupTag;
  const GroupView({super.key, required this.groupTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupViewModel>(tag: groupTag);
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CommonLoadingLottie());
        }

        final data = controller.groupModel.value;
        if (data == null) {
          return Center(
            child: Text('그룹 정보를 불러올 수 없습니다.', style: textTheme.bodyMedium),
          );
        }
        if (controller.isDeleteAndLeaveGroup.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/main');
          });
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          controller.deleteGroup();
                        } else if (value == 'leave') {
                          controller.leaveGroup();
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (controller.isMyGroup) ...[
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  '그룹 삭제',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ] else ...[
                              PopupMenuItem(
                                value: 'leave',
                                child: Text(
                                  '그룹 나가기',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ],
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      color: const Color(0xff1a1a1a),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Get.dialog(
                        SelectFriendDialog(
                          friendList: controller.validFriends.obs,
                          selectedFriends: controller.selectedFriends,
                          toggleFriend: controller.toggleFriend,
                          disabledUids:
                              controller.memberList
                                  .map((u) => u.userModel.uid)
                                  .toList(),
                          confirmText: '초대하기',
                          onConfirm: () {
                            controller.invite();
                            Get.back();
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xff1a1a1a),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Color(0xffa8216b),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "친구 초대하기",
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffa8216b),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.white12, thickness: 0.2),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(
                      '구성원',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final leader = controller.leaderModel.value;
                      final isUnknown = leader?.uniqueId == 'unknown';

                      if (isUnknown) {
                        return TextButton(
                          onPressed: () {
                            controller.changeLeader(
                              leaderUid: controller.currentUser!,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            '👑 내가 할래요',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.blueAccent,
                            ),
                          ),
                        );
                      }

                      return Text(
                        '그룹장: ${leader?.name ?? '정보 없음'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: screenWidth * 0.25,
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
                  child: groupMemberList(
                    context,
                    controller,
                    textTheme,
                    screenWidth,
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => LoungeInGroupView(),
                      arguments: controller.group.id,
                      binding: BindingsBuilder(() {
                        Get.put(
                          LoungeInGroupViewModel(
                            authRepository: Get.find<AuthRepository>(),
                            userRepository: Get.find<UserRepository>(),
                            groupRepository: Get.find<GroupRepository>(),
                            groupId: controller.group.id,
                          ),
                        );
                      }),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xffa8216b), width: 0.5),
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
                      child: Text(
                        '그룹 채팅 채널',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  '현재 진행중인 약속',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final promise = controller.currentPromise.value;

                  if (promise != null) {
                    return GestureDetector(
                      onTap:
                          controller.isParticipating.value
                              ? () {
                                Get.to(
                                  () => PromiseView(),
                                  binding: BindingsBuilder(() {
                                    Get.put(
                                      PromiseViewModel(promiseId: promise.id),
                                    );
                                  }),
                                );
                              }
                              : null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              controller.isParticipating.value
                                  ? const Color(0xff1a1a1a)
                                  : Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                controller.isParticipating.value
                                    ? Colors.blueAccent.withOpacity(0.5)
                                    : Colors.grey[700]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    promise.name,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          controller.isParticipating.value
                                              ? Colors.white
                                              : Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!controller.isParticipating.value)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '미참여',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              '시간: ${promise.time.year}년 ${promise.time.month}월 ${promise.time.day}일 ${promise.time.hour}시 ${promise.time.minute}분',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),

                            Text(
                              '장소: ${promise.location.placeName}',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Text(
                      '약속이 없습니다.',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                    );
                  }
                }),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            controller.isPromiseExisted.value
                                ? null
                                : () {
                                  Get.to(
                                    () => CreatePromiseView(),
                                    binding: BindingsBuilder(() {
                                      Get.put(
                                        CreatePromiseViewModel(
                                          groupId: controller.group.id,
                                          groupRepository:
                                              Get.find<GroupRepository>(),
                                          userRepository:
                                              Get.find<UserRepository>(),
                                          promiseRepository:
                                              Get.find<PromiseRepository>(),
                                          fcmRepository:
                                              Get.find<
                                                NotificationApiRepository
                                              >(),
                                        ),
                                      );
                                    }),
                                  );
                                },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 120,
                          decoration: BoxDecoration(
                            color:
                                controller.isPromiseExisted.value
                                    ? Colors.grey[900]
                                    : Theme.of(context)
                                            .elevatedButtonTheme
                                            .style
                                            ?.backgroundColor
                                            ?.resolve({})
                                            ?.withOpacity(0.9) ??
                                        Colors.pinkAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  controller.isPromiseExisted.value
                                      ? Colors.white12
                                      : Colors.white24,
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              controller.isPromiseExisted.value
                                  ? '현재 진행중인 약속을 마감해야\n새로운 약속을 추가할 수 있어요'
                                  : '약속 추가하러 가기',
                              style: textTheme.bodySmall?.copyWith(
                                color:
                                    controller.isPromiseExisted.value
                                        ? Colors.grey[600]
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => const PromiseLogView(),
                            binding: BindingsBuilder(() {
                              Get.put(
                                PromiseLogViewModel(
                                  groupId: controller.group.id,
                                  groupRepository: Get.find<GroupRepository>(),
                                  promiseRepository:
                                      Get.find<PromiseRepository>(),
                                ),
                              );
                            }),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xff1a1a1a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '지난 약속 목록 보기',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isMyGroup &&
                                controller.currentPromise.value != null
                            ? () {
                              Get.dialog(
                                _buildEndPromiseDialog(
                                  context,
                                  onConfirm: () {
                                    controller.endPromise();
                                    Get.back();
                                  },
                                ),
                              );
                            }
                            : null,
                    style: Theme.of(
                      context,
                    ).elevatedButtonTheme.style?.copyWith(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>((
                            Set<MaterialState> states,
                          ) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey[800]?.withOpacity(0.4);
                            }

                            return Colors.redAccent;
                          }),
                    ),
                    child: Text(
                      '현재 약속 마감하기',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '약속 마감은 그룹장만 진행할 수 있어요.',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget groupMemberList(
    BuildContext context,
    GroupViewModel controller,
    TextTheme textTheme,
    double screenWidth,
  ) {
    return Obx(() {
      final members = controller.memberList;
      if (members.isEmpty) {
        return Center(
          child: Text(
            '구성원이 없습니다.',
            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        );
      }
      final currentUid = controller.currentUser;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children:
              members.map((member) {
                final isSelf = member.userModel.uid == currentUid;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap:
                        isSelf
                            ? null
                            : () {
                              Get.to(
                                () => const UserProfileView(),
                                fullscreenDialog: true,
                                transition: Transition.downToUp,
                                binding: BindingsBuilder(() {
                                  Get.put(
                                    UserProfileViewModel(
                                      userRepository:
                                          Get.find<UserRepository>(),
                                      authRepository:
                                          Get.find<AuthRepository>(),
                                      chatRepository:
                                          Get.find<ChatRepository>(),
                                      targetUserUid: member.userModel.uid,
                                      getSingleUserWithStatusUsecase:
                                          Get.find<
                                            GetSingleUserWithStatusUsecase
                                          >(),
                                    ),
                                  );
                                }),
                              );
                            },
                    child: Opacity(
                      opacity: isSelf ? 0.6 : 1.0,
                      child: UserSquareCard(
                        user: member.userModel,
                        size: screenWidth * 0.16,
                        borderColor:
                            controller.leaderModel.value?.uid ==
                                    member.userModel.uid
                                ? Colors.amber
                                : Colors.transparent,
                        borderWidth:
                            controller.leaderModel.value?.uid ==
                                    member.userModel.uid
                                ? 2.0
                                : 0.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      );
    });
  }

  Widget _buildEndPromiseDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(
        '약속 마감',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(
        '현재 진행중인 약속을 마감하시겠어요? \n 진행되지 않은 약속은 삭제됩니다. \n진행된 약속은 기록으로 볼 수 있어요',
        style: textTheme.bodySmall,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            '아니오',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.redAccent),
          ),
          child: Text(
            '네',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      backgroundColor: const Color(0xff1a1a1a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
