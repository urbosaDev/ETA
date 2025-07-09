import 'package:flutter/material.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class UserSquareCard extends StatelessWidget {
  final UserModel user;
  final double size;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  const UserSquareCard({
    super.key,
    required this.user,
    this.size = 70.0,
    this.borderRadius = 8.0,
    this.onTap,
    this.borderColor = Colors.transparent, // 기본값 투명
    this.borderWidth = 0.0, // 기본값 0
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor!,
            width: borderWidth,
          ), // 동적으로 설정된 테두리 사용
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: size * 0.25,
              backgroundImage:
                  user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : const AssetImage('assets/imgs/default_profile.png')
                          as ImageProvider,
              backgroundColor: Colors.grey[700],
            ),
            SizedBox(height: size * 0.05),
            Text(
              user.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
