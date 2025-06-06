import 'package:flutter/material.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing; // ✅ 추가

  const UserTile({
    super.key,
    required this.user,
    this.isSelected = false,
    this.onTap,
    this.trailing, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 핵심
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.uniqueId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (trailing != null) trailing!, // ✅ 우측 위젯
          ],
        ),
      ),
    );
  }
}
