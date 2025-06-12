import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/location_model/promise_location_model.dart';
import 'package:what_is_your_eta/data/repository/location_repository.dart';
import 'package:what_is_your_eta/domain/usecase/%08geo_current_location_usecase.dart';
import 'package:what_is_your_eta/domain/usecase/search_location_usecase.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/create_promise/create_promise_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_location/select_location_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_location/select_location_view_model.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_time/select_time_view.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/promise/select_time/select_time_view_model.dart';

class CreatePromiseView extends GetView<CreatePromiseViewModel> {
  const CreatePromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('약속 생성'),
            actions: [
              Obx(
                () => TextButton(
                  onPressed:
                      controller.isFormValid.value
                          ? () async {
                            final success = await controller.createPromise();
                            if (success) {
                              Get.back(); // 성공 시 화면 종료
                            } else {
                              Get.snackbar('실패', '약속 생성에 실패했습니다. 다시 시도해주세요.');
                            }
                          }
                          : null,
                  child: Text(
                    '완료',
                    style: TextStyle(
                      color:
                          controller.isFormValid.value
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('약속 이름을 정해요'),
                      Obx(
                        () => Checkbox(
                          value: controller.isNameValid.value,
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildTextField(
                    controller: nameController,
                    label: '약속 이름을 입력해주세요',
                    onChanged: (value) => controller.promiseName.value = value,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('구성원을 모집해요'),
                      Obx(
                        () => Checkbox(
                          value: controller.isMembersValid.value,
                          onChanged: null,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final group = controller.groupModel.value;
                          if (group != null) {
                            controller.fetchMembers(
                              group.memberIds,
                              clearSelection: true,
                            ); // 명시적
                          }
                        },
                        icon: const Text('↻'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.isMemberFetchLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return buildAddMemberField();
                  }),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('약속 위치를 정해봐요'),
                      Obx(
                        () => Checkbox(
                          value: controller.isLocationValid.value,
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildSelectLocationField(),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('약속 시간을 정해요'),
                      Obx(
                        () => Checkbox(
                          value: controller.isTimeValid.value,
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildSelectTimeField(),
                ],
              ),
            ),
          ),
        ),

        Obx(() {
          if (controller.isLoading.value) {
            return const ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildAddMemberField() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.memberList.length,
        itemBuilder: (context, index) {
          final member = controller.memberList[index];

          return Obx(() {
            final isSelected = controller.selectedMemberIds.contains(
              member.uid,
            );

            return GestureDetector(
              onTap: () => controller.toggleMember(member),
              child: Container(
                color:
                    isSelected ? Colors.lightBlue.shade100 : Colors.transparent,
                child: ListTile(
                  title: Text(member.name),
                  subtitle: Text(member.uniqueId),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget buildSelectLocationField() {
    final controller = Get.find<CreatePromiseViewModel>();

    return GestureDetector(
      onTap: () async {
        final selectedLocation = await Get.to<PromiseLocationModel>(
          () => const SelectLocationView(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => GetCurrentLocationUseCase());
            Get.lazyPut(
              () => SearchLocationUseCase(
                locationRepository: Get.find<LocationRepository>(),
              ),
            );
            Get.lazyPut(
              () => SelectLocationViewModel(
                getCurrentLocationUseCase:
                    Get.find<GetCurrentLocationUseCase>(),
                searchLocationUseCase: Get.find<SearchLocationUseCase>(),
              ),
              fenix: false,
            );
          }),
        );

        if (selectedLocation != null) {
          controller.setSelectedLocation(selectedLocation);
        }
      },
      child: Obx(() {
        final location = controller.selectedLocation.value;
        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.amber,
          child: Center(
            child:
                location != null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location.placeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          location.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                    : const Text('약속 위치를 선택하세요'),
          ),
        );
      }),
    );
  }

  Widget buildSelectTimeField() {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await Get.to<DateTime?>(
          () => const SelectTimeView(),
          binding: BindingsBuilder(() {
            Get.put(SelectTimeViewModel());
          }),
        );

        if (selectedTime != null) {
          controller.setPromiseTime(selectedTime);
        }
      },
      child: Obx(() {
        final time = controller.promiseTime.value;
        final displayText =
            time != null
                ? '${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분'
                : '약속 시간을 선택하세요';

        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.amber,
          child: Center(child: Text(displayText)),
        );
      }),
    );
  }
}
