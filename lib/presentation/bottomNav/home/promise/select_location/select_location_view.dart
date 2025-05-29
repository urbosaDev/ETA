import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_location/select_location_view_model.dart';

class SelectLocationView extends GetView<SelectLocationViewModel> {
  const SelectLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 선택')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('위치 선택 화면'),
            ElevatedButton(
              onPressed: () {
                // 위치 선택 로직 추가
              },
              child: const Text('위치 선택하기'),
            ),
            SizedBox(
              height: 300,
              child: NaverMap(
                options: const NaverMapViewOptions(),
                onMapReady: (controller) {
                  print("네이버 맵 로딩됨!");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
