import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/model/user_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class PromiseInfoView extends GetView<PromiseInfoViewModel> {
  const PromiseInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약속 정보')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 로딩 상태
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink(); // 로딩 아니면 아무것도 안 보여줌
            }),

            // 🔹 시간
            Obx(() {
              final promise = controller.promise.value;
              if (promise == null) return const SizedBox();
              return buildPromiseTimeSection(promise);
            }),
            const SizedBox(height: 24),

            // 🔹 장소
            Obx(() {
              final location = controller.location.value;
              if (location == null) return const SizedBox();
              return buildPromiseLocationSection(location);
            }),
            const SizedBox(height: 24),

            // 🔹 참여자
            Obx(() {
              final members = controller.memberList;
              return buildPromiseMemberSection(members);
            }),
          ],
        ),
      ),
    );
  }
}

// 1. 시간 섹션
Widget buildPromiseTimeSection(PromiseModel promise) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
      Text(promise.time.toLocal().toString()),
    ],
  );
}

// 2. 장소 섹션
Widget buildPromiseLocationSection(PromiseLocationModel location) {
  final NLatLng latLng = NLatLng(location.latitude, location.longitude);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
      Text(location.placeName),
      Text(location.address),
      const SizedBox(height: 8),
      SizedBox(
        height: 300,
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
    ],
  );
}

// 3. 참여자 섹션
Widget buildPromiseMemberSection(List<UserModel> members) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '참여자 (${members.length}명)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...members.map(
        (user) => UserTile(user: user, isSelected: false, onTap: null),
      ),
    ],
  );
}
