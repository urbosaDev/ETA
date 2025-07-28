

# 🦍어딧삼 
### " 약속하고 모이고 소통해요 "
그룹을 생성하고 그룹 안에 약속을 만들어서 친구들과 위치를 공유하는 채팅앱입니다. 
<img width="220" height="478" alt="Group 4" src="https://github.com/user-attachments/assets/59575d38-ed89-41bb-b6cb-e7bf95451806" /><img  width="220" height="478" alt="Group 6" src="https://github.com/user-attachments/assets/f2864762-b74f-41e6-9e0b-76dac29945ab" /><img width="220"  height="478" alt="Group 7" src="https://github.com/user-attachments/assets/5d00e60f-96f9-4c98-93ef-9dee9987fdd2" />

---

## 📄목차 

목차는 다음과 같습니다  

0. [프로젝트 시연 영상](#0-프로젝트-시연-영상)
1. [프로젝트 소개](#1-프로젝트-소개)

    *[1.1 Motivation](#11-motivation)

    *[1.2 Concept](#12-concept)

    *[1.3 프로젝트 개요](#13-프로젝트-개요)

2. [프로젝트 기술 스택](#2-프로젝트-기술-스택)
3. [프로젝트에 사용된 Architecture](#3-프로젝트에-사용된-architecture)

    *[MVVM 및 계층 구조](#mvvm-및-계층-구조)

    *[선언형 UI 및 단방향 데이터 흐름](#선언형-ui-및-단방향-데이터-흐름)

    *[의존성 주입](#의존성-주입-di)

4. [프로젝트 구조](#4-프로젝트-구조)
5. [주요기능](#5-주요기능)

    *[5.1 그룹: 약속을 위한 베이스캠프 (핵심 기능)](#51-그룹-약속을-위한-베이스캠프-핵심-기능)

    *[5.2 약속 및 위치 공유 (⭐ 핵심 기능)](#52-약속-및-위치-공유--핵심-기능)

    *[5.3 친구관리 및 1:1채팅](#53-친구관리-및-11채팅)

    *[5.4 사용자 프로필 및 보호 기능](#54-사용자-프로필-및-보호-기능)

6. [데이터베이스 모델 구조 (firestore)](#6-데이터베이스-모델-구조-firestore)
7. [주요 트러블 슈팅 및 문제 해결 경험](#7-주요-트러블-슈팅-및-문제-해결-경험)

    *[7.1 비효율적인 폴링(Polling) 방식의 알림 시스템 개선](#71-비효율적인-폴링polling-방식의-알림-시스템-개선)

    *[7.2 비동기 처리 최적화를 통한 UX 개선](#72-비동기-처리-최적화를-통한-ux-개선)

    *[7.3 도메인 레이어 적용](#73-도메인-레이어-적용)

    *[7.4 복잡한 초기 설계를 뒤엎은 대규모 리팩토링](#74-복잡한-초기-설계를-뒤엎은-대규모-리팩토링)

8. [이번 프로젝트 회고](#8-이번-프로젝트-회고)
9. [향후 개발 계획](#9-향후-개발-계획)
10. [앱 화면별 사진 모음](#10-앱-화면별-사진-모음)

---
## 0. 프로젝트 시연 영상 
> 해당 링크를 참고해주시면 감사하겠습니다 ;)
링크 : 
[https://www.youtube.com/watch?v=84TcM15TTFc ](https://www.youtube.com/watch?v=84TcM15TTFc)
---

##  1. 프로젝트 소개

### 1.1 Motivation
> - 오래된 친구들 모임에서 가끔 한번씩 모이게 되는데 ,
그룹중 “ 나 거의 다옴“ 이라면서 그때 출발하는 경우가 있었습니다. 
거기에서 아이디어를 얻고 프로젝트를 만들게 되었습니다. 
> - 사실 제가 친구들과 사용하려 만든 앱입니다 🙂‍↕️ 
친구들과의 만남을 추억하기 위한 앱입니다. 

### 1.2 Concept
> - 그룹 구성원을 정하고 ,그룹 안에서  약속의 시간과 장소를 정해,
직접 장소를 업데이트하고 이를 공유할 수 있도록 했습니다. 
> - 기본적으로는 그룹채팅앱입니다.

### 1.3 프로젝트 개요 

- 프로젝트 기간 : 2025.04 ~ 2025.07
- 개발 인원 : 1인개발 
- 담당 역할 : 
  - 기획 및 설계: 아이디어 구체화, 기능 정의, 전체 아키텍처 설계
  - UI/UX 디자인 : Figma를 사용한 전체 화면 디자인
  - 앱 개발 : Flutter 클라이언트 전체 개발
  - 서버 개발 : Firebase 및 Cloud Functions 백엔드 개발 
- 앱스토어 등록 : 현재 심사 진행 중입니다.


---

## 2. 프로젝트 기술 스택 
### 2.1 Flutter & Dart 
- Flutter 기반 앱 로직 구현
- MVVM 아키텍처 적용

### 2.2 Firebase 
- Auth : 구글 로그인, 애플 로그인
- FireStore : db 사용 , 유저, 약속, 그룹, 채팅 등 실시간 데이터 저장 및 스트리밍
- FCM : 푸시 메시지 전송
- Cloud Functions : 탈퇴 / 그룹 삭제 시 문서 트리거 , 약속 생성시 Cloud Task예약, Fcm발송
- Cloud Tasks : 약속 1시간 전 예약 푸시 알림
- Storage : 기본 이미지 URL 저장

### 2.3 GetX 
- 상태관리
- 라우팅
- 의존성 주입

### 2.4 GeoLocator
- 현재 위치 가져오기에 사용 
- 약속 생성 기본 좌표 및 약속 뷰에 사용

### 2.5 Kakao Local Api 
- 주소 -> 좌표 변환 
- 좌표 -> 주소 변환
- 키워드 -> 장소 검색 ( ex) 서울역 카페

### 2.6 Flutter Naver Map 패키지 이용 
- 좌표 기반 약속 및 사용자 위치를 지도에 출력하기 위해 사용

### 2.7 Lottie 
- 로딩 애니메이션 위해 사용
  
---

## 3. 프로젝트에 사용된 Architecture

이 프로젝트는 [Flutter 공식 아키텍처 가이드](https://docs.flutter.dev/app-architecture)를 바탕으로 MVVM (Model-View-ViewModel) 패턴을 구현했습니다. 핵심 원칙은 관심사의 분리로, 각 계층은 자신만의 책임을 가지며 UI, 비즈니스 로직, 데이터 접근 코드가 서로 독립적으로 작동하도록 구성했습니다.

---
#### MVVM 및 계층 구조

앱은 `Presentation` → `Domain` → `Data` 순서의 의존성 규칙을 따르는 3개의 논리적 계층으로 구성됩니다.

* **Presentation Layer**: 사용자에게 보여지는 모든 것을 책임지는 영역입니다.
    * **View**: 현재 상태(State)에 따라 UI를 그리고, 사용자의 상호작용을 ViewModel에 전달합니다.
    * **ViewModel**: View를 위한 데이터와 UI 상태를 관리합니다. Repository를 호출하고, 복잡한 로직은 UseCase에 위임하여, 그 결과를 UI가 즉시 반응할 수 있는 상태로 가공하여 제공합니다.

* **Domain Layer** ViewModel이 처리하기엔 복잡한 로직을 모아놓은 영역입니다.
    * **UseCase**: 여러 데이터를 조합하거나, CRUD를 제외한 복잡한 비즈니스 로직을 캡슐화합니다. (예: `GetFriendsWithStatusUseCase`)

* **Data Layer**: 데이터의 출처와 실제 통신을 책임지는 영역입니다.
    * **Repository**: 데이터 소스를 추상화하여 Domain 계층에 일관된 API를 제공하고, 원시 데이터를 앱에서 사용할 Model 객체로 변환합니다.
    * **Service**: Firebase, 외부 API 등과 직접 통신하는 실무를 담당합니다.
    * **Data Model**: Firestore 문서의 스키마를 정의하며, 직렬화/역직렬화를 책임집니다.

---
#### 선언형 UI 및 단방향 데이터 흐름

UI는 ViewModel의 상태(State)가 변경되면, 그 새로운 상태에 맞춰 효율적으로 다시 그려내는 선언형 구조를 따릅니다. 데이터는 아래와 같이 예측 가능한 단방향으로 흐릅니다.

* **요청**: `View` → `ViewModel` → `Repository` → `Service`
* **응답**: `Service` → `Repository` → `ViewModel` → `View`

<details>
<summary><b>코드 예시: 친구 검색 기능의 데이터 흐름</b></summary>

*사용자가 View에서 친구 ID를 검색하면, 그 이벤트는 ViewModel을 거쳐 Repository까지 전달되어 데이터를 가져옵니다. 그 결과는 다시 ViewModel의 상태 변수(`searchedUser`)에 반영되고, Obx 위젯이 이를 감지하여 UI를 자동으로 업데이트합니다.*

```dart
// AddFriendView.dart
class AddFriendView extends GetView<AddFriendViewModel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 사용자가 버튼을 눌러 이벤트를 발생시킴
        ElevatedButton(
          onPressed: () => controller.searchFriend("friend_id"),
          child: Text("친구 검색"),
        ),

        // 4. ViewModel의 상태가 바뀌면, Obx가 이를 감지하여 UI를 다시 그림
        Obx(() {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          }
          final user = controller.searchedUser.value;
          if (user != null) {
            return Text("${user.name} 님을 찾았습니다!");
          }
          return Text("검색 결과가 없습니다.");
        }),
      ],
    );
  }
}

// AddFriendViewModel.dart
class AddFriendViewModel extends GetxController {
  final UserRepository _userRepository;
  AddFriendViewModel({required this.userRepository});

  // 3. UI가 관찰할 '상태' 변수
  final Rxn<UserModel> searchedUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  // 2. View로부터 호출되어 비즈니스 로직을 처리
  Future<void> searchFriend(String uniqueId) async {
    isLoading.value = true;
    searchedUser.value = null; 
    try {
      // Repository에 데이터 요청을 위임
      final friend = await _userRepository.getUserByUniqueId(uniqueId);
      // 결과에 따라 상태 업데이트
      searchedUser.value = friend;
    } finally {
      isLoading.value = false;
    }
  }
}
```

</details>

---

### 의존성 주입 (DI)

이 프로젝트의 의존성 주입은 GetX를 사용하여 관리합니다. 
의존성은 두 가지 전략을 사용합니다. 

- **전역 의존성** : 앱 전반에서 사용되는 핵심 서비스 및 저장소 (Service, Repository)
- **뷰모델 의존성** : 특정 화면의 상태와 로직을 담당하는 클래스 

#### 전역 의존성 
의존성은 전역 싱글턴으로 주입했습니다. 
앱 전반에서 공유되며 상태를 가지지 않는 **Repository와 Service는 전역 싱글턴(Global Singleton)으로 
주입**하여 어디서든 안정적으로 접근할 수 있도록 했습니다.

```dart
.. core/dependency/dependency_injection.dart 
class DependencyInjection {
  static Future<void> init() async {
    final kakaoApiKey = dotenv.env['KAKAO_REST_API_KEY']!;
    final kakaoBaseUrl = dotenv.env['KAKAO_BASE_URL']!;
    final fcmFunctionUrl = dotenv.env['FIREBASE_FCM_FUNCTION_URL']!;
    final fcmService = NotificationApiService(functionUrl: fcmFunctionUrl);

    Get.put<NotificationApiService>(fcmService, permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    ... 
main.dart 
main() async { 
...

  await DependencyInjection.init();

...

```

#### 뷰모델 의존성 
특정 화면의 상태를 책임지는 ViewModel은 해당 화면으로 이동하는 순간에만 
생성 및  주입하는 라우트 기반 의존성 주입 방식을 사용합니다. 
이러한 방식은 각 화면의 독립성을 보장하고 
메모리 누수를 방지합니다. 
```
                          Get.to(
                            () => const UserProfileView(),
                            fullscreenDialog: true,
                            transition: Transition.downToUp,
                            binding: BindingsBuilder(() {
                              Get.put(
                                UserProfileViewModel(
                                  userRepository: Get.find<UserRepository>(),
                                  authRepository: Get.find<AuthRepository>(),
                                  chatRepository: Get.find<ChatRepository>(),
                                  getSingleUserWithStatusUsecase:
                                      Get.find<
                                        GetSingleUserWithStatusUsecase
                                      >(),
                                  targetUserUid: friendInfo.userModel.uid,
                                ),
                              );
                            }),
                          );
```
---




## 4. 프로젝트 구조 
```
lib/
┣ core/                            # 앱 전역 설정 및 유틸리티 모음
┃ ┗ dependency/                   # 전역 의존성 주입 설정 (Get.put 등)
// data layer //
┣ data/                            # 데이터 계층 (외부와 직접 통신)
┃ ┣ model/                        # Firestore 문서 구조 정의 (User, Group 등)
┃ ┃ ┣ location_model/            # 위치 관련 모델 (좌표, 주소 등)
┃ ┣ repository/                  # Service와 ViewModel 사이 추상화 계층
┃ ┗ service/                     # Firebase 및 외부 API 직접 호출 계층
// domain layer //
┣ domain/                          # 도메인 계층 (비즈니스 로직)
┃ ┗ usecase/                     # 재사용 가능한 복잡한 로직 (ex. 거리 계산, 차단 체크 등)
// presentation layer //
┣ presentation/                    # UI 및 상태 관리 계층
┃ ┣ bottomNav/                   # 메인 하단탭 화면 관련
┃ ┃ ┣ home/                      # 홈 탭 관련 화면
┃ ┃ ┃ ┣ group/                 # 그룹 관련 뷰
┃ ┃ ┃ ┃ ┣ create_group/       # 그룹 생성 뷰
┃ ┃ ┃ ┃ ┣ lounge_in_group/    # 그룹 내 채팅 라운지
┃ ┃ ┃ ┃ ┣ promise/            # 약속 관련 뷰
┃ ┃ ┃ ┃ ┃ ┣ late/             # 지각 상태 뷰
┃ ┃ ┃ ┃ ┃ ┣ location_share/   # 위치 공유 뷰
┃ ┃ ┃ ┃ ┃ ┣ promise_info/     # 약속 상세정보 뷰
┃ ┃ ┃ ┃ ┣ promise_log/        # 약속 히스토리 뷰
┃ ┃ ┃ ┃ ┃ ┣ component/        # 약속 로그에서 재사용되는 컴포넌트
┃ ┃ ┃ ┣ private_chat/         # 1:1 채팅 뷰
┃ ┃ ┃ ┃ ┣ add_friend/         # 친구 추가 뷰
┃ ┃ ┃ ┃ ┣ private_chat_room/  # 1:1 채팅방 뷰
┃ ┃ ┃ ┣ promise/              # 약속 생성 흐름
┃ ┃ ┃ ┃ ┣ create_promise/     # 약속 정보 입력 뷰
┃ ┃ ┃ ┃ ┣ select_location/    # 위치 선택 뷰
┃ ┃ ┃ ┃ ┗ select_time/        # 시간 선택 뷰
┃ ┃ ┣ notification/           # 푸시 알림 뷰
┃ ┃ ┣ setting/                # 설정 화면
┃ ┃ ┃ ┗ component/            # 설정 내 UI 구성요소
┃ ┣ core/                     # 공통 UI 요소
┃ ┃ ┣ dialog/                 # 공통 다이얼로그
┃ ┃ ┣ loading/                # 로딩 애니메이션
┃ ┃ ┣ widget/                 # 재사용 위젯 모음
┃ ┃ ┃ ┗ chat/                 # 채팅 관련 공통 위젯
┃ ┃ ┗ filter_words.dart       # 욕설 필터 리스트
┃ ┣ login/                    # 로그인 화면
┃ ┃ ┗ unique_id_input/        # 유저 고유 ID 입력 화면
┃ ┣ models/                   # View 전용 모델 (UI 상태나 응답 매핑)
┃ ┣ report/                   # 신고 기능 화면
┃ ┣ splash/                   # 앱 시작시 스플래시 화면
┃ ┗ user_profile/             # 사용자 프로필 화면

┣ routes/                          # 라우팅 설정
┃ 
┗ main.dart                         # 앱 시작점 (runApp)
```
---

## 5. 주요기능

### 5.1 그룹: 약속을 위한 베이스캠프 (핵심 기능)

ETA의 모든 약속은 그룹에서 시작됩니다. 그룹은 약속을 함께할 멤버들을 모아두고, 
약속 전후로 소통하며, 지난 약속의 추억을 기록하는 중심 공간입니다.


|그룹화면 | 그룹채팅방 |
|:--:|:--:|
|<img width="198" height="430" alt="group" src="https://github.com/user-attachments/assets/ef8a8fba-3f02-4511-9fd8-3bf6d5ebf630" />|<img width="198" height="429" alt="IMG_4546" src="https://github.com/user-attachments/assets/f96f7901-52ab-47a8-adab-6fbd0ded1ab8" />|

**주요 기능**
**약속 관리**: 그룹 내에서 새로운 약속을 생성하고, **진행 중인 약속의 상태를 확인**하며, 
**마감된 약속**의 기록을 **'기록'** 형태로 모아볼 수 있습니다.

**실시간 그룹 채팅 채널**: 모든 그룹은 실시간 채팅이 가능한 **그룹 채팅**을 가집니다. 약속에 대한 논의뿐만 아니라, 약속 시간 알림, 참여자 도착 정보 등 주요 이벤트가 시스템 메시지로 공유되어 모든 멤버가 상황을 쉽게 파악할 수 있습니다.
또한 실시간 그룹 채팅에서도 **약속 정보를 확인**할 수 있습니다.

**멤버 관리**: 친구를 그룹에 자유롭게 초대할 수 있으며, 그룹을 생성한 **그룹장**은 
**약속 마감 등 일부 관리**권한을 가집니다.

### 5.2 약속 및 위치 공유 (⭐ 핵심 기능)
그룹 내에서 약속을 생성하고, 참여자들의 실시간 위치를 공유하여 약속의 전 과정을 투명하고 즐겁게 만드는 어딧삼 의 핵심 기능입니다.

#### 1. 약속 생성: '언제 어디서 만날까?'
그룹 멤버들과 함께 할 약속의 이름, 시간, 장소, 참여 멤버를 직접 설정하여 새로운 약속을 생성할 수 있습니다.

장소 검색: Kakao Local API를 활용하여 키워드 또는 주소 검색으로 정확한 약속 장소를 설정할 수 있습니다. 검색 결과는 페이지네이션으로 제공되어 사용성을 높였습니다.

위치 확인: Naver Map 을 통해 검색된 장소를 지도 위에서 시각적으로 확인하며 최종 약속 장소를 결정합니다.
| 약속 생성하기 | 약속 장소 검색하기 |
|:--:|:--:|
| <img width="198" height="430" alt="createPromise" src="https://github.com/user-attachments/assets/a98efdab-abac-45d0-a5f5-1ec22f80774a" />|<img width="198" height="430" alt="searchLocat2" src="https://github.com/user-attachments/assets/1890e8a9-db08-4a31-a035-6a3a74154af3" />|


#### 2. 약속 진행: '누가 어디쯤 오고 있지?'
**생성된 약속 화면에서는 모든 참여자의 상태를 한눈에 파악할 수 있습니다.**

**실시간 위치 공유**: 참여자가 '**위치 공유**'를 시작하면, 다른 멤버들은 지도 위에서 해당 멤버의 **실시간 위치**를 확인할 수 있습니다.

**도착 처리**: 약속 장소 100m 반경 내에 진입 후 ,도착 버튼을 누르면  '도착' 처리됩니다. 이 정보는 그룹 채팅방에도 **시스템 메시지로 공유**됩니다.

| 약속화면 | 위치공유 | 위치공유했을때 채팅방 | 업데이트된 유저 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="promise" src="https://github.com/user-attachments/assets/b5f954b7-4821-478d-acc2-804a9366f3d1" />| <img width="198" height="430" alt="share" src="https://github.com/user-attachments/assets/6b95fecc-703e-4832-ab5a-9f8554e657cd" />| <img width="198" height="430" alt="shareAfter1" src="https://github.com/user-attachments/assets/722f188b-2700-4be1-ac10-3d18bcc54b7e" /> |<img width="198" height="430" alt="shareAfter2" src="https://github.com/user-attachments/assets/c2f383e7-0a59-477b-8879-cce01812a8ca" />|



#### 3. 약속 종료: '누가 왔고, 누가 늦었나?'
약속 시간이 되면, 약속 현황판은 도착자와 지각자를 명확하게 구분하여 보여줍니다. 
그룹장은 언제든지 약속을 '마감'할 수 있으며, 마감된 약속은 그룹의 '지난 약속 기록'으로 남아 언제든 다시 확인할 수 있습니다.
 <img width="198" height="429" alt="IMG_4550" src="https://github.com/user-attachments/assets/804ccd99-9ba3-4dfb-a54a-bcf923b90084" />

### 5.3 친구관리 및 1:1채팅 
**어딧삼**의 모든 소셜 활동은 **친구 관계**에서 시작됩니다. 이 기능은 사용자가 자신의 소셜 그래프를 관리하고, 친구와 안전하게 1:1로 소통할 수 있는 기반을 제공합니다.
| 기본 화면 | 친구추가 화면 | 채팅 화면 | 
|:--:|:--:|:--:|
|<img width="198" height="430" alt="mainHome1" src="https://github.com/user-attachments/assets/13d2f89e-9a4c-423b-a13e-38346643d048"/>| <img width="198" height="430" alt="addFriend" src="https://github.com/user-attachments/assets/346f3b3d-1c21-4282-86f7-5a0514964098" /> | <img width="198" height="430" alt="chat" src="https://github.com/user-attachments/assets/90a40801-168b-48d4-ab90-3812fef38861" /> |

**주요 기능**
**친구 관리**: 고유 ID 검색을 통해 손쉽게 친구를 추가하고, 내 친구 목록을 관리할 수 있습니다.

**1:1 채팅**: 친구와 개인적인 대화를 나눌 수 있는 채팅방을 제공합니다. 
스크롤 기반 페이지네이션을 적용하여, 대화 내용이 많아도 효율적으로 메시지를 로드합니다.

**실시간 상태 반영**: 상대방과의 친구 관계나 나의 차단 상태가 변경되면, 채팅 목록과 채팅방 UI가 즉시 반응하여 업데이트됩니다. 이를 통해 사용자는 항상 최신 관계를 기반으로 안전하게 상호작용할 수 있습니다.

### 5.4 사용자 프로필 및 보호 기능 
다른 사용자의 프로필을 확인하고, 관계를 관리하며, 스스로를 보호할 수 있는 필수적인 기능입니다.
| 차단한 후 | 상대 유저 프로필 | 신고화면 |
|:--:|:--:|:--:|
| <img width="198" height="430" alt="blockUser" src="https://github.com/user-attachments/assets/6ad649eb-a8fb-4a18-a019-a7393e87a32f" /> | <img width="198" height="430" alt="IMG_4537" src="https://github.com/user-attachments/assets/3a76f4c2-956d-449b-83b1-6fb7eb516be3" /> |<img width="198" height="430" alt="IMG_4538" src="https://github.com/user-attachments/assets/0e95b29b-3fa5-4234-9da1-4d07a419b819" />|

**주요 기능**
**프로필 확인 및 상호작용**: 사용자의 프로필에서 이름, 고유 ID, 사진 등 기본 정보를 확인할 수 있으며, '1:1 채팅하기', '친구 추가/삭제' 등 주요 상호작용을 시작할 수 있습니다.

**실시간 관계 관리**: 프로필 화면은 '나'와 '상대방'의 관계(친구 여부, 차단 여부)가 변경될 때마다 실시간으로 UI가 업데이트됩니다. 예를 들어, 사용자를 차단하는 즉시 프로필 화면은 '차단된 사용자' 상태로 변경됩니다.

**사용자 보호 기능**: 모든 사용자는 다른 사용자를 차단하여 메시지 수신 및 프로필 조회를 포함한 대부분의 상호작용을 막을 수 있습니다. 또한, 불쾌한 경험을 했을 경우, 특정 카테고리를 선택하여 사용자를 신고할 수 있는 기능을 제공하여 앱 스토어 가이드라인을 준수합니다.
*차단한 유저는 그룹 내에서도 필터링됩니다


---
## 6. 데이터베이스 모델 구조 (firestore)

<img width="935" height="932" alt="스크린샷 2025-07-15 오후 9 18 00" src="https://github.com/user-attachments/assets/21e1fe4c-3a3e-46ed-b36c-714419c32bed" />


Firestore를 주 데이터베이스로 사용하며, 주요 최상위 컬렉션의 구조와 문서 ID 생성은 다음과 같습니다.

| 컬렉션 (Collection) | 주요 역할 | 문서 ID (Document ID) |
| :--- | :--- | :--- |
| **`users`** | 사용자 프로필, 친구/차단 목록 | Firebase Auth **UID** |
| **`groups`** | 그룹 정보, 멤버 목록, 약속 관리 | Firestore **자동 생성 ID** |
| **`privateChatRooms`** | 1:1 채팅방 정보 및 메시지 | 2명의 UID를 조합한 **복합 키** |
| **`promises`** | 약속 상세 정보 및 참여자 | Firestore **자동 생성 ID** |
| **`reports`** | 사용자 신고 내역 | Firestore **자동 생성 ID** |

<br>

* **하위 컬렉션 (Subcollections)**
  * `users/{uid}/messages`: 개인에게 보내진 푸시 알림 내역을 저장합니다.
  * `groups/{gid}/messages`: 해당 그룹의 채팅 메시지를 저장합니다.
  * `privateChatRooms/{cid}/messages`: 해당 1:1 채팅방의 메시지를 저장합니다.
---


## 7. 주요 트러블 슈팅 및 문제 해결 경험 


### 7.1 비효율적인 폴링(Polling) 방식의 알림 시스템 개선

#### **문제점: 주기적인 전체 데이터 스캔의 비효율과 비용**

프로젝트 초기 버전에서는 약속 시간 알림을 구현하기 위해, **주기적으로(예: 10분마다) 모든 `promises` 문서를 읽는** 폴링(Polling) 방식을 사용했습니다.

이 방식은 구현은 간단했지만, 약속이 있든 없든 정해진 시간마다 모든 문서를 스캔해야 했습니다. 이는 프로젝트 규모가 커질수록 불필요한 **데이터 읽기(Read) 비용을 기하급수적으로 증가**시키고, 서버에 지속적인 부하를 주는 매우 비효율적인 구조였습니다.

#### **해결책: Cloud Tasks를 이용한 이벤트 기반 작업 예약**

이 문제를 해결하기 위해, 비효율적인 폴링 방식 대신 **Google Cloud Tasks**를 도입하여 **이벤트 기반의 작업 예약 시스템**으로 전환했습니다.

1.  **작업 예약 (`schedulePromiseOnCreate`)**: `onDocumentCreated` 트리거를 사용하여, 새로운 약속 문서가 생성되는 바로 그 시점에만 함수가 실행됩니다. 이 함수는 약속 시간(예: 1시간 전, 정각)에 맞춰 알림을 보낼 `handlePromiseTask` 함수의 실행을 Cloud Tasks에 **정확한 시간으로 예약**합니다.
2.  **예약된 작업 실행 (`handlePromiseTask`)**: Cloud Tasks는 예약된 시간이 되면, 약속 ID가 포함된 요청을 `handlePromiseTask` 함수에 보내 알림 발송 등 필요한 작업을 정확하게 수행하도록 합니다.

```javascript
// functions/index.js

// 1. 약속이 생성될 때 '미래의 작업'을 예약합니다.
exports.schedulePromiseOnCreate = onDocumentCreated("promises/{docId}", async (event) => {
  const data = event.data.data();
  const promiseTime = data.time.toDate();
  const oneHourBefore = new Date(promiseTime.getTime() - 60 * 60 * 1000);

  // Cloud Tasks에 '1시간 전 알림'과 '정각 알림' 작업을 예약
  await createTask("notify1Hour", oneHourBefore);
  await createTask("notifyStart", promiseTime);
});

// 2. 예약된 시간에 정확히 호출되는 함수
exports.handlePromiseTask = functions.https.onRequest(async (req, res) => {
  // 약속 ID를 받아 알림 발송 등 필요한 작업만 수행
  const { docId, type } = req.body;
  // ...
});
```

#### **개선 결과**

* **비용 및 리소스 절감**: 더 이상 불필요하게 전체 데이터베이스를 스캔하지 않습니다. 오직 '약속 생성'이라는 이벤트가 발생할 때만 함수가 실행되고, 필요한 작업을 한 번만 예약하므로 **Firestore 읽기 비용과 서버 리소스를 대폭 절감**했습니다.
* **정확성 및 확장성**: 각 약속마다 고유한 작업이 예약되므로, 지연이나 누락 없이 **정확한 시간에 알림**이 발송됩니다. 또한 사용자가 늘어나도 시스템에 가해지는 부하가 거의 없어 확장성이 크게 향상되었습니다.

#### **배운것**
이 경험을 통해, 사용자 경험은 프론트엔드뿐만 아니라 효율적인 백엔드 설계에서 시작된다는 점을 깊이 깨달았고, 실제 서비스의 확장성과 비용까지 고려하는 개발자로 성장하겠습니다.

### 7.2 비동기 처리 최적화를 통한 UX 개선

#### **문제점: 불필요한 대기 시간**

그룹 생성 기능 실행 시, DB 저장과 같은 핵심 작업이 끝났음에도 불구하고, 부가적인 **FCM 푸시 알림 전송이 완료될 때까지** 사용자가 기다려야 하는 문제가 있었습니다.

Stopwatch를 이용한 실측 결과, 이로 인해 사용자는 버튼 클릭 후 다음 화면으로 넘어가기까지 평균 **약 6초의 불필요한 대기 시간**을 겪고 있었습니다.

#### **해결책: 비동기 처리 개선**

사용자 경험을 개선하기 위해, **그룹 생성 자체는 DB에 저장되는 시점에 완료**된다고 판단하고, 푸시 알림 전송은 백그라운드에서 처리되도록 로직을 분리했습니다.

`await` 키워드를 제거하여, 앱이 푸시 알림 전송 완료를 기다리지 않고 즉시 다음 UI 로직을 실행하도록 변경했습니다.

```dart
// 기존 코드
// await _notificationApiService.sendGroupNotification(...);

// 수정 후: await를 제거하여 결과를 기다리지 않고 다음으로 넘어감
_notificationApiService.sendGroupNotification(...);
```

#### **개선 결과: 응답 시간 88% 단축**

* **변경 전**: 평균 `6,074ms` (약 6초)
* **변경 후**: 평균 `692ms` (약 0.7초)

`await` 키워드 하나를 제거하는 간단한 코드 수정만으로, 사용자 체감 응답 시간을 **약 88% 개선**하여 훨씬 쾌적한 앱 사용 경험을 제공할 수 있게 되었습니다. 이는 비동기 코드의 동작 방식을 이해하고 사용자 경험 관점에서 로직을 최적화한 의미 있는 개선 사례입니다.

#### **배운것**
이전엔 안전한 코드를 우선으로 작성했지만 이 개선을 통해 비동기 코드에 대한 이해가 보다 깊어졌습니다.
await 을 사용해야 할 때는 결과를 기다려야 할때 사용해야하고 
await 을 사용하지 않을때는 비동기 작업의 완료 여부가 사용자의 다음 행동이나 
UI 업데이트에 즉시 영향을 주지 않을때 사용해야 하는 것이라 느꼈습니다.
사용자 경험을 최우선으로 고려하여 성능을 최적화하는 개발자로 성장하겠습니다. 

---

### 7.3 도메인 레이어 적용

#### **문제점: ViewModel의 역할 과부하와 복잡성 증가**

'사용자 차단' 기능이 추가되면서, 화면에 다른 사용자 목록을 표시하는 로직이 매우 복잡해졌습니다.

하나의 ViewModel이 친구 목록을 보여주기 위해, 
1. 나의 최신 정보(차단 목록)를 가져오고, 
2. 친구들의 프로필 정보를 가져온 뒤, 
3. 두 데이터를 조합하여 각 친구의 최종 상태(정상, 차단, 탈퇴)를 판단해야 했습니다.

이러한 로직은 Flutter 공식 아키텍처 가이드에서 언급하는 **"여러 Repository의 데이터를 조합"**하고, "로직이 매우 복잡하며", "여러 ViewModel에서 재사용될" 필요가 있는 전형적인 사례였습니다. 이처럼 복잡한 비즈니스 로직이 UI 상태를 관리해야 하는 ViewModel에 직접 포함되자, ViewModel의 코드가 비대해지고 복잡해지는 발생했습니다.


#### **해결책: UseCase를 통한 비즈니스 로직 캡슐화**

이 문제를 해결하기 위해, 공식 가이드의 권장 사항에 따라 **Domain Layer**를 선택적으로 적용했습니다. 사용자의 상태를 판단하는 모든 로직을 `GetFriendsWithStatusUseCase`라는 단일 클래스로 캡슐화하여 분리했습니다.

이 UseCase는 **특정 유저 목록의 최종 관계 상태를 판단한다**는 단 하나의 명확한 책임을 가집니다. 이를 통해 ViewModel은 더 이상 '어떻게' 상태를 계산하는지 알 필요 없이, UseCase에 작업을 위임하고 최종 결과만 받아서 사용하는 이상적인 구조가 되었습니다.

```dart
// domain/usecase/get_friends_with_status_usecase.dart
class GetFriendsWithStatusUsecase {
  // ...
  Future<List<FriendInfoModel>> assignStatusToUsers({required List<String> uids}) async {
    // 1. 나의 최신 차단 목록을 가져옴
    final blockUids = (await _userRepository.getUser(myUid))?.blockFriendsUids ?? [];
    
    // 2. 파라미터로 받은 대상 유저들의 정보를 가져옴
    final userList = await _userRepository.getUsersByUids(uids);

    // 3. 두 정보를 조합하여 상태(blocked, deleted, active)를 결정하고 반환
    return uids.map((uid) {
      if (blockUids.contains(uid)) {
        return FriendInfoModel(userModel: UserModel.blocked(uid), status: UserStatus.blocked);
      }
      final user = userList.firstWhereOrNull((u) => u.uid == uid);
      if (user == null) {
        return FriendInfoModel(userModel: UserModel.unknownWithUid(uid), status: UserStatus.deleted);
      }
      return FriendInfoModel(userModel: user, status: UserStatus.active);
    }).toList();
  }
}
```

#### **개선 결과**

* **명확한 역할 분리**: ViewModel은 UI 상태 관리에만 집중하고, 복잡한 비즈니스 로직은 UseCase가 전담하게 되어 각 클래스의 책임이 명확해졌습니다.
* **코드 단순화 및 안정성 향상**: ViewModel의 코드가 극적으로 단순해졌고, 사용자 상태 처리에 대한 규칙이 통일되어 앱 전체의 안정성이 향상되었습니다.

#### **배운점**
초기에는 관리 포인트가 늘어난다는 생각에 UseCase의 도입을 주저했습니다. 하지만 개발 막바지에 '사용자 차단'이라는 복잡한 요구사항이 추가되었을 때, 미리 계층을 분리해 둔 덕분에 새로운 비즈니스 로직을 기존 코드에 최소한의 영향만으로 유연하게 통합하고 확장할 수 있었습니다.

사실은 글로만 알던 지식이지만, 
복잡한 비즈니스 로직은 Domain Layer를 적용하면 ViewModel의 상태관리가 편해진다는 것을 깊게 체감했습니다.

---

### 7.4 복잡한 초기 설계를 뒤엎은 대규모 리팩토링

#### **문제점: 불명확한 사용자 경험과 복잡한 구조**

프로젝트 초기 버전은 의욕이 앞서 너무 많은 기능을 담으려 했습니다. '그룹' 안에 여러 '약속'이 존재하고, 다시 그 '약속' 안에 별도의 '채팅방'과 '벌칙 투표', '정산' 기능까지 얽혀있었습니다.

이로 인해 사용자에게 **"그래서 이 앱은 뭘 하는 앱이지?"** 라는 혼란을 주었고, 데이터 구조와 화면 흐름이 지나치게 복잡해져 개발 과정에서 수많은 버그를 유발했습니다. 프로젝트의 핵심 가치인 '간단한 약속 관리'가 흐려지고, 개발 방향성마저 잃어버릴 뻔한 큰 위기였습니다.

#### **해결책: 핵심 가치에 집중한 과감한 재설계**

문제의 본질을 해결하기 위해, 이미 만든 기능을 버리는 것을 감수하고 아래와 같은 원칙으로 프로젝트 전체를 재설계했습니다.

1.  **'1그룹 1진행 약속' 원칙 수립**: 그룹 내 활성 약속은 단 하나만 존재하도록 구조를 단순화했습니다. 이를 통해 사용자는 현재 가장 중요한 약속에만 집중할 수 있게 되었습니다.

2.  **부가 기능 제거**: 앱의 핵심을 흐리는 '벌칙 투표'와 '정산' 기능을 과감히 제거했습니다.

3.  **직관적인 레이아웃 도입**: 복잡했던 채팅방 위주의 구조를 버리고, **'사이드 탭' 기반의 레이아웃**을 도입하여 '그룹'과 '채팅'의 공간을 명확히 분리했습니다.

4.  **'약속'의 역할 재정의**: 약속의 역할을 복잡한 기능의 집합이 아닌, 오직 **'참여자들의 상태(위치, 도착 여부)를 공유하는 보드'**로 명확히 하여 핵심 기능에만 집중하도록 했습니다.

#### **개선 결과**

* **명확한 사용자 경험**: 이제 사용자는 **그룹에 모여서 → 약속을 잡고 → 약속 보드에서 현황을 확인한다**는 매우 직관적이고 명확한 흐름을 경험할 수 있게 되었습니다.
* **단순화된 아키텍처**: 데이터 모델과 ViewModel의 책임이 단순해지면서 코드의 양이 줄고, 예측 가능한 구조가 되어 버그 발생률이 현저히 감소했습니다.
* **개발 방향성 확립**: 이 과감한 재설계 과정을 통해 앱의 핵심 정체성을 확립할 수 있었고, 이후의 개발 과정을 훨씬 더 빠르고 자신감 있게 진행할 수 있는 원동력이 되었습니다.

#### **배운점**
이 경험을 통해, 제품의 핵심 가치에 집중하기 위해 때로는 과감히 기능을 덜어내는 결정이, 결국 더 명확한 사용자 경험과 안정적인 아키텍처를 만든다는 것을 배웠습니다.

---

## 8. 이번 프로젝트 회고 

이 프로젝트는 기술적인 도전만큼이나, 좋은 제품을 만들기 위한 기획과 설계, 그리고 유지보수의 중요성을 깊이 깨닫게 된 성장의 과정이었습니다.

#### **1. 기획 및 설계의 중요성**
"일단 만들자"는 접근 방식의 한계를 깨달았습니다. 기능의 모든 예외 상황과 사용자 권한(예: 그룹장)을 미리 상세하게 설계하는 것이, 결국 개발 후반의 더 큰 비용을 막는다는 것을 배웠습니다. 하나의 기능을 명확히 이해하지 못하면, 앱 전체가 방향을 잃는다는 것을 직접 경험했습니다.

#### **2. 아키텍처와 코드 품질**
'보이스카우트 원칙'을 체감한 프로젝트였습니다. 프로젝트가 복잡해질수록 명확한 네이밍(Naming)과 단일 책임 원칙이 얼마나 중요한지 느꼈습니다. 특히 개발 막바지에 '사용자 차단'과 같은 복잡한 요구사항이 추가되었을 때, 초기에 분리해 둔 UseCase와 Repository의 역할이 명확했기 때문에 다른 코드를 거의 수정하지 않고도 새로운 기능을 유연하게 통합할 수 있었습니다. 만약 계층을 나누지 않았다면 수정이 불가능했을 것이라 생각합니다.

#### **3. 상태 관리와 UI 반응성**
'상태'를 어떻게 설계하고 관리하는지가 앱의 안정성에 얼마나 치명적인지를 배웠습니다. 초기에는 여러 비동기 상태들을(로딩, 데이터 유무, 에러 등) 명확하게 구분하지 않아, UI가 데이터 변경에 반응하지 않거나 '무한 로딩'에 빠지는 문제를 겪었습니다.

특히 '차단된 유저'와 '탈퇴한 유저'의 상태를 각기 다른 변수로 관리하려 했을 때, ViewModel이 걷잡을 수 없이 복잡해지며 개발을 이어가기 힘든 인지 부조화를 겪었습니다. 이 문제를 UseCase를 통해 가공된 단일 상태 모델(FriendInfoModel)로 통합하면서, ViewModel의 상태 변수는 최소한으로, 그리고 명확하게 유지해야 한다는 원칙의 중요성을 깨달았습니다.

#### **4. 백엔드 설계와 사용자 경험**
초기 폴링(Polling) 방식의 알림 시스템을 이벤트 기반(Event-Driven)의 Cloud Tasks로 개선하며, 비효율적인 백엔드 설계가 어떻게 사용자 경험에 직접적인 악영향을 미치는지 배웠습니다. 안정적이고 확장성 있는 서비스는 클라이언트뿐만 아니라, 비용과 성능까지 고려한 서버 설계에서 시작된다는 것을 깨달았습니다.

#### **5. 정책 준수와 제품 출시**
'코드를 완성하는 것'과 '제품을 출시하는 것'은 다른 차원의 문제임을 인지했습니다. 개발 초기에는 전혀 고려하지 못했던 사용자 차단, 계정 삭제, 개인정보 처리 등 Apple의 심사 가이드라인을 학습하고 준수하는 과정은, 기술 구현만큼이나 중요한 단계임을 배웠습니다.

---

## 9. 향후 개발 계획

* **채팅 기능 고도화**:
    * **읽음 확인 기능**: 메시지 옆에 '읽음' 표시를 추가하여, 상대방이 메시지를 확인했는지 알 수 있도록 하여 소통의 편의성을 높일 계획입니다.
    * **알림 메시지 확장**: 약속 변경, 멤버 강퇴 등 그룹 내 주요 이벤트 발생 시, 관련 내용을 담은 시스템 알림 메시지를 추가하여 멤버들이 중요한 변경사항을 놓치지 않도록 개선합니다.

* **그룹 활동 강화**:
    * **벌칙 기능 재도입**: 초기 기획 단계에서 제외했던 '벌칙' 기능을, 사용자에게 새로운 재미를 줄 수 있는 선택적 기능(Optional Feature)으로 재검토하고 도입할 계획입니다.

* **아키텍처 개선**:
    * **데이터 구조 리팩토링**: 현재 최상위 컬렉션인 `promises`를 각 `groups` 문서의 하위 컬렉션(Subcollection)으로 변경하는 것을 검토 중입니다. 이를 통해 그룹과 약속 간의 데이터 종속성을 더 명확히 하고, 보안 규칙을 더 정교하게 관리할 수 있을 것으로 기대합니다.
---

## 10. 앱 화면별 사진 모음 

| 진입화면 | 로그인화면 | 아이디입력 |
|:--:|:--:|:--:|
| <img width="199" height="372" alt="splash" src="https://github.com/user-attachments/assets/e4b7bebe-5c12-4237-bf45-2605a68f9ae3" /> | <img width="199" height="372" alt="login" src="https://github.com/user-attachments/assets/0b2fe9ca-e237-4ae2-9f63-3a8b973d71fb" /> | <img width="199" height="372" alt="input" src="https://github.com/user-attachments/assets/5a34288f-3ec2-4691-a3d3-9b1408fa2535" /> |

| 홈화면 | 친구추가 | 채팅화면 | 채팅방이있는 홈 |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="mainHome1" src="https://github.com/user-attachments/assets/13d2f89e-9a4c-423b-a13e-38346643d048" /> | <img width="198" height="430" alt="addFriend" src="https://github.com/user-attachments/assets/346f3b3d-1c21-4282-86f7-5a0514964098" /> | <img width="198" height="430" alt="chat" src="https://github.com/user-attachments/assets/90a40801-168b-48d4-ab90-3812fef38861" /> |<img width="198" height="430" alt="afterChat" src="https://github.com/user-attachments/assets/28028816-216c-4546-b86a-8e8dbaa9edbd" />|
| 유저 프로필 | 차단 | 유저프로필 팝업메뉴 | 신고 |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="userProfile" src="https://github.com/user-attachments/assets/53e2c3c1-1bf7-4bfb-bb4c-bff4f3afea9f" /> | <img width="198" height="430" alt="blockUser" src="https://github.com/user-attachments/assets/6ad649eb-a8fb-4a18-a019-a7393e87a32f" /> | <img width="198" height="430" alt="IMG_4537" src="https://github.com/user-attachments/assets/3a76f4c2-956d-449b-83b1-6fb7eb516be3" /> |<img width="198" height="430" alt="IMG_4538" src="https://github.com/user-attachments/assets/0e95b29b-3fa5-4234-9da1-4d07a419b819" />|

| 그룹생성 | 그룹 생성 후 | 그룹화면 | 그룹에 초대 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="createGroup" src="https://github.com/user-attachments/assets/af89c24d-a70e-457a-b6a0-79c55e2faca1" />| <img width="198" height="430" alt="afterCrGr" src="https://github.com/user-attachments/assets/58ee05e3-098c-4d78-b3bd-12c94027e005" />| <img width="198" height="430" alt="group" src="https://github.com/user-attachments/assets/ef8a8fba-3f02-4511-9fd8-3bf6d5ebf630" /> |<img width="198" height="430" alt="inviteGr" src="https://github.com/user-attachments/assets/3448ec7a-cd92-4b3d-8edd-093f8b0d242e" />|

| 그룹채팅 | 약속생성 | 위치정하기 | 더보기버튼 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="groupChat" src="https://github.com/user-attachments/assets/983cbca6-9320-4e38-bf67-af3dcbf381af" />| <img width="198" height="430" alt="createPromise" src="https://github.com/user-attachments/assets/a98efdab-abac-45d0-a5f5-1ec22f80774a" />| <img width="198" height="430" alt="searchLocat" src="https://github.com/user-attachments/assets/b8b439f7-d4e3-4c7d-895b-b237b49cf5e7" /> |<img width="198" height="430" alt="searchLocat2" src="https://github.com/user-attachments/assets/1890e8a9-db08-4a31-a035-6a3a74154af3" />|

| 주소검색 | 시간선택 | 시간선택 | 약속 생성 후 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="searchAddr" src="https://github.com/user-attachments/assets/6df49811-3a14-4569-b960-b81b8d4603ef" />| <img width="198" height="430" alt="selectT" src="https://github.com/user-attachments/assets/ab2b5039-17e8-4a5e-a4da-ac2fa30ede7a" />| <img width="198" height="430" alt="selectT2" src="https://github.com/user-attachments/assets/5766a363-a20b-4420-a0e7-482d73fbbbc4" /> |<img width="198" height="430" alt="proCreAft" src="https://github.com/user-attachments/assets/5ceff2b7-2c5d-49c8-b698-b1ea18e20d08" />|

| 약속화면 | 위치공유 | 위치공유 후 채팅방 | 위치공유 후 업데이트 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="promise" src="https://github.com/user-attachments/assets/b5f954b7-4821-478d-acc2-804a9366f3d1" />| <img width="198" height="430" alt="share" src="https://github.com/user-attachments/assets/6b95fecc-703e-4832-ab5a-9f8554e657cd" />| <img width="198" height="430" alt="shareAfter1" src="https://github.com/user-attachments/assets/722f188b-2700-4be1-ac10-3d18bcc54b7e" /> |<img width="198" height="430" alt="shareAfter2" src="https://github.com/user-attachments/assets/c2f383e7-0a59-477b-8879-cce01812a8ca" />|

| 끝난 약속 기록 | 알림탭 | 설정탭 |
|:--:|:--:|:--:|
|<img width="198" height="430" alt="endPromise" src="https://github.com/user-attachments/assets/6479ad3d-a7df-4193-9605-55103406752e" />| <img width="198" height="430" alt="notification" src="https://github.com/user-attachments/assets/c2625c3b-3b9b-4282-9a48-c25b35c17498" />|<img width="198" height="430" alt="setting" src="https://github.com/user-attachments/assets/a8b9919a-c7da-4b5a-a8c6-6912658b6f6e" />|























