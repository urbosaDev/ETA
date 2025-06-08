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
}
