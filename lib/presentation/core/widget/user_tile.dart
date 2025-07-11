import 'package:flutter/material.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextTheme textTheme;

  const UserTile({
    super.key,
    required this.user,
    this.isSelected = false,
    this.onTap,
    this.trailing,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      user.photoUrl.isNotEmpty
                          ? NetworkImage(user.photoUrl)
                          : const AssetImage('assets/imgs/default_profile.png')
                              as ImageProvider,
                  backgroundColor: Colors.grey[700],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@${user.uniqueId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
