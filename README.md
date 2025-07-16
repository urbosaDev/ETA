---
# 🦍어딧삼 
### " 약속하고 모이고 소통해요 "
그룹을 생성하고 검색을 통해 약속 장소를 잡으며
위치를 공유하는 실시간 그룹 채팅 앱입니다. 

---

## 📄목차 

목차는 다음과 같습니다  

0. 프로젝트 시연 영상 

1. 프로젝트 소개
- 1.1 Motivation
- 1.2 Concept
- 1.3 프로젝트 개요 


2. 프로젝트 기술 스택


3. 프로젝트에 사용된 Architecture
- 3.1 MVVM 구조
- 3.2 선언형 구조


4. 의존성 주입 (DI)
- ( 전역의존성 , 뷰모델 의존성 )

5. 프로젝트 구조
- ( 폴더 구조 )
  
6. 주요기능
- 6.1 스플래쉬 & 로그인 
- 6.2 기본 채팅화면 , 친구추가, 채팅
- 6.3 유저프로필, 차단, 신고
- 6.4 그룹 생성, 그룹뷰, 그룹에 초대
- 6.5 약속생성 ( 장소선택, 장소 검색, 시간정하기 )
- 6.6 약속화면, 위치공유, 위치공유 이후, 약속 마감
- 6.7 알림 화면
- 6.8 설정 화면
  
7. 데이터베이스 모델 구조 (firestore)

7. 트러블 슈팅 및 문제 해결 경험

8. 프로젝트 회고

--- 
<img width="220" height="478" alt="Group 4" src="https://github.com/user-attachments/assets/59575d38-ed89-41bb-b6cb-e7bf95451806" /><img  width="220" height="478" alt="Group 6" src="https://github.com/user-attachments/assets/f2864762-b74f-41e6-9e0b-76dac29945ab" /><img width="220"  height="478" alt="Group 7" src="https://github.com/user-attachments/assets/5d00e60f-96f9-4c98-93ef-9dee9987fdd2" /><img width="220" height="478"  alt="Group 8" src="https://github.com/user-attachments/assets/167d2f4e-b2f2-4204-bf19-2bbd6b11b078" />
---




---
## 0. 프로젝트 시연 영상 
> 해당 링크를 참고해주시면 감사하겠습니다 ;)
링크 : 
[https://www.youtube.com/watch?v=0ksjm3zotwA ](https://youtu.be/L5sbEdbAX6M)
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

이 프로젝트는 [Flutter 공식 아키텍처 가이드](https://docs.flutter.dev/app-architecture)를 바탕으로 MVVM (Model-View-ViewModel) 패턴을 구현했습니다.
핵심 원칙은 관심사의 분리로, 각 계층은 자신만의 책임을 가지며 UI, 비즈니스 로직, 
데이터 접근 코드가 서로 독립적으로 작동하도록 구성했습니다.


### 3.1 MVVM 구조
이 프로젝트는 MVVM (Model-View-ViewModel) 패턴을 결합하여 설계되었습니다. 각 계층은 명확한 책임을 가지며, Presentation → Domain → Data 순서의 의존성 규칙을 통해 코드의 안정성과 테스트 용이성을 확보했습니다.

1. Presentation Layer
사용자에게 보여지는 모든 것을 책임지는 영역입니다.

View: 현재 상태(State)에 따라 UI를 화면에 그리고, 사용자의 상호작용(버튼 클릭, 입력 등)을 ViewModel에 전달하는 역할만 합니다.

ViewModel: View가 사용할 데이터와 UI 상태를 관리합니다. 사용자의 요청이 들어오면 비즈니스 로직 처리를 하위 계층에 위임하고, 그 결과를 UI가 즉시 반응할 수 있는 상태(Rx 변수)로 가공하여 제공합니다.

2. Domain Layer
 앱의 핵심 비즈니스 로직을 처리하는 두뇌 영역입니다.

UseCase: 여러 데이터를 조합하거나, CRUD(Create, Read, Update, Delete)를 제외한 복잡한 비즈니스 로직을 캡슐화합니다. 재사용성이 높은 로직을 담당합니다.

예시: GetFriendsWithStatusUseCase (친구 목록을 가져와 차단/탈퇴 상태를 함께 부여)

3. Data Layer
 데이터의 출처와 실제 통신을 책임지는 영역입니다.

Repository: 데이터 소스를 추상화하는 역할을 합니다. Domain 계층은 이 Repository를 통해 데이터를 요청하며, 실제 데이터가 Firebase에서 오는지, 다른 API에서 오는지는 전혀 알지 못합니다. Service로부터 받은 원시 데이터를 앱에서 사용하기 좋은 Data Model 객체로 변환하여 전달합니다.

Service: 외부 데이터 소스와 직접 통신하는 실무를 담당합니다. Firebase(Firestore)나 외부 API에 직접 접근하여 원시 데이터(raw data)를 가져오거나 저장합니다.

Data Model: Firestore 문서의 데이터 구조를 정의하는 클래스입니다. fromJson/toJson을 통해 데이터의 **직렬화/역직렬화(Serialization/Deserialization)**를 책임집니다.

### 3.2 선언형 구조

ViewModel의 상태(State)가 변경되면, View는 그 새로운 상태에 맞춰 UI를 효율적으로 다시 그려내는 선언형 구조를 따릅니다.
예시로 아이디 입력란을 들어보겠습니다. 

```dart
// unique_id_input_view_model.dart 

class UniqueIdInputViewModel extends GetxController {
// ...

  Future<void> createUser() async {
    isLoading.value = true;
    try {
      // ...
      isCreated.value = await _userRepository.userExists(userModel.uid);
    } finally {
      isLoading.value = false;
    }
  }

  void onCreationHandled() {
    isCreated.value = false;
  }
}
      
// unique_id_input_view.dart 

return Obx(() {
  // ...

  if (controller.isCreated.value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed('/main');
      controller.onCreationHandled(); 
    });
  }

  // ...
});
```
사용자가 View에서 'ID 생성' 버튼을 누르면 ViewModel의 createUser 함수가 호출됩니다. ViewModel은 비즈니스 로직을 처리한 후, isCreated와 같은 반응형 상태(State)를 업데이트합니다.

### 계층화된 아키텍처

“어딧삼” 앱은 크게 3가지의 레이어로 나뉩니다. 
Presentation Layer
Domain Layer 
Data Layer 

### 단일 데이터 흐름

앱의 데이터는 단방향으로 흐릅니다. 
친구 추가 기능으로 예시를 들어보겠습니다. 
데이터 흐름은 다음과 같습니다 

사용자 이벤트 
View → ViewModel → Repository → Service

받아온 데이터 
View ← ViewModel ← Repository ← Service 

```dart

//Presentation Layer 
	// 뷰는 사용자와 상호작용하여 친구추가 버튼으로 ephemeral data를 뷰모델에 전달합니다.
(AddFriendView)
onPressed: controller.searchAddFriend(textIdController.text);
	// 뷰모델은 Repository에 위임합니다. 
(AddFriendViewModel)
Future<void> searchAddFriend(String uniqueId) async {
...
 final friend = await _userRepository.getUser(friendUid);
...
}

	// 레포지토리는 서비스에 전달하고 데이터를 변환해 받아옵니다.
(user_repository)
  @override
  Future<UserModel?> getUser(String uid) async {
    final json = await _userService.getUserData(uid);
    return json == null ? null : UserModel.fromJson(json);
  }
  
  // 서비스는 외부 db와 상호작용합니다. 
(user_service)
	  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _userRef.doc(uid).get();
    return doc.data();
  }
  ... 
  // 다시 뷰모델에 전달된 상태는 Rx값으로 저장하고, 뷰는 Rx값에 반응합니다. 
  
```

 
---
## 4. 의존성 주입 (DI)

이 프로젝트의 의존성 주입은 GetX를 사용하여 관리합니다. 
의존성은 두 가지 전략을 사용합니다. 

- **전역 의존성** : 앱 전반에서 사용되는 핵심 서비스 및 저장소 (Service, Repository)
- **뷰모델 의존성** : 특정 화면의 상태와 로직을 담당하는 클래스 

### 전역 의존성 
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

### 뷰모델 의존성 
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




## 5. 프로젝트 구조 
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

## 6. 주요기능

### 6.1 스플래쉬 & 로그인 
| Splash | Login | Input |
|:--:|:--:|:--:|
| <img width="199" height="372" alt="splash" src="https://github.com/user-attachments/assets/e4b7bebe-5c12-4237-bf45-2605a68f9ae3" /> | <img width="199" height="372" alt="login" src="https://github.com/user-attachments/assets/0b2fe9ca-e237-4ae2-9f63-3a8b973d71fb" /> | <img width="199" height="372" alt="input" src="https://github.com/user-attachments/assets/5a34288f-3ec2-4691-a3d3-9b1408fa2535" /> |

**Splash**
- 앱 시작 -> 로그인 상태 판단후 main 혹은 로그인 화면 진입. 
**Login**
- 애플 혹은 구글 로그인 제공, 
- 아이디 선택 후, firestore를 조회하여 , 해당 유저가 존재하면 main or 아이디가 없다면 UniqueIdInput 진입
**UniqueIdInput**
- 아이디 및 이름(앱내에서사용할) 지정, 
- 아이디 중복검사 및 , 비속어필터링
- 이름 비속어 필터링 후 아이디 생성 후 main진입

### 6.2 기본 채팅화면 , 친구추가, 채팅 
| PrivateChat | AddFriend | Chat | AfterChat |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="mainHome1" src="https://github.com/user-attachments/assets/13d2f89e-9a4c-423b-a13e-38346643d048" /> | <img width="198" height="430" alt="addFriend" src="https://github.com/user-attachments/assets/346f3b3d-1c21-4282-86f7-5a0514964098" /> | <img width="198" height="430" alt="chat" src="https://github.com/user-attachments/assets/90a40801-168b-48d4-ab90-3812fef38861" /> |<img width="198" height="430" alt="afterChat" src="https://github.com/user-attachments/assets/28028816-216c-4546-b86a-8e8dbaa9edbd" />|
**PrivateChat**
- 기본 채팅화면 제공
- 친구 추가 제공,
- 친구의 상태 (삭제,추가,차단) 실시간 구독 제공
- 채팅방의 상태 (존재, 차단) 실시간 구독 제공

**AddFriend**
- uniqueId통해 친구 검색 후 추가

**Chat**
- 유저 프로필 통해 채팅방 진입,
- 메시지 pageNation, -> 첫 진입시 20개 , 상위로 스크롤 올리면 추가 20개씩

### 6.3 유저프로필, 차단, 신고 

| UserProfile | block | beforeReport | report |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="userProfile" src="https://github.com/user-attachments/assets/53e2c3c1-1bf7-4bfb-bb4c-bff4f3afea9f" /> | <img width="198" height="430" alt="blockUser" src="https://github.com/user-attachments/assets/6ad649eb-a8fb-4a18-a019-a7393e87a32f" /> | <img width="198" height="430" alt="IMG_4537" src="https://github.com/user-attachments/assets/3a76f4c2-956d-449b-83b1-6fb7eb516be3" /> |<img width="198" height="430" alt="IMG_4538" src="https://github.com/user-attachments/assets/0e95b29b-3fa5-4234-9da1-4d07a419b819" />|

**UserProfile**
- 유저 프로필은 채팅하기 , 신고,차단,신고,친구삭제를 제공
- 상대 유저를 구독하여 반응형으로 동작
- 상대 유저를 차단하면 이후에는 상대 유저 필터링기능 (UserModel.blockFriend로 제공)
- 차단 이후 상대유저 채팅방 필터링, 그룹채팅 등에서 상대유저 메시지 필터링

**report**
- 애플 심사를 위해 제공, 3가지 카테고리로 정해서 상대 uid통해 신고하는 기능

### 6.4 그룹 생성, 그룹뷰, 그룹에 초대 

| CreateGroup | After | Group | GroupInvite |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="createGroup" src="https://github.com/user-attachments/assets/af89c24d-a70e-457a-b6a0-79c55e2faca1" />| <img width="198" height="430" alt="afterCrGr" src="https://github.com/user-attachments/assets/58ee05e3-098c-4d78-b3bd-12c94027e005" />| <img width="198" height="430" alt="group" src="https://github.com/user-attachments/assets/ef8a8fba-3f02-4511-9fd8-3bf6d5ebf630" /> |<img width="198" height="430" alt="inviteGr" src="https://github.com/user-attachments/assets/3448ec7a-cd92-4b3d-8edd-093f8b0d242e" />|


**CreateGroup**
- 그룹을 생성할 수 있습니다
- 현재 친구로 저장되어 있는 사람을 초대할 수 있습니다.
- 그룹 제목은 비속어 필터링이 적용되어있습니다.

**Group**
- 앱의 핵심 기능중 하나인 그룹입니다.
- 그룹 내에서 약속을 생성할 수 있습니다.
- 마감이 지난 약속 또한 볼 수 있습니다.
- 그룹을 생성한 사람이 그룹장입니다.
- 그룹은 그룹장만 삭제할 수 있으며, 약속의 마감 또한 그룹장이 결정합니다.
- 그룹에는 친구초대가 가능합니다.
- 그룹은 그룹 채팅방을 제공합니다. 

**GroupChat**

<img width="198" height="430" alt="groupChat" src="https://github.com/user-attachments/assets/983cbca6-9320-4e38-bf67-af3dcbf381af" />

- 그룹채팅을 제공합니다.
- 개인채팅과 마찬가지로 페이지네이션을 제공합니다.
- 차단된 유저의 메시지는 senderId로 구분해 필터링합니다.
- 약속 알림, 위치 공유 등의 시스템메시지가 전송됩니다. 

### 6.5 약속생성 ( 장소선택, 장소 검색, 시간정하기 )

| CreatePromise | SelectLocation | PageNation |
|:--:|:--:|:--:|
| <img width="198" height="430" alt="createPromise" src="https://github.com/user-attachments/assets/a98efdab-abac-45d0-a5f5-1ec22f80774a" />| <img width="198" height="430" alt="searchLocat" src="https://github.com/user-attachments/assets/b8b439f7-d4e3-4c7d-895b-b237b49cf5e7" /> |<img width="198" height="430" alt="searchLocat2" src="https://github.com/user-attachments/assets/1890e8a9-db08-4a31-a035-6a3a74154af3" />|

| SelectAddr | SelectTime1 | SelectTime2 | PromiseCreated |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="searchAddr" src="https://github.com/user-attachments/assets/6df49811-3a14-4569-b960-b81b8d4603ef" />| <img width="198" height="430" alt="selectT" src="https://github.com/user-attachments/assets/ab2b5039-17e8-4a5e-a4da-ac2fa30ede7a" />| <img width="198" height="430" alt="selectT2" src="https://github.com/user-attachments/assets/5766a363-a20b-4420-a0e7-482d73fbbbc4" /> |<img width="198" height="430" alt="proCreAft" src="https://github.com/user-attachments/assets/5ceff2b7-2c5d-49c8-b698-b1ea18e20d08" />|

**CreatePromise**

- 그룹 내에서 약속을 생성합니다. 이름, 구성원, 위치 , 시간을 정한 후 약속을 생성합니다.

**SelectLocation**

- 약속 내의 장소를 검색 후 정하는 화면입니다.
- 키워드로 검색 , 주소로 검색으로 분리됩니다.
- 키워드로 검색은 주소와 좌표를 제공하고, 주소로 검색은 좌표와 주소를 제공합니다. (kakao local api를 사용했습니다)
- 키워드로 검색은 페이지네이션을 제공합니다. ( 처음 10개 이후 더보기 버튼으로 10개씩 추가)
- NaverMap을 통해 좌표를 보여줍니다.

**SelectTime**
- 약속의 시간을 정하는 화면입니다.

### 6.6 약속화면, 위치공유, 위치공유 이후, 약속 마감 

| Promise | LocatShare | shareAfter1 | shareAfter2 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="promise" src="https://github.com/user-attachments/assets/b5f954b7-4821-478d-acc2-804a9366f3d1" />| <img width="198" height="430" alt="share" src="https://github.com/user-attachments/assets/6b95fecc-703e-4832-ab5a-9f8554e657cd" />| <img width="198" height="430" alt="shareAfter1" src="https://github.com/user-attachments/assets/722f188b-2700-4be1-ac10-3d18bcc54b7e" /> |<img width="198" height="430" alt="shareAfter2" src="https://github.com/user-attachments/assets/c2f383e7-0a59-477b-8879-cce01812a8ca" />|

**Promise**

- 약속뷰입니다. 약속뷰는 1페이지 2페이지로 구성됩니다.
- 1페이지는 약속에 대한 정보, 참여자들의 위치정보 (위치를 공유했는지, 공유했다면 탭으로 상대유저의 위치를 확인)
- 2페이지는 약속시간이 지난 후 볼 수있습니다 (지각한사람 도착한 사람을 보여줍니다.)
- 약속 화면은 위치공유를 제공합니다

**LocationShare**
- 위치를 공유하는 화면입니다.
- 위치를 공유하면 약속화면에서 상대방이 나의 위치를 확인할 수 있습니다.
- 위치를 공유하면 그룹채팅방에도 나의 위치가 전송됩니다.
- 도착의 기준은 100m2 입니다. 거리계산 usecase를 사용하여 현재 나의 위치를 계산하고, 100m2 이하이면 도착처리합니다.

**약속이 마감 된 후**

<img width="198" height="430" alt="endPromise" src="https://github.com/user-attachments/assets/6479ad3d-a7df-4193-9605-55103406752e" />

- 그룹장은 약속을 마감할 수 있습니다. 
- 마감된 약속은 그룹뷰에서 기록으로 남습니다. 


### 6.7 알림 화면

<img width="198" height="430" alt="notification" src="https://github.com/user-attachments/assets/c2625c3b-3b9b-4282-9a48-c25b35c17498" />

- 바텀네비게이션에서 알림 화면을 제공합니다.
- 상단은 현재 로그인한 유저의 정보, 하단은 내가 받은 push message를 보여줍니다.

### 6.8 설정 화면 

<img width="198" height="430" alt="setting" src="https://github.com/user-attachments/assets/a8b9919a-c7da-4b5a-a8c6-6912658b6f6e" />

- 개인정보 처리방침, 서비스 이용약관을 볼 수 있습니다.
- 알림 on/off 기능이 존재합니다. (기본적으로는 현재상태를 반영합니다)
- 로그아웃과 탈퇴하기 기능이 있습니다.
- 로그아웃을 하면 login화면으로 이동합니다.
- 탈퇴하기를하면 Firebase Function에서 모든 기록을 삭제하고 유저는 GoodByeView로 이동합니다.


  
---
## 7. 데이터베이스 모델 구조 (firestore)

<img width="935" height="932" alt="스크린샷 2025-07-15 오후 9 18 00" src="https://github.com/user-attachments/assets/21e1fe4c-3a3e-46ed-b36c-714419c32bed" />


**최상위 컬렉션**

- uesers, groups, promises, reports, privateChatRooms는 최상위 컬렉션입니다. 

**서브컬렉션**

- user_notifications은 user내의 알림메시지를 나타냅니다. 
- group_chat_messages 는 각 groups 하위의 채팅 메시지 목록입니다.
- private_chat_messages 는 각 private chat Rooms 문서 하위의 채팅 메시지 목록 입니다. 


---


## 7. 트러블 슈팅 및 문제 해결 경험 
트러블 슈팅: 비동기 처리 최적화를 통한 사용자 경험(UX) 개선
문제점
그룹 생성 기능 실행 시, 사용자는 그룹 정보가 데이터베이스에 저장된 후 FCM 푸시 알림 전송까지 모든 과정이 끝날 때까지 기다려야 했습니다.

Stopwatch를 이용한 테스트 결과, 푸시 알림 전송에 상당한 시간이 소요되어 사용자가 '그룹 생성' 버튼을 누른 후 다음 화면으로 넘어가기까지 평균 6,074ms(약 6초)의 불필요한 대기 시간이 발생하는 것을 확인했습니다.

해결책
사용자 경험을 개선하기 위해, 기능의 흐름을 분석했습니다. 그룹 생성 자체는 DB에 저장되는 시점에 완료되며, 푸시 알림 전송은 그 결과를 사용자에게 알려주는 부가적인 작업이라고 판단했습니다.

이에 따라, sendGroupNotification 함수를 호출하는 부분의 await 키워드를 제거하여 'fire-and-forget'(실행 후 즉시 다음으로 넘어가는) 방식으로 코드를 수정했습니다. 이를 통해 앱은 푸시 알림이 백그라운드에서 전송되는 동안 다음 로직을 즉시 실행할 수 있게 되었습니다.

개선 결과
await를 제거하는 간단한 코드 수정만으로, 사용자가 '그룹 생성 완료' 피드백을 받기까지 걸리는 대기 시간을 평균 692ms(약 0.7초)로 단축시켰습니다.

결과적으로 사용자 체감 응답 시간을 약 88% 개선하여, 훨씬 쾌적한 앱 사용 경험을 제공할 수 있게 되었습니다. 이는 비동기 코드의 동작 방식을 이해하고 사용자 경험 관점에서 로직을 최적화한 의미 있는 개선 사례입니다.

## 8. 프로젝트 회고 


## 앱 기능별 사진 모음 

| Splash | Login | Input |
|:--:|:--:|:--:|
| <img width="199" height="372" alt="splash" src="https://github.com/user-attachments/assets/e4b7bebe-5c12-4237-bf45-2605a68f9ae3" /> | <img width="199" height="372" alt="login" src="https://github.com/user-attachments/assets/0b2fe9ca-e237-4ae2-9f63-3a8b973d71fb" /> | <img width="199" height="372" alt="input" src="https://github.com/user-attachments/assets/5a34288f-3ec2-4691-a3d3-9b1408fa2535" /> |

| PrivateChat | AddFriend | Chat | AfterChat |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="mainHome1" src="https://github.com/user-attachments/assets/13d2f89e-9a4c-423b-a13e-38346643d048" /> | <img width="198" height="430" alt="addFriend" src="https://github.com/user-attachments/assets/346f3b3d-1c21-4282-86f7-5a0514964098" /> | <img width="198" height="430" alt="chat" src="https://github.com/user-attachments/assets/90a40801-168b-48d4-ab90-3812fef38861" /> |<img width="198" height="430" alt="afterChat" src="https://github.com/user-attachments/assets/28028816-216c-4546-b86a-8e8dbaa9edbd" />|
| UserProfile | block | beforeReport | report |
|:--:|:--:|:--:|:--:|
| <img width="198" height="430" alt="userProfile" src="https://github.com/user-attachments/assets/53e2c3c1-1bf7-4bfb-bb4c-bff4f3afea9f" /> | <img width="198" height="430" alt="blockUser" src="https://github.com/user-attachments/assets/6ad649eb-a8fb-4a18-a019-a7393e87a32f" /> | <img width="198" height="430" alt="IMG_4537" src="https://github.com/user-attachments/assets/3a76f4c2-956d-449b-83b1-6fb7eb516be3" /> |<img width="198" height="430" alt="IMG_4538" src="https://github.com/user-attachments/assets/0e95b29b-3fa5-4234-9da1-4d07a419b819" />|
| CreateGroup | After | Group | GroupInvite |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="createGroup" src="https://github.com/user-attachments/assets/af89c24d-a70e-457a-b6a0-79c55e2faca1" />| <img width="198" height="430" alt="afterCrGr" src="https://github.com/user-attachments/assets/58ee05e3-098c-4d78-b3bd-12c94027e005" />| <img width="198" height="430" alt="group" src="https://github.com/user-attachments/assets/ef8a8fba-3f02-4511-9fd8-3bf6d5ebf630" /> |<img width="198" height="430" alt="inviteGr" src="https://github.com/user-attachments/assets/3448ec7a-cd92-4b3d-8edd-093f8b0d242e" />|
| GroupChat | CreatePromise | SelectLocation | PageNation |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="groupChat" src="https://github.com/user-attachments/assets/983cbca6-9320-4e38-bf67-af3dcbf381af" />| <img width="198" height="430" alt="createPromise" src="https://github.com/user-attachments/assets/a98efdab-abac-45d0-a5f5-1ec22f80774a" />| <img width="198" height="430" alt="searchLocat" src="https://github.com/user-attachments/assets/b8b439f7-d4e3-4c7d-895b-b237b49cf5e7" /> |<img width="198" height="430" alt="searchLocat2" src="https://github.com/user-attachments/assets/1890e8a9-db08-4a31-a035-6a3a74154af3" />|
| SelectAddr | SelectTime1 | SelectTime2 | PromiseCreated |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="searchAddr" src="https://github.com/user-attachments/assets/6df49811-3a14-4569-b960-b81b8d4603ef" />| <img width="198" height="430" alt="selectT" src="https://github.com/user-attachments/assets/ab2b5039-17e8-4a5e-a4da-ac2fa30ede7a" />| <img width="198" height="430" alt="selectT2" src="https://github.com/user-attachments/assets/5766a363-a20b-4420-a0e7-482d73fbbbc4" /> |<img width="198" height="430" alt="proCreAft" src="https://github.com/user-attachments/assets/5ceff2b7-2c5d-49c8-b698-b1ea18e20d08" />|
| Promise | LocatShare | shareAfter1 | shareAfter2 |
|:--:|:--:|:--:|:--:|
|<img width="198" height="430" alt="promise" src="https://github.com/user-attachments/assets/b5f954b7-4821-478d-acc2-804a9366f3d1" />| <img width="198" height="430" alt="share" src="https://github.com/user-attachments/assets/6b95fecc-703e-4832-ab5a-9f8554e657cd" />| <img width="198" height="430" alt="shareAfter1" src="https://github.com/user-attachments/assets/722f188b-2700-4be1-ac10-3d18bcc54b7e" /> |<img width="198" height="430" alt="shareAfter2" src="https://github.com/user-attachments/assets/c2f383e7-0a59-477b-8879-cce01812a8ca" />|

| EndPromise | Notification | Setting |
|:--:|:--:|:--:|
|<img width="198" height="430" alt="endPromise" src="https://github.com/user-attachments/assets/6479ad3d-a7df-4193-9605-55103406752e" />| <img width="198" height="430" alt="notification" src="https://github.com/user-attachments/assets/c2625c3b-3b9b-4282-9a48-c25b35c17498" />|<img width="198" height="430" alt="setting" src="https://github.com/user-attachments/assets/a8b9919a-c7da-4b5a-a8c6-6912658b6f6e" />|























