import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/location_share/location_share_view_model.dart';

class LocationShareModalView extends GetView<LocationShareModalViewModel> {
  const LocationShareModalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('위치 공유'),
              const SizedBox(height: 16),
              Obx(() {
                return controller.isSharing.value
                    ? const Text('공유 중...')
                    : const Text('공유 준비됨');
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      controller.startSharing();
                    },
                    child: const Text('공유 시작'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.stopSharing();
                    },
                    child: const Text('공유 종료'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // 모달 닫기
                },
                child: const Text('닫기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
