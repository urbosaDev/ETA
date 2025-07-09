import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/domain/usecase/search_location_usecase.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_location/select_location_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/common_text_field.dart';

class SelectLocationView extends StatelessWidget {
  SelectLocationView({super.key});
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelectLocationViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('위치 선택', style: textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CommonTextField(
              controller: textController,
              hintText: '위치 검색 (주소, 장소 이름 등)',
              keyboardType: TextInputType.text,
              onChanged: (value) {},
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
                controller.searchFirstPage(value);
              },
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.searchFirstPage(textController.text);
                },
              ),
              textStyle: textTheme.bodyMedium,
              hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  RadioListTile<SearchType>(
                    title: Text(
                      "키워드로 검색",
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    value: SearchType.keyword,
                    groupValue: controller.searchType.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.searchType.value = value;
                      }
                    },
                    activeColor:
                        Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.backgroundColor
                            ?.resolve({}) ??
                        Colors.blueAccent,
                    tileColor: const Color(0xff1a1a1a),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<SearchType>(
                    title: Text(
                      "주소로 검색",
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    value: SearchType.address,
                    groupValue: controller.searchType.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.searchType.value = value;
                      }
                    },
                    activeColor:
                        Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.backgroundColor
                            ?.resolve({}) ??
                        Colors.blueAccent,
                    tileColor: const Color(0xff1a1a1a),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.5665, 126.9780),
                      zoom: 14,
                    ),
                  ),
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
                            onPressed: () {
                              Get.back(result: selected);
                            },
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: Text(
                              "${selected.placeName} 선택하기",
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : const SizedBox();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              final results = controller.searchResults;
              final isLast = controller.isLastPage.value;
              final isLoading = controller.isLoading.value;
              final hasSearched = controller.hasSearched.value;

              if (!hasSearched) {
                return Center(
                  child: Text(
                    '위치를 검색해주세요.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                );
              }

              if (results.isEmpty && !isLoading) {
                return Center(
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: results.length + (isLast ? 0 : 1),
                separatorBuilder:
                    (context, index) => const Divider(
                      color: Colors.white12,
                      thickness: 0.2,
                      indent: 16,
                      endIndent: 16,
                    ),
                itemBuilder: (context, index) {
                  if (index < results.length) {
                    final location = results[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                      ),
                      title: Text(
                        location.placeName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        location.address,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      tileColor:
                          controller.selectedLocation.value?.placeName ==
                                  location.placeName
                              ? Colors.white.withOpacity(0.05)
                              : null,
                      selected:
                          controller.selectedLocation.value?.placeName ==
                          location.placeName,
                      onTap: () => controller.selectLocation(location),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                        isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  textTheme.bodyMedium?.color ?? Colors.white,
                                ),
                              ),
                            )
                            : ElevatedButton(
                              onPressed: () {
                                controller.loadNextPage();
                              },
                              style: Theme.of(
                                context,
                              ).elevatedButtonTheme.style?.copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.grey[800],
                                ),
                              ),
                              child: Text(
                                "더보기",
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
