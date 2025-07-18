# What's Your ETA 
# 기술 명세서 

## 개요

### 이 서비스는 무엇을 제공하는 서비스인가 ? 
- 술자리 혹은 동호회 , 친구들과 모임이 있을때, 
분명 늦는 사람이 있다. 그리고 거리를 속일 수도 있다. 
이를 방지하기 위해 , 벌칙과 사용자의 거리를 제공한다. 

- 그룹을 만들고 , 그룹내의 약속을 제공한다. 
약속은 시간과 장소, 즉 하나의 만남 약속이다. 
각 구성원은 , 약속 장소에 도착 후 "도착 도장"을 찍을 수 있다. 
제한 시간 내에 도착 도장을 찍지 못하면 벌칙

- 한 그룹에 다양한 약속을 만듬으로서 , 해당 그룹이 함께했던 것들을 
기록처럼 남길 수 있다. 
추가적으로, 하나의 약속이 종료되면 인증사진을 첨부할 수 있는 기능을 추가할 예정 

- 다들 오래된 친구 모임 하나씩은 있을거라 생각한다.
이들의 유대감을 위한 앱이다.
**이 앱의 목적은 사람간의 거리이다.만나서 소통하고 기록하고 추억을 공유하기 위함**

- 가까운 지인그룹중 여행을 자주가는 그룹도 있을 것이다. 
커플들이 사용하게 될 수도 있다. 
추가적인 확장으로 이들이 갔던 곳을 지도에 표시할 예정 


### 핵심 기능 나열 
- 로그인 기능 
    - fireAuth 를 통한 googleAuth 사용 
    - fireAuth에서 제공하는 uid를 기준으로 추가적인 data Model 을 가진, 유저를 firestore에 추가로 저장 (User set)
    - 각 사용자는 중복되지 않은 Id를 기입하여 회원가입을 한다. 
    - 로그인 상태의 관리는 FireAuth 를 통한다. 
    - fireStore에 user collection 생성 

- Social 실시간 메시지 
    - 친구를 추가/삭제 , 실시간 메시지기능 
    - 서로 친구 추가 된 유저간 실시간 채팅 
    - 그룹 내 채팅방의 실시간 채팅 

- 그룹 채널 생성 
    - 그룹 채널 collection 생성, 초대한 유저의 수,잡담채팅채널(채널내 채팅방), 제목이 우선 기입 , uid를 생성하고 이를통해 제어
    - 하위 서브 collection으로 "약속"은 시작시 null 약속 추가하기로 data model 넣는다.

- 그룹 채널 내 약속 
    - 약속 추가하기 버튼으로 생성된다.
    - 제목 , 구성원 (그룹 채널 내의 사용자로 한정), 위치, 시간 을 정한다.
    - 위치는 naver map 패키지를 이용한다. 
    - 약속이 생성되면 정보, 정산, 벌칙, 현황 , 메모를 제공한다. 

- 정보 기능
    - 그룹 채널 내 약속 내에서 날짜,시간,주소,참여자를 제공한다. 
    - 진입시에 정보 View 에서 날짜,시간,주소,참여자 정보를 받아온다. 

- 정산 기능 
    - 금액과 인원수를 입력한다, (인원수의 기본값은 참여자 인원수)
    - 계좌번호와 계좌 등 의 정보를 입력하면, 그룹 내 채팅방에 보내진다. 
    - 정산 view model 은 금액/n 의 기능을 제공한다. 

- 벌칙 기능 
    - 벌칙을 사전에 정할 수 있다.
    - 약속 조건에 부합하지 않은 사용자는 벌칙에 걸린다. 

- 현황 기능 
    - 도착 후 도착 도장을 찍을 수 있는 기능 
    - 도착하게 되면 알림 발송 (도착 도장을 찍으라는 알림)

- 메모 기능 (약속 내 메모 기능을 제공)
    - 뺄것같은 기능 (불필요해보임)




