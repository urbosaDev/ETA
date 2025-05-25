import 'dart:async';
import 'package:get/get.dart';
import 'package:what_is_your_eta/data/model/group_model.dart';
import 'package:what_is_your_eta/data/repository/group_repository.dart';

class GroupViewModel extends GetxController {
  final GroupModel group;
  final GroupRepository _groupRepository;
  GroupViewModel({
    required GroupRepository groupRepository,
    required this.group,
  }) : _groupRepository = groupRepository;

  final Rx<GroupModel?> groupModel = Rx<GroupModel?>(null);
  final RxBool isLoading = true.obs;
  StreamSubscription<GroupModel>? _groupSub;

  @override
  void onInit() {
    isLoading.value = true;
    super.onInit();
    groupModel.value = group;
    _initGroup();
    isLoading.value = false;
  }

  @override
  void onClose() {
    _groupSub?.cancel();
    super.onClose();
  }

  // init 시에 그룹 정보 불러오기,
  // stream 해야함,
  //
  void _initGroup() async {
    groupModel.value = await _groupRepository.getGroup(group.id);
    // groupModel.value = groupModel.value;
    _startGroupStream();
  }

  void _startGroupStream() {
    _groupSub = _groupRepository.streamGroup(group.id).listen((group) {
      groupModel.value = group;
    });
  }
}
