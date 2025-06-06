import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class SelectFriendDialog extends StatelessWidget {
  final List<UserModel> friendList;
  final RxList<UserModel> selectedFriends;
  final void Function(UserModel) toggleFriend;

  final String confirmText;
  final VoidCallback onConfirm;

  /// ✅ 선택 불가 유저 목록
  final List<String> disabledUids;

  const SelectFriendDialog({
    super.key,
    required this.friendList,
    required this.selectedFriends,
    required this.toggleFriend,
    required this.confirmText,
    required this.onConfirm,
    this.disabledUids = const [], // 기본값은 없음
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500,
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내 친구 목록에서 추가하기',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('선택된 친구들'),
            const SizedBox(height: 8),
            Obx(() {
              return Container(
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.lime.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    selectedFriends.isEmpty
                        ? const Center(child: Text('아직 선택된 친구 없음'))
                        : ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              selectedFriends.map((f) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.lime.shade400,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(f.name),
                                );
                              }).toList(),
                        ),
              );
            }),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final selectedUids = selectedFriends.map((f) => f.uid).toSet();

                return ListView.builder(
                  itemCount: friendList.length,
                  itemBuilder: (context, index) {
                    final friend = friendList[index];
                    final isSelected = selectedUids.contains(friend.uid);
                    final isDisabled = disabledUids.contains(friend.uid);

                    return ListTile(
                      title: Text(friend.name),
                      subtitle: Text(friend.uniqueId),
                      trailing: Icon(
                        isDisabled
                            ? Icons.check_circle_outline
                            : (isSelected ? Icons.check : Icons.add),
                        color:
                            isDisabled
                                ? Colors.grey
                                : (isSelected ? Colors.green : null),
                      ),
                      onTap: isDisabled ? null : () => toggleFriend(friend),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
