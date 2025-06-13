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
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 약속 장소
              Row(
                children: [
                  // 현재 위치
                  Flexible(
                    flex: 1,
                    child: Obx(() {
                      final location = controller.currentLocation.value;
                      final distance = controller.distanceToPromiseMeters.value;
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

              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text('위치공유')),
                  ElevatedButton(onPressed: () {}, child: const Text('위치공유')),
                ],
              ),
            ],
          ),
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
      key: UniqueKey(),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
