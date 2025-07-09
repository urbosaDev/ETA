import 'package:flutter/material.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextTheme textTheme; // ✨ 추가: TextTheme을 외부에서 주입받습니다.

  const UserTile({
    super.key,
    required this.user,
    this.isSelected = false,
    this.onTap,
    this.trailing,
    required this.textTheme, // ✨ 생성자에도 추가
  });

  @override
  Widget build(BuildContext context) {
    // isSelected에 따른 배경색 (약속 참여자 목록에서는 주로 투명하지만, 기능 유지)
    final backgroundColor =
        isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // padding과 margin을 조정하여 작고 간결하게
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 2), // 리스트 아이템 간 간격
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10), // 둥근 모서리
          // 이 타일이 PromiseInfoView의 _buildInfoCard 내부에 있으므로
          // 별도의 border나 boxShadow는 여기 UserTile에서 일반적으로 추가하지 않습니다.
          // 필요하다면 isSelected에 따라 보더를 추가할 수 있습니다.
          // border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // 좌우 끝 정렬 (trailing 위젯 때문에)
          crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16, // 아바타 크기 조정 (작게)
                  backgroundImage:
                      user.photoUrl.isNotEmpty
                          ? NetworkImage(user.photoUrl)
                          : const AssetImage('assets/imgs/default_profile.png')
                              as ImageProvider,
                  backgroundColor: Colors.grey[700],
                ),
                const SizedBox(width: 12), // 아바타와 텍스트 사이 간격
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name, // ✨ uniqueId 대신 name을 먼저 표시 (디스코드 스타일)
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, // 굵기 조정
                        color: Colors.white, // 텍스트 색상
                      ),
                    ),
                    Text(
                      '@${user.uniqueId}', // ✨ uniqueId는 @와 함께
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500], // 보조 텍스트 색상
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (trailing != null) trailing!, // trailing 위젯 표시
          ],
        ),
      ),
    );
  }
}
