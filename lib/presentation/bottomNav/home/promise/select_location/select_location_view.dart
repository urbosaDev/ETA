import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_location/select_location_view_model.dart';

class SelectLocationView extends StatelessWidget {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelectLocationViewModel>();
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('위치 선택')),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: '위치 검색 예시(주소, 장소 이름 등)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.searchLocation(
                      textController.text,
                      isFirst: true,
                    );
                  },
                ),
              ),
            ),
          ),

          // 체크박스
          Obx(
            () => CheckboxListTile(
              title: const Text("내 주변 카테고리 검색 (예: 카페, 고기집 등)"),
              value: controller.isNearbySearch.value,
              onChanged: (value) => controller.isNearbySearch.value = value!,
            ),
          ),

          // 네이버 지도 (고정 높이)
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                NaverMap(
                  key: UniqueKey(),
                  options: const NaverMapViewOptions(),
                  onMapReady: controller.onMapReady,
                ),
                // 마커 위에 "선택하기" 버튼
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Obx(() {
                      final selected = controller.selectedLocation.value;
                      return selected != null
                          ? ElevatedButton(
                            onPressed: () {
                              Get.back(
                                result: controller.selectedLocation.value,
                              );
                            },
                            child: Text("${selected.placeName} 선택하기"),
                          )
                          : const SizedBox(); // 선택 안 했으면 표시 안 함
                    }),
                  ),
                ),
              ],
            ),
          ),

          // 검색 결과 리스트 (이 부분만 스크롤)
          Expanded(
            child: Obx(() {
              final results = controller.searchResults;
              final isLast = controller.isLastPage;
              final isLoading = controller.isLoading.value;
              final hasSearched = controller.lastKeyword.isNotEmpty;

              return hasSearched
                  ? ListView.builder(
                    itemCount: results.length + (isLast ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index < results.length) {
                        final location = results[index];
                        return Obx(() {
                          return ListTile(
                            title: Text(location.placeName),
                            subtitle: Text(location.address),
                            tileColor:
                                controller.selectedLocation.value?.placeName ==
                                        location.placeName
                                    ? Colors.grey[200]
                                    : null,
                            onTap: () => controller.selectLocation(location),
                          );
                        });
                      }

                      // 리스트 마지막 더보기 버튼 (검색 결과 있을 때만)
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  onPressed: () {
                                    controller.searchLocation(
                                      controller.lastKeyword,
                                      isFirst: false,
                                    );
                                  },
                                  child: const Text("더보기"),
                                ),
                      );
                    },
                  )
                  : const SizedBox(); // 검색 안 한 상태면 빈 위젯
            }),
          ),
        ],
      ),
    );
  }
}
