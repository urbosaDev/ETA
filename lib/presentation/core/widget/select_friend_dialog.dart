import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/core/widget/%08user_card.dart';

import 'package:what_is_your_eta/presentation/models/friend_info_model.dart';

class SelectFriendDialog extends StatelessWidget {
  final RxList<FriendInfoModel> friendList;
  final RxList<FriendInfoModel> selectedFriends;
  final void Function(FriendInfoModel) toggleFriend;

  final String confirmText;
  final VoidCallback onConfirm;
  final List<String> disabledUids;
  final int maxGroupsPerUser;
  const SelectFriendDialog({
    super.key,
    required this.friendList,
    required this.selectedFriends,
    required this.toggleFriend,
    required this.confirmText,
    required this.onConfirm,
    this.disabledUids = const [],
    this.maxGroupsPerUser = 6,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: const Color(0xff1a1a1a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12, width: 0.5),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '내 친구 목록에서 추가하기',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '선택된 친구들',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12, width: 0.5),
                ),
                child:
                    selectedFriends.isEmpty
                        ? Center(
                          child: Text(
                            '아직 선택된 친구 없음',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        )
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedFriends.length,
                          itemBuilder: (context, index) {
                            final friend = selectedFriends[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: UserSquareCard(
                                user: friend.userModel,
                                size: 60,
                                onTap: () {
                                  toggleFriend(friend);
                                },
                              ),
                            );
                          },
                        ),
              );
            }),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                final selectedUids =
                    selectedFriends.map((f) => f.userModel.uid).toSet();

                return ListView.separated(
                  itemCount: friendList.length,
                  separatorBuilder:
                      (context, index) => const Divider(
                        color: Colors.white12,
                        thickness: 0.2,
                        indent: 16,
                        endIndent: 16,
                      ),
                  itemBuilder: (context, index) {
                    final friend = friendList[index];
                    final isSelected = selectedUids.contains(
                      friend.userModel.uid,
                    );
                    final isDisabled = disabledUids.contains(
                      friend.userModel.uid,
                    );
                    final bool isGroupLimitReached =
                        friend.userModel.groupIds.length >= maxGroupsPerUser;

                    final bool finalIsDisabled =
                        isDisabled ||
                        isGroupLimitReached ||
                        friend.status == UserStatus.deleted ||
                        friend.status == UserStatus.blocked;

                    String subtitleText = '@${friend.userModel.uniqueId}';
                    if (friend.status == UserStatus.deleted) {
                      subtitleText = '탈퇴한 유저입니다.';
                    } else if (friend.status == UserStatus.blocked) {
                      subtitleText = '차단된 유저입니다.';
                    } else if (isGroupLimitReached) {
                      subtitleText = '그룹 최대($maxGroupsPerUser개)에 도달했어요.';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            friend.userModel.photoUrl.isNotEmpty
                                ? NetworkImage(friend.userModel.photoUrl)
                                : const AssetImage(
                                      'assets/imgs/default_profile.png',
                                    )
                                    as ImageProvider,
                        backgroundColor: Colors.grey[700],
                      ),
                      title: Text(
                        friend.userModel.name,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDisabled ? Colors.grey[600] : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '$subtitleText',
                        style: textTheme.bodySmall?.copyWith(
                          color: isDisabled ? Colors.grey[700] : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        isDisabled
                            ? Icons.check_circle_outline
                            : (isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline),
                        color:
                            isDisabled
                                ? Colors.grey
                                : (isSelected
                                    ? Colors.greenAccent
                                    : Colors.blueAccent),
                        size: 24,
                      ),
                      onTap:
                          finalIsDisabled ? null : () => toggleFriend(friend),
                      selected: isSelected,
                      selectedTileColor: Colors.white.withOpacity(0.05),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  confirmText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
