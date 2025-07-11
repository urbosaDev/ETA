import 'package:flutter/material.dart';

class GoodbyeView extends StatelessWidget {
  const GoodbyeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.waving_hand, size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 24),

                Text(
                  "다음에 또 만나요 👋",
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  "회원 탈퇴가 성공적으로 완료되었습니다.",
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "모든 데이터가 안전하게 삭제되었으며,\n더 이상 이 계정으로 로그인할 수 없습니다.",
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                Text(
                  "지금 바로 앱을 종료해주세요.",
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "앱을 완전히 종료한 뒤 다시 시작하면\n초기 화면으로 돌아갑니다.",
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
