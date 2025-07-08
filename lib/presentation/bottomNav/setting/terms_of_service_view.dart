import 'package:flutter/material.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서비스 이용약관')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SelectableText('''[서비스 이용약관]

본 약관은 귀하가 본 모바일 애플리케이션(이하 “서비스”)을 이용함에 있어 회사와 사용자 간의 권리, 의무 및 책임사항 등을 규정함을 목적으로 합니다.

1. 목적
본 약관은 귀하가 채팅 및 위치 공유 기반의 소셜 서비스 “WHAT'S YOUR ETA”(이하 “서비스”)를 이용함에 있어, 회사와 사용자 간의 권리 및 의무를 규정합니다.

2. 서비스의 내용
회사는 아래와 같은 서비스를 제공합니다.
- 사용자 간 1:1 및 그룹 채팅 기능
- 위치 기반 약속 기능 및 위치 공유
- 사용자 계정 기반 소셜 네트워킹

3. 회원가입 및 계정 관리
- 사용자는 Google 또는 Apple 계정을 통해 로그인할 수 있으며, 별도의 회원가입 절차는 필요하지 않습니다.
- 사용자는 언제든지 계정 삭제를 요청할 수 있으며, 삭제 시 모든 데이터는 즉시 파기됩니다.

4. 사용자 책임
- 사용자는 타인에게 불쾌감이나 피해를 주는 행위를 하여서는 안됩니다.
- 채팅 또는 위치 정보를 통한 불법행위가 발견될 경우 서비스 이용이 제한될 수 있습니다.

5. 서비스의 변경 및 중단
회사는 안정적인 서비스 제공을 위해 필요한 경우 일부 또는 전부를 수정하거나 중단할 수 있습니다.

6. 책임 제한
- 회사는 사용자 간의 채팅 내용이나 위치 공유로 발생하는 피해에 대해 책임을 지지 않습니다.
- 회사는 서비스 유지 및 보안을 위해 최선을 다합니다.

7. 분쟁 해결
- 본 약관에 따른 분쟁은 대한민국 법률에 따릅니다.
'''),
      ),
    );
  }
}
