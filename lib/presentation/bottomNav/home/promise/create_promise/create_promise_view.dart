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
import 'package:what_is_your_eta/presentation/core/loading/common_loading_lottie.dart';
import 'package:what_is_your_eta/presentation/core/widget/common_text_field.dart';

class CreatePromiseView extends GetView<CreatePromiseViewModel> {
  final TextEditingController promiseNameController = TextEditingController();
  CreatePromiseView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final message = controller.systemMessage.value;
      final isPromiseCreated = controller.isPromiseCreated.value;
      final isCreatingPromise = controller.isCreatingPromise.value;
      if (message.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('알림', message, snackPosition: SnackPosition.TOP);
          controller.systemMessage.value = '';
        });
      }
      if (isLoading) {
        return const Center(child: CommonLoadingLottie());
      }
      if (isCreatingPromise) {
        return const Center(child: CommonLoadingLottie());
      }

      if (isPromiseCreated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
        });
      }

      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('약속 생성', style: textTheme.titleLarge),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              ),
              actions: [
                Obx(
                  () => TextButton(
                    onPressed:
                        controller.isFormValid.value &&
                                !controller.containsBlockedWordInName.value
                            ? () async {
                              await controller.createPromise();
                            }
                            : null,
                    child: Text(
                      '완료',
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            controller.isFormValid.value &&
                                    !controller.containsBlockedWordInName.value
                                ? Colors.blueAccent
                                : Colors.grey[600],
                        fontWeight: FontWeight.bold,
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
                    Text(
                      '약속 이름을 정해요',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPromiseNameInput(context, textTheme),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '구성원을 모집해요',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(
                          () => Checkbox(
                            value: controller.isMembersValid.value,
                            onChanged: null,
                            checkColor: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildAddMemberField(context, textTheme),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '약속 위치를 정해봐요',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(
                          () => Checkbox(
                            value: controller.isLocationValid.value,
                            onChanged: null,
                            checkColor: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSelectLocationField(context, textTheme),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '약속 시간을 정해요',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(
                          () => Checkbox(
                            value: controller.isTimeValid.value,
                            onChanged: null,
                            checkColor: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSelectTimeField(context, textTheme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPromiseNameInput(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: promiseNameController,
          hintText: '약속 이름을 입력하세요 (2~20자, 욕설 금지)',
          keyboardType: TextInputType.text,
          onChanged: (value) => controller.onPromiseNameChanged(value),
          maxLength: 8,
        ),
        Obx(() {
          if (controller.containsBlockedWordInName.value) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '❌ 약속 이름에 부적절한 단어가 포함되어 있습니다.',
                style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
              ),
            );
          } else if (controller.promiseName.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '✅ 사용 가능한 이름입니다.',
                style: textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '약속 이름을 입력해주세요.',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildAddMemberField(BuildContext context, TextTheme textTheme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final members = controller.memberList;
        final selectedUids = controller.selectedMemberIds.toSet();

        if (controller.isMemberFetchLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textTheme.bodyMedium?.color ?? Colors.white,
              ),
            ),
          );
        }
        if (members.isEmpty) {
          return Center(
            child: Text(
              '그룹 멤버를 불러오는 중이거나 없습니다.',
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          );
        } else {
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: members.length,
            separatorBuilder:
                (context, index) => const Divider(
                  color: Colors.white12,
                  thickness: 0.2,
                  indent: 16,
                  endIndent: 16,
                ),
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelected = selectedUids.contains(member.uid);

              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      member.photoUrl.isNotEmpty
                          ? NetworkImage(member.photoUrl)
                          : const AssetImage('assets/imgs/default_profile.png')
                              as ImageProvider,
                  backgroundColor: Colors.grey[700],
                ),
                title: Text(
                  member.name,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                subtitle: Text(
                  '@${member.uniqueId}',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.greenAccent : Colors.grey[600],
                  size: 24,
                ),
                onTap: () => controller.toggleMember(member),
                // selected: isSelected,
                // selectedTileColor: Colors.white.withOpacity(0.05),
              );
            },
          );
        }
      }),
    );
  }

  Widget _buildSelectLocationField(BuildContext context, TextTheme textTheme) {
    return GestureDetector(
      onTap: () async {
        final selectedLocation = await Get.to<PromiseLocationModel>(
          () => SelectLocationView(),
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
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Obx(() {
            final location = controller.selectedLocation.value;
            return location != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location.placeName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      location.address,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                : Text(
                  '약속 위치를 선택하세요',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                );
          }),
        ),
      ),
    );
  }

  Widget _buildSelectTimeField(BuildContext context, TextTheme textTheme) {
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
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Obx(() {
            final time = controller.promiseTime.value;
            final displayText =
                time != null
                    ? '${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분'
                    : '약속 시간을 선택하세요';

            return Text(
              displayText,
              style: textTheme.bodyMedium?.copyWith(
                color: time != null ? Colors.white : Colors.white70,
                fontWeight: time != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            );
          }),
        ),
      ),
    );
  }
}
