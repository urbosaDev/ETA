import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/model/promise_member_status.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/status/promise_status_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class PromiseStatusView extends GetView<PromiseStatusViewModel> {
  const PromiseStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약속 상태')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 네이버맵
          Expanded(flex: 2, child: _buildNaverMap()),

          // 유저 리스트
          Expanded(child: _buildMemberStatus()),
        ],
      ),
    );
  }

  Widget _buildMemberStatus() {
    return Obx(() {
      final selectedUid = controller.selectedUser.value?.user.uid;
      final list = controller.promiseMemberStatusList;
      return ListView.separated(
        itemCount: list.length,
        physics: const ClampingScrollPhysics(),

        separatorBuilder: (_, __) => const Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          final member = list[index];

          return UserTile(
            user: member.user,
            onTap: () {
              controller.selectUser(member);
            },
            isSelected: selectedUid == member.user.uid,
            trailing:
                member.updateStatus == MemberUpdateStatus.notUpdated
                    ? const Text(
                      '업데이트 필요',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '"${member.address}"',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${member.distance?.toStringAsFixed(1)} m',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
          );
        },
      );
    });
  }

  Widget _buildNaverMap() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final currentLatLng = controller.currentLatLng;

      if (isLoading || currentLatLng == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          NaverMap(
            // key: UniqueKey(),
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  currentLatLng.latitude,
                  currentLatLng.longitude,
                ),
                zoom: 15,
              ),
              locationButtonEnable: false,
              indoorEnable: false,
              scaleBarEnable: false,
            ),
            onMapReady: (mapController) async {
              controller.mapController.value = mapController;
            },
          ),
          _buildStackStatus(),
        ],
      );
    });
  }

  Widget _buildStackStatus() {
    return Obx(() {
      if (controller.selectedUser.value == null) {
        return const SizedBox.shrink();
      }

      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                controller.selectedUser.value?.location?.address ?? '주소 없음',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${controller.selectedUser.value?.distance?.toStringAsFixed(1) ?? '-'} m',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    });
  }
}
