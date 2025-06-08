import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

class LocationShareModalView extends GetView<LocationShareModalViewModel> {
  const LocationShareModalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 주소 + 업데이트 시간 + 새로고침 버튼
                  Obx(() {
                    final location = controller.currentLocation.value;
                    if (location == null) {
                      return const Text('위치 정보를 불러오지 못했습니다.');
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '나의 현재 주소:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location.address,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '업데이트: ${_formatDateTime(location.updatedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            await controller.initCurrentLocation();
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),

                  // NaverMap
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final location = controller.currentLocation.value;
                      if (location == null) {
                        return const Center(child: Text('위치 정보를 불러오지 못했습니다.'));
                      }

                      return NaverMap(
                        key: UniqueKey(),
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                            target: NLatLng(
                              location.latitude,
                              location.longitude,
                            ),
                            zoom: 15,
                          ),
                          locationButtonEnable: false,
                          indoorEnable: false,
                          scaleBarEnable: false,
                        ),
                        onMapReady: (mapController) async {
                          await mapController.addOverlay(
                            NMarker(
                              id: 'current-location-marker',
                              position: NLatLng(
                                location.latitude,
                                location.longitude,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // 하단 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 장소 공유 버튼 눌렀을 때 처리
                        // TODO: 원하는 동작 넣기
                      },
                      child: const Text('장소 공유'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 장소 공유 버튼 눌렀을 때 처리
                        // TODO: 원하는 동작 넣기
                      },
                      child: const Text('도착'),
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽 상단 X 버튼
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
