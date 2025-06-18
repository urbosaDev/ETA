import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:what_is_your_eta/presentation/bottomNav/notification/notification_view_model.dart';

class NotificationView extends GetView<NotificationViewModel> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Notification');
  }
}
