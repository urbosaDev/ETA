import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/domain/usecase/search_location_usecase.dart';
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
                    controller.searchFirstPage(textController.text);
                  },
                ),
              ),
            ),
          ),
          Obx(
            () => Column(
              children: [
                RadioListTile<SearchType>(
                  title: const Text("키워드로 검색"),
                  value: SearchType.keyword,
                  groupValue: controller.searchType.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.searchType.value = value;
                    }
                  },
                ),
                RadioListTile<SearchType>(
                  title: const Text("주소로 검색"),
                  value: SearchType.address,
                  groupValue: controller.searchType.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.searchType.value = value;
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                NaverMap(
                  // key: UniqueKey(),
                  options: const NaverMapViewOptions(),
                  onMapReady: controller.onMapReady,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Obx(() {
                      final selected = controller.selectedLocation.value;
                      return selected != null
                          ? ElevatedButton(
                            onPressed: () async {
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              Get.back(
                                result: controller.selectedLocation.value,
                              );
                            },
                            child: Text("${selected.placeName} 선택하기"),
                          )
                          : const SizedBox();
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final results = controller.searchResults;
              final isLast = controller.isLastPage.value;
              final isLoading = controller.isLoading.value;
              final hasSearched = controller.hasSearched.value;

              if (!hasSearched) {
                return const SizedBox();
              }

              if (results.isEmpty) {
                return const Center(child: Text('검색 결과가 없습니다.'));
              }

              return ListView.builder(
                itemCount: results.length + (isLast ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index < results.length) {
                    final location = results[index];
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
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                              onPressed: () {
                                controller.loadNextPage();
                              },
                              child: const Text("더보기"),
                            ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
