import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/%08home/group/promise/pay/promise_payment_view_model.dart';
import 'package:what_is_your_eta/presentation/core/widget/user_tile.dart';

class PromisePaymentView extends GetView<PromisePaymentViewModel> {
  const PromisePaymentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('정산하기')),

      bottomNavigationBar: Obx(() {
        final isEnabled =
            controller.totalAmount.value > 0 &&
            controller.selectedMembers.isNotEmpty &&
            controller.bankName.isNotEmpty &&
            controller.accountNumber.isNotEmpty;

        return SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  isEnabled
                      ? () async {
                        final success = await controller.notifyPayment();
                        if (success) {
                          Get.back(); // 성공시 뒤로가기
                        } else {
                          Get.snackbar(
                            '오류',
                            '정산 알리기에 실패했습니다. 다시 시도해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
              ),
              child: Text(
                '약속에 ₩${controller.perPersonAmount} 정산 알리기',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey.shade200,
                ),
              ),
            ),
          ),
        );
      }),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTotalAmountSection(controller),
              const SizedBox(height: 24),
              buildMemberSelectionSection(controller),
              const SizedBox(height: 24),
              buildAccountSection(controller),
              const SizedBox(height: 80), // 버튼 가려짐 방지용 여백
            ],
          ),
        );
      }),
    );
  }
}

Widget buildTotalAmountSection(PromisePaymentViewModel controller) {
  final textController = TextEditingController();

  return Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('총 금액을 입력해주세요'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '${controller.totalAmount.value}',
                  suffixText: '원',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val.replaceAll(',', '')) ?? 0;
                  controller.totalAmount.value = parsed;
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              child: const Text('완료'),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildMemberSelectionSection(PromisePaymentViewModel controller) {
  return Obx(() {
    final members = controller.memberList;
    final selected = controller.selectedMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('참여자 (${selected.length}명)'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final user = members[index];
              final isSelected = selected.contains(user);
              return UserTile(
                user: user,
                isSelected: isSelected,
                onTap: () => controller.toggleMember(user),
              );
            },
          ),
        ),
      ],
    );
  });
}

Widget buildAccountSection(PromisePaymentViewModel controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('어디로 입금해야할까요?'),
      const SizedBox(height: 8),
      TextField(
        textInputAction: TextInputAction.next,
        onChanged: controller.setBankName,
        decoration: InputDecoration(
          labelText: '은행명 / 예금주',
          border: const OutlineInputBorder(),
          hintText:
              controller.bankName.value.isEmpty
                  ? '예: 하나은행 / 김민수'
                  : controller.bankName.value,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: controller.setAccountNumber,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                labelText: '계좌번호',
                border: const OutlineInputBorder(),
                hintText:
                    controller.accountNumber.value.isEmpty
                        ? '예: 12345678901234'
                        : controller.accountNumber.value,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    ],
  );
}
