import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/location_share_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/model/promise_member_status.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/promise_info/promise_info_view_model.dart';
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class PromiseInfoView extends GetView<PromiseInfoViewModel> {
  const PromiseInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CommonLoadingLottie());
      }

      final promise = controller.promise.value;
      if (promise == null) {
        return Center(
          child: Text('약속 정보를 불러올 수 없습니다.', style: textTheme.bodyMedium),
        );
      }

      // SingleChildScrollView를 제거하여 페이지 자체는 스크롤 불가능하도록 합니다.
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              textTheme,
              child: Column(
                children: [
                  Obx(() {
                    final latLng = controller.currentPosition.value;
                    final mapDisplayLocation = latLng;
                    if (mapDisplayLocation == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            textTheme.bodyMedium?.color ?? Colors.white,
                          ),
                        ),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: screenHeight * 0.25,
                        child: NaverMap(
                          options: NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(
                              target: mapDisplayLocation,
                              zoom: 16,
                            ),
                            locationButtonEnable: false,
                            indoorEnable: false,
                            scaleBarEnable: false,
                            liteModeEnable: true,
                          ),
                          onMapReady: (mapController) async {
                            controller.mapController.value = mapController;

                            final promiseMarker = NMarker(
                              id: 'promise_location',
                              position: NLatLng(
                                promise.location.latitude,
                                promise.location.longitude,
                              ),
                              caption: NOverlayCaption(
                                text: promise.location.placeName,
                              ),
                            );
                            mapController.addOverlay(promiseMarker);

                            if (latLng != null) {
                              mapController.addOverlay(
                                NMarker(
                                  id: 'current_user_location',
                                  position: latLng,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  Text(
                    '시간: ${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(promise.time)}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),

                  Text(
                    '장소: ${promise.location.placeName}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    promise.location.address,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.setPromiseLocation();
                    },
                    style: Theme.of(
                      context,
                    ).elevatedButtonTheme.style?.copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                    ),
                    child: Text(
                      '약속장소 보기',

                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => LocationShareView(),
                        binding: BindingsBuilder(() {
                          Get.put(
                            LocationShareViewModel(
                              promiseId: promise.id,
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
                    style: Theme.of(
                      context,
                    ).elevatedButtonTheme.style?.copyWith(
                      // 패딩을 줄여 버튼 크기를 작게 만듭니다.
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                    ),
                    child: Text(
                      '내 위치 공유하기',
                      // 텍스트 크기도 bodySmall로 줄여 더 작은 버튼에 맞춥니다.
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 3. 참여자 목록 섹션
            Text(
              '참여자 (${controller.promiseMemberStatusList.length}명)',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildInfoCard(
                context,
                textTheme,
                child: Obx(() {
                  final members = controller.promiseMemberStatusList;
                  if (members.isEmpty) {
                    return Center(
                      child: Text(
                        '참여자가 없습니다.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final memberStatus = members[index];
                      return _buildMemberStatusTile(
                        context,
                        textTheme,
                        memberStatus,
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  // 재사용 가능한 정보 카드 위젯
  Widget _buildInfoCard(
    BuildContext context,
    TextTheme textTheme, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMemberStatusTile(
    BuildContext context,
    TextTheme textTheme,
    PromiseMemberStatus memberStatus,
  ) {
    // PromiseMemberStatus 모델에 `location` 필드가 존재함을 가정합니다.
    return UserTile(
      // ✨ UserTile 위젯 사용
      user: memberStatus.user, // UserModel 전달
      textTheme: textTheme, // ✨ textTheme 전달
      isSelected: false, // PromiseInfoView에서는 isSelected를 사용하지 않음
      onTap:
          memberStatus.updateStatus == MemberUpdateStatus.updated &&
                  memberStatus.location != null
              ? () {
                controller.selectUser(memberStatus); // ViewModel의 selectUser 호출
              }
              : null, // 미공유 또는 위치 정보 없으면 탭 비활성화
      trailing: switch (memberStatus.updateStatus) {
        // ✨ trailing 위젯을 UserTile에 전달
        MemberUpdateStatus.notUpdated => Text(
          '미 공유',
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        MemberUpdateStatus.updated => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '공유 완료',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (memberStatus.distance != null)
              Text(
                '${memberStatus.distance?.toStringAsFixed(1)} m',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      },
      // UserTile 내부에서 contentPadding과 tileColor가 이미 처리됩니다.
      // contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // tileColor: Colors.transparent,
    );
  }
}
