import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/user_location_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

class LocationShareView extends GetView<LocationShareViewModel> {
  const LocationShareView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '위치 공유',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.8,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff2a2a2a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.15,
                    child: Obx(() {
                      final location = controller.currentLocation.value;
                      final distance = controller.distanceToPromiseMeters.value;
                      return _buildCurrentLocation(
                        textTheme,
                        location,
                        distance,
                      );
                    }),
                  ),

                  Expanded(
                    child: Obx(() {
                      final isLoading = controller.isLoading.value;
                      final location = controller.currentLocation.value;
                      return _buildNaverMap(textTheme, isLoading, location);
                    }),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller.updateUserLocation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            '위치 공유',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller.arriveLocation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            '도착',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () =>
                        controller.isAlreadyArrived.value
                            ? Text(
                              '도착 완료 ✅',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            final message =
                controller.successMessage.value.isNotEmpty
                    ? controller.successMessage.value
                    : controller.errorMessage.value;
            final isSuccess = controller.successMessage.value.isNotEmpty;
            return _buildMessageBanner(textTheme, message, isSuccess);
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation(TextTheme textTheme, location, distance) {
    if (location == null) {
      return Center(
        child: Text(
          '내 위치 정보를 불러오지 못했습니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      );
    }

    final userLocation = location as UserLocationModel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '나의 현재 주소:',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userLocation.address,
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                '업데이트: ${_formatDateTime(userLocation.updatedAt)}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '약속장소와의 거리: ${distance.toStringAsFixed(1)} m',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: () async {
            await controller.initCurrentLocation();
          },
        ),
      ],
    );
  }

  Widget _buildNaverMap(TextTheme textTheme, bool isLoading, location) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (location == null) {
      return Center(
        child: Text(
          '내 위치 정보를 불러오지 못했습니다.',
          style: textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      );
    }

    final userLocation = location as UserLocationModel;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(userLocation.latitude, userLocation.longitude),
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
              position: NLatLng(userLocation.latitude, userLocation.longitude),

              size: const NSize(24, 30),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBanner(
    TextTheme textTheme,
    String message,
    bool isSuccess,
  ) {
    if (message.isEmpty) return const SizedBox.shrink();

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
            color: isSuccess ? Colors.green[700] : Colors.red[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
