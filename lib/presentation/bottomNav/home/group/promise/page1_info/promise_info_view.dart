import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';

import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/location_share_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/model/promise_member_status.dart';
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

              // 시간,장소 텍스트 섹션
              Obx(() {
                final promise = controller.promise.value;
                if (promise == null) return const SizedBox();
                return buildPromiseTimeSection(
                  promise,
                  height: constraints.maxHeight * 0.07,
                );
              }),
              const SizedBox(height: 14),
              Divider(color: Colors.grey.shade300, thickness: 1),
              // 장소
              Obx(() {
                final latLng = controller.currentPosition.value;

                if (latLng == null) {
                  return SizedBox(
                    height: constraints.maxHeight * 0.25,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return buildPromiseLocationSection(
                  latLng,
                  height: constraints.maxHeight * 0.25,
                );
              }),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300, thickness: 1),

              // 참여자
              Obx(() {
                final members = controller.promiseMemberStatusList;
                return buildPromiseMemberSection(
                  members,
                  height: constraints.maxHeight * 0.27,
                );
              }),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        controller.setPromiseLocation();
                      },
                      child: Text('약속장소 보기'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => LocationShareView(),
                          binding: BindingsBuilder(() {
                            Get.put(
                              LocationShareViewModel(
                                promiseId: controller.promise.value?.id ?? '',
                                promiseRepository: Get.find(),
                                authRepository: Get.find(),
                                locationShareUseCase: LocationShareUseCase(
                                  promiseRepository: Get.find(),
                                  calculateDistanceUseCase: Get.find(),
                                  getCurrentLocationUseCase:
                                      GetCurrentLocationUseCase(),
                                  groupRepository: Get.find(),
                                  locationRepository: Get.find(),
                                  userRepository: Get.find(),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                      child: Text('내 위치 공유하기'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 시간,장소 섹션
  Widget buildPromiseTimeSection(
    PromiseModel promise, {
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: height,
          child: Text(
            '${promise.time.year}년 ${promise.time.month}월 ${promise.time.day}일 ${promise.time.hour}시 ${promise.time.minute}분',
          ),
        ),
        const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: height,
          child: Text(
            '${promise.location.address} ${promise.location.placeName}',
          ),
        ),
      ],
    );
  }

  // 장소 섹션
  Widget buildPromiseLocationSection(
    NLatLng location, {
    required double height,
  }) {
    final NLatLng latLng = NLatLng(location.latitude, location.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: latLng,
                  zoom: 16,
                ),

                locationButtonEnable: false,
                indoorEnable: false,
                scaleBarEnable: false,
              ),
              onMapReady: (mapController) async {
                controller.mapController.value = mapController;
              },
            ),
          ),
        ),
      ],
    );
  }

  // 3. 참여자 섹션
  Widget buildPromiseMemberSection(
    List<PromiseMemberStatus> members, {
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
              return UserTile(
                user: user.user,
                isSelected: false,
                onTap: () => controller.selectUser(user),
                trailing: switch (user.updateStatus) {
                  MemberUpdateStatus.notUpdated => Text(
                    '미 공유',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  MemberUpdateStatus.updated => Column(
                    children: [
                      Text(
                        '공유 완료',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${user.distance?.toStringAsFixed(1)} m',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
