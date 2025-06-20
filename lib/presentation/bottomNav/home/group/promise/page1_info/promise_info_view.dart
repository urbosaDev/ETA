import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/page1_info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class PromiseInfoView extends GetView<PromiseInfoViewModel> {
  const PromiseInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로딩 상태
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink(); // 로딩 아니면 아무것도 안 보여줌
              }),

              // 시간
              Obx(() {
                final promise = controller.promise.value;
                if (promise == null) return const SizedBox();
                return buildPromiseTimeSection(
                  promise,
                  height: constraints.maxHeight * 0.09,
                );
              }),
              const SizedBox(height: 14),
              Divider(color: Colors.grey.shade300, thickness: 1),
              // 장소
              Obx(() {
                final location = controller.location.value;
                if (location == null) return const SizedBox();
                return buildPromiseLocationSection(
                  location,
                  height1: constraints.maxHeight * 0.09,
                  height2: constraints.maxHeight * 0.25,
                );
              }),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300, thickness: 1),

              // 참여자
              Obx(() {
                final members = controller.memberList;
                return buildPromiseMemberSection(
                  members,
                  height: constraints.maxHeight * 0.27,
                );
              }),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('내 위치 공유하기'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 시간섹션
Widget buildPromiseTimeSection(PromiseModel promise, {required double height}) {
  return SizedBox(
    height: height,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '${promise.time.year}년 ${promise.time.month}월 ${promise.time.day}일 ${promise.time.hour}시 ${promise.time.minute}분',
        ),
      ],
    ),
  );
}

// 장소 섹션
Widget buildPromiseLocationSection(
  PromiseLocationModel location, {
  required double height1,
  required double height2,
}) {
  final NLatLng latLng = NLatLng(location.latitude, location.longitude);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: height1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${location.address} ${location.placeName}'),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height2,
          child: NaverMap(
            // key: UniqueKey(),
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: latLng, zoom: 16),
              locationButtonEnable: false,
              indoorEnable: false,
              scaleBarEnable: false,
            ),
            onMapReady: (mapController) async {
              await mapController.addOverlay(
                NMarker(id: 'location-marker', position: latLng),
              );
            },
          ),
        ),
      ),
    ],
  );
}

// 3. 참여자 섹션
Widget buildPromiseMemberSection(
  List<UserModel> members, {
  required double height,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '참여자 (${members.length}명)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: height,
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final user = members[index];
            return UserTile(user: user, isSelected: false, onTap: null);
          },
        ),
      ),
    ],
  );
}
