import 'dart:async';

import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';
import 'package:what_is_your_eta/data/repository/promise_repository.dart';

class PromiseLogViewModel extends GetxController {
  final String groupId;
  final GroupRepository _groupRepository;
  final PromiseRepository _promiseRepository;

  PromiseLogViewModel({
    required this.groupId,
    required GroupRepository groupRepository,
    required PromiseRepository promiseRepository,
  }) : _groupRepository = groupRepository,
       _promiseRepository = promiseRepository;
  final RxBool isLoading = true.obs;
  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  StreamSubscription<GroupModel>? _groupSub;
  final RxList<PromiseModel> endPromises = <PromiseModel>[].obs;

  @override
  void onInit() {
    _initialize();
    super.onInit();
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    final fetchedGroup = await _groupRepository.getGroup(groupId);
    if (fetchedGroup == null) {
      isLoading.value = false;
      return;
    }
    groupModel.value = fetchedGroup;
    fetchEndPromises(fetchedGroup);
    _groupSub = _groupRepository.streamGroup(groupId).listen((g) {
      groupModel.value = g;
      fetchEndPromises(g);
    });
    isLoading.value = false;
  }

  Future<void> fetchEndPromises(GroupModel groupModel) async {
    try {
      final endPromiseIds = groupModel.endPromiseIds;
      if (endPromiseIds.isEmpty) {
        endPromises.clear();
        return;
      }
      final promises = await _promiseRepository.getPromisesByIds(endPromiseIds);
      endPromises.value = promises;
    } catch (e) {
      endPromises.clear();
    }
  }
}
