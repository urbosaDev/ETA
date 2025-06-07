import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/components/swipe_hint.dart';

import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/add_vote_penalty/penalty_container/vote_penalty/vote_penalty_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class VotePenaltyView extends GetView<VotePenaltyViewModel> {
  const VotePenaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '벌칙 투표 화면',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          buildPenaltyVotingBox(),

          _buildVoteProgressBar(),
          _buildFinalPenaltyResult(),
          const SizedBox(height: 16),
          _buildPenaltyVotingStatus(),
          SwipeHint(icon: Icons.arrow_back_ios, label: '벌칙 생성'),
        ],
      ),
    );
  }

  Widget buildPenaltyVotingBox() {
    return Obx(() {
      final list = controller.memberWithStatusList;
      final selected = controller.selectedMember.value;
      final allSuggested = controller.allSuggested.value;

      if (!allSuggested) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white38),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: const Text(
            '아직 모든 사람이 벌칙을 추가하지 않았습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      return Column(
        children: [
          const Text(
            '투표하기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            '투표는 수정할 수 없습니다.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            '투표수가 동일하다면 랜덤으로 선택됩니다.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(
            height: 230,
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final member = list[index];
                final isSelected = selected?.user.uid == member.user.uid;

                return GestureDetector(
                  onTap: () {
                    if (!controller.hasCurrentUserVoted) {
                      controller.selectedMember.value = member;
                    }
                  },
                  child: Container(
                    color:
                        isSelected
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '"${member.description ?? '내용 없음'}" - ${member.isCurrentUser ? "나" : member.user.name}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.orange),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (controller.hasCurrentUserVoted)
            const Text(
              '이미 투표를 완료하셨습니다.',
              style: TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:
                controller.hasCurrentUserVoted || controller.isSubmitting.value
                    ? null
                    : () async {
                      final success = await controller.votePenalty();
                      if (!success) return;

                      final isLast = await controller.isLastVote();
                      if (isLast) {
                        await controller.finalizeSelectedPenalty();
                        await controller.notifyPenalty(); // 메시지 전송까지
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  controller.hasCurrentUserVoted ||
                          controller.isSubmitting.value
                      ? Colors.grey
                      : Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('투표하기'),
          ),
        ],
      );
    });
  }

  Widget _buildVoteProgressBar() {
    return Obx(() {
      final votedCount = controller.votedCount;
      final total = controller.totalMemberCount;
      final progress = total > 0 ? votedCount / total : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '투표 진행률: ${votedCount} / ${total}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFinalPenaltyResult() {
    return Obx(() {
      final selected = controller.promise.value?.selectedPenalty;
      final memberCount = controller.memberList.length;

      if (selected == null) return const Text('아직 최종 벌칙이 선택되지 않았습니다.');

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ 최종 벌칙 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${selected.description}"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '(${selected.userIds.length} / $memberCount 명이 선택했습니다)',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPenaltyVotingStatus() {
    return Obx(() {
      final list = controller.memberWithStatusList;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            '투표 현황',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '모든 참여자가 투표를 완료해야 합니다.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final member = list[index];
                return Container(
                  color:
                      member.isCurrentUser
                          ? Colors.white12
                          : Colors.transparent,
                  child: UserTile(
                    user: member.user.copyWith(
                      name: member.isCurrentUser ? '나' : member.user.name,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          member.hasVoted ? '투표 완료' : '대기 중',
                          style: TextStyle(
                            color:
                                member.hasVoted
                                    ? Colors.greenAccent
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (member.description != null)
                          Text(
                            '"${member.description}"',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
