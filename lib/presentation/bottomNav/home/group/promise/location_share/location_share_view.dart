import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

class LocationShareView extends GetView<LocationShareViewModel> {
  const LocationShareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 공유'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Obx(() {
                          final location = controller.currentLocation.value;
                          final distance =
                              controller.distanceToPromiseMeters.value;
                          return _buildCurrentLocation(location, distance);
                        }),
                      ),
                    ],
                  ),

                  // Naver Map
                  Flexible(
                    flex: 3,
                    child: Obx(() {
                      final isLoading = controller.isLoading.value;
                      final location = controller.currentLocation.value;
                      return SizedBox(
                        height: 200,
                        child: _buildNaverMap(isLoading, location),
                      );
                    }),
                  ),

                  // 버튼들
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await controller.updateUserLocation();
                        },
                        child: const Text('위치공유'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await controller.arriveLocation();
                        },
                        child: const Text('도착'),
                      ),
                    ],
                  ),
                  Obx(
                    () =>
                        controller.isAlreadyArrived.value
                            ? const Text(
                              '도착 완료',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),

            // Success / Error message 영역
            Obx(() {
              return _buildMessageBanner();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation(location, distance) {
    if (location == null) {
      return const Text('내 위치 정보를 불러오지 못했습니다.');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '나의 현재 주소:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(location.address, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                '업데이트: ${_formatDateTime(location.updatedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '약속장소와의 거리: ${distance.toStringAsFixed(1)} m',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
  }

  Widget _buildNaverMap(bool isLoading, location) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (location == null) {
      return const Center(child: Text('내 위치 정보를 불러오지 못했습니다.'));
    }

    return NaverMap(
      // key: UniqueKey(),
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(location.latitude, location.longitude),
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
            position: NLatLng(location.latitude, location.longitude),
          ),
        );
      },
    );
  }

  Widget _buildMessageBanner() {
    final message =
        controller.successMessage.value.isNotEmpty
            ? controller.successMessage.value
            : controller.errorMessage.value;

    final isSuccess = controller.successMessage.value.isNotEmpty;

    if (message.isEmpty) return const SizedBox();

    // 자동 clear
    Future.delayed(const Duration(seconds: 2), () {
      controller.clearMessages();
    });

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: message.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
